" Specify a directory for plugins
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" List of plugins.
" Make sure you use single quotes

" Shorthand notation
Plug 'rakr/vim-one'            	     " vim-one color theme
Plug 'ncm2/ncm2'                     " completion [dep]: nvim-0.2.2, nvim-yarp, python3
Plug 'roxma/nvim-yarp'               " remote plugin framework required for ncm2
Plug 'ncm2/ncm2-bufword'             " complete words in buffer
Plug 'ncm2/ncm2-path'                " complete paths
Plug 'ncm2/ncm2-jedi'                " Python completion
Plug 'gaalcaras/ncm-R'               " R completion [dep]: ncm2, Nvim-R
Plug 'jalvesaq/Nvim-R'               " required for ncm-R
Plug 'jalvesaq/R-Vim-runtime'        " indent for pipe
Plug 'preservim/nerdtree'        	   " side bar file tree 
Plug 'itchyny/lightline.vim'     	   " minimal status bar
Plug 'tpope/vim-fugitive'     	 	   " git commit in vim session
Plug 'airblade/vim-gitgutter'        " show git changes in gutter
Plug 'easymotion/vim-easymotion' 	   " go to any word quickly '\\w', '\\e', '\\b'
Plug 'yuttie/comfortable-motion.vim' " scrolling 'C-d' or 'C-u'
Plug 'karoliskoncevicius/vim-sendtowindow' " space + hjkl
Plug 'mhinz/vim-startify'             	   " A start menu for vim
Plug 'Raimondi/delimitMate' " automatic closing of quotes, parenthesis, brackets, etc

" Initialize plugin system
call plug#end()

" Use radian (had issue in resizing plot)
"let R_app = "radian"
"let R_cmd = "R"
"let R_hl_term = 0
"let R_args = []  " if you had set any
"let R_bracketed_paste = 1

" NCM2
autocmd BufEnter * call ncm2#enable_for_buffer()    " To enable ncm2 for all buffers.
set completeopt=noinsert,menuone,noselect           " :help Ncm2PopupOpen for more
                                                    " information.

" Theme settings
colorscheme one
set background=dark " for the dark version
set termguicolors

" NerdTree settings
map <C-n> :NERDTreeToggle<CR>
let NERDTreeIgnore = ['\.pyc$']  " ignore pyc files

" Window Splits
set splitright splitbelow
" Remap splits navigation to just CTRL + hjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" Remap close window to just CTRL + q
nnoremap <C-q> <C-w>q
" Make adjusing split sizes a bit more friendly
noremap <silent> <C-Left> :vertical resize -3<CR>
noremap <silent> <C-Right> :vertical resize +3<CR>
noremap <silent> <C-Up> :resize +3<CR>
noremap <silent> <C-Down> :resize -3<CR>
" Change 2 split windows from vert to horiz or horiz to vert
map <Leader>hh <C-w>t<C-w>H
map <Leader>kk <C-w>t<C-w>K
" Start terminals for R and Python sessions '\tr' or '\tp'
map <Leader>tr :new term://bash<CR>iR<CR><C-\><C-n><C-w>k
map <Leader>tp :new term://bash<CR>ipython3<CR><C-\><C-n><C-w>k
map <Leader>tt :new term://bash<CR>i<CR><C-\><C-n><C-w>k


" General settings
set backspace=indent,eol,start  " To make backscape work in all conditions.
set ma                          " To set mark a at current cursor location.
set number                      " To switch the line numbers on.
set expandtab                   " To enter spaces when tab is pressed.
set smarttab                    " To use smart tabs.
set autoindent                  " To copy indentation from current line 
                                " when starting a new line.
set si                          " To switch on smart indentation.
set tabstop=2                   " The width of a hard tabstop
set shiftwidth=2 	        " The size of an indent
set updatetime=100  	        " set update time for gitgutter update
set noswapfile                  " no swap
set clipboard=unnamedplus       " copy/paste between vim and other programs.
set colorcolumn=60              " vertical line to indicate line number
" set vim-r-plugin to 
let r_indent_align_args = 0
" Set vim-r-plugin to mimics ess :
let r_indent_ess_comments = 0
let r_indent_ess_compatible = 0

" Select all
map <C-a> <esc>ggVG<CR>

" Move line up/down: ddkp/ddp
" Open R (\rf) and run line (\d)
" Select and replace all: :%s/SearchWord/ReplaceWord
