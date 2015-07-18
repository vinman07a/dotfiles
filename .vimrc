" Joshua's custom .vimrc
"
" 
" Credit goes to https://github.com/HashBang173
"
 
 
set nocompatible              " be iMproved, required
filetype off                  " required
 
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')
 
" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
 
Plugin 'Valloric/YouCompleteMe'
 
Plugin 'joequery/Stupid-EasyMotion'

 
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
 
 
 
" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif
 
" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
 
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
 
if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  set undofile		" keep an undo file (undo changes after closing)
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
 
" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")
 
" Don't use Ex mode, use Q for formatting
map Q gq
 
" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>
 
"In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif
 
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif
 
" Only do this part when compiled with support for autocommands.
if has("autocmd")
 
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  "filetype plugin indent on
 
  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!
 
  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
 
  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
 
  augroup END
 
else
 
  set autoindent		" always set autoindenting on
 
endif " has("autocmd")
 
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif
 
"Custom Status Line
"set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L] 
set laststatus=2
 
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup
let g:Powerline_symbols = 'fancy'
set noshowmode
set showtabline=2
let g:miniBufExplForceSyntaxEnable = 1
set term=xterm-256color
set termencoding=utf-8
set encoding=utf-8
set t_Co=256
set fillchars+=stl:\ ,stlnc:\
 
set number
 
nmap <C-N><C-N> :set invnumber<CR>
nmap <C-N><C-R> :set invrelativenumber<CR>
nmap <F8> :call Indrmad()<CR>
function! Indrmad()
    let a = &formatoptions
    if match(a, "c") > -1
        set formatoptions-=c formatoptions-=r formatoptions-=o
        set noautoindent
        echom "Auto Indentation/Comments Disabled"
    else
        set formatoptions+=c formatoptions+=r formatoptions+=o
        set autoindent
        echom "Auto Indentation/Comments Enabled"
    endif
endfunction
 
" Toggle for hlsearch
nmap <C-H> :set invhlsearch<CR>
 
" Theme line number sidebar
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE
 
" <F6> to go navigate into prev tab, <F7> to go navigate into next tab 
map <f6> :tabp<CR>
map <f7> :tabn<CR>
 
set expandtab
set tabstop=4
set shiftwidth=4
 
command! -nargs=1 -range SuperRetab <line1>,<line2>s/\v%(^ *)@<= {<args>}/\t/g
 
command! -range=% -nargs=0 Tab2Space execute '<line1>,<line2>s#^\t\+#\=repeat(" ", len(submatch(0))*' . &ts . ')' 
command! -range=% -nargs=0 Space2Tab execute '<line1>,<line2>s#^\( \{'.&ts.'\}\)\+#\=repeat("\t", len(submatch(0))/' . &ts . ')'
 
" Allow :Wq and :W to do the same as :wq and :w respectively 
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
