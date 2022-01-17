" Source: https://www.youtube.com/watch?v=gfa2_6OeOkk

call plug#begin('~/.vim/plugged')
Plug 'rakr/vim-one'
Plug 'scrooloose/nerdtree'           " side bar file tree
Plug 'itchyny/lightline.vim'         " minmal status bar
Plug 'tpope/vim-fugitive'            " allows git commands in vim session
Plug 'easymotion/vim-easymotion'     " go to any word quickly '\\w', '\\e', '\\b'
Plug 'KKPMW/vim-sendtowindow'        " send commands to REPL
call plug#end()

" nerdtree settings
map <C-n> :NERDTreeToggle<CR>

colorscheme one
set background=dark
set termguicolors
set number 
