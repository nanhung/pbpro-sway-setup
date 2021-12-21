#!/bin/sh

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

DEBIAN_VER=buster
CONTAINER_DIR=/var/lib/machines/
CONTAINER_ID=chromium_widevine
TEMP_DIR="$(mktemp -p /var/cache/ -td ChromeOS-IMG.XXXXXX)"

# check online connectivity
wget -q --spider https://google.com
CONNECTION_STATUS=$?
if [[ $CONNECTION_STATUS -ne 0 ]]; then
  echo "You have to establish an online connection first!" 1>&2
  exit 1
fi

set -e # error if a command as non 0 exit
set -u # error if undefined variable

# message functions
msg() {
  ALL_OFF="\e[1;0m"
  BOLD="\e[1;1m"
  GREEN="${BOLD}\e[1;32m"
  local mesg=$1; shift
  printf "${GREEN}==>${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

info() {
  ALL_OFF="\e[1;0m"
  BOLD="\e[1;1m"
  BLUE="${BOLD}\e[1;34m"
  local mesg=$1; shift
  printf "${BLUE}  ->${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

# check for command availability
available () {
  command -v "$1" >/dev/null 2>&1
}

if ! available debootstrap; then
  pacman -S --noconfirm debian-archive-keyring debootstrap
fi

if ! available xhost; then
  pacman -S --noconfirm xorg-xhost
fi

if ! available curl; then
  pacman -S --noconfirm curl
fi

if ! available git; then
  pacman -S --noconfirm git
fi

if [[ ! -d $CONTAINER_DIR ]]; then
  info "Creating base directory for systemd containers $CONTAINER_DIR..."
  mkdir -p $CONTAINER_DIR
fi

if [[ ! -d $CONTAINER_DIR/$CONTAINER_ID ]]; then
  info "Bootstrap new Debian 10 Buster armhf container $CONTAINER_ID..."
  cd $CONTAINER_DIR
  debootstrap --include=systemd-container,debconf --components=main,universe --arch=armhf $DEBIAN_VER $CONTAINER_ID
fi

info "Cloning docker-chromium-armhf from Git repo..."
git clone --progress --depth=1 https://github.com/appelgriebsch/docker-chromium-armhf/ $TEMP_DIR

info "Downloading ChromeOS image..."
CHROMEOS_URL="$(curl -s https://dl.google.com/dl/edgedl/chromeos/recovery/recovery.conf | grep -A11 CB5-312T | sed -n 's/^url=//p')"
CHROMEOS_IMG="$(basename "$CHROMEOS_URL" .zip)"
curl -L "$CHROMEOS_URL" | zcat > "$TEMP_DIR/$CHROMEOS_IMG"

# Note the next free loop device in a variable
info "Mounting local ChromeOS image..."
LOOPD="$(losetup -f)"
mkdir -p $TEMP_DIR/img
losetup -Pf "$TEMP_DIR/$CHROMEOS_IMG"
mount -o ro "${LOOPD}p3" "$TEMP_DIR/img"

info "Setting up environment in systemd container $CONTAINER_ID..."
systemd-nspawn --directory="$CONTAINER_DIR/$CONTAINER_ID" --bind-ro=$TEMP_DIR:/tmp/chromium --pipe /bin/bash <<'EOF'
apt install --yes --no-install-recommends \
  fontconfig fontconfig-config fonts-dejavu-core gconf-service gconf2-common \
  libasn1-8-heimdal libasound2 libasound2-data libatk1.0-0 libatk1.0-data libavahi-client3 libavahi-common-data \
  libavahi-common3 libcairo2 libcups2 libdatrie1 libdbus-1-3 libdbus-glib-1-2 libexpat1 libfontconfig1 \
  libfreetype6 libgconf-2-4 libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgmp10 \
  libgnutls30 libgraphite2-3 libgssapi-krb5-2 libgssapi3-heimdal libgtk2.0-0 \
  libgtk2.0-common libharfbuzz0b libhcrypto4-heimdal libheimbase1-heimdal libheimntlm0-heimdal libhogweed4 \
  libhx509-5-heimdal libjbig0 libk5crypto3 libkeyutils1 \
  libkrb5-26-heimdal libkrb5-3 libkrb5support0 libldap-2.4-2 libnettle6 libnspr4 libnss3 \
  libp11-kit0 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpixman-1-0 libpng16-16 libroken18-heimdal \
  libsasl2-2 libsasl2-modules-db libsqlite3-0 libtasn1-6 libthai-data libthai0 libtiff5 libwind0-heimdal libx11-6 \
  libx11-data libxau6 libxcb-render0 libxcb-shm0 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxdmcp6 \
  libxext6 libxfixes3 libxi6 libxinerama1 libxml2 libxrandr2 libxrender1 libxss1 libxtst6 shared-mime-info ucf \
  x11-common xdg-utils libpulse0 pulseaudio-utils wget libatk-bridge2.0-0 libatspi2.0-0 libgtk-3-0 \
  mesa-va-drivers mesa-vdpau-drivers mesa-utils libosmesa6 libegl1-mesa libwayland-egl1-mesa libgl1-mesa-dri \
  libgles2-mesa libegl1 libgles2

apt install /tmp/chromium/dependencies/chromium*.deb

cp -R /tmp/chromium/img/opt/google/chrome/libwidevinecdm.so /usr/lib/chromium-browser
cp -R /tmp/chromium/img/opt/google/chrome/pepper /usr/lib/chromium-browser
cp -R /tmp/chromium/widevine/netflix-1080p-1.20.1 /usr/lib/chromium-browser/netflix-1080p
cp -R /tmp/chromium/chromium-settings /etc/chromium-browser/default

useradd -m -s /bin/bash chromium
gpasswd -a chromium audio
EOF

info "Cleaning up..."
umount "$TEMP_DIR/img"
losetup -d "$LOOPD"
rm -rf "$TEMP_DIR"
msg "All done! You can use the launcher to start the Chromium Widevine application"
