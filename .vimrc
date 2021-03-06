" credit goes to github.com/neersighted
"
Profiling
"

if has('vim_starting')
    let startup = reltime()
    autocmd VimEnter * let ready = reltime(startup) | redraw | echo reltimestr(ready)
endif

"
" System Detection
"

" Platform Variables {{{
  let s:is_tmux = exists($TMUX)

  let s:is_windows = has('win32') || has('win64')
  let s:is_cygwin  = has('win32unix')
  let s:is_mac     = match(system('uname'), 'Darwin') != -1

  let s:is_gui    = has('gui_running')
  let s:is_gtk    = has('gui_gtk2')
  let s:is_macvim = has('gui_macvim')
  let s:is_neovim = has('nvim')

  if s:is_windows && !s:is_cygwin
    let g:vim = '~/Application Data/Vim'
  elseif s:is_mac
    let g:vim = '~/Library/Application Support/Vim'
  else
    if exists($XDG_DATA_HOME)
      let g:vim = $XDG_DATA_HOME . '/vim'
    else
      let g:vim = '~/.local/share/vim'
    endif
  endif
" }}}

"
" Functions
"

" Platform Functions {{{
  " Check if a directory is empty/does not exist.
  function! s:is_empty(dir)
    return empty(glob(expand(a:dir)))
  endfunction

  " Make sure a directory exists.
  function! s:mkdir_p(dir)
    let dir = expand(a:dir)

    if s:is_empty(dir) && !isdirectory(dir)
      try
        call mkdir(target, 'p')
      catch
        " On some platforms mkdir() does not exist.
        silent execute '!mkdir -p ' . dir
      endtry
    endif
  endfunction

  " Get the (platform dependant) cache location.
  function! s:cache_for(for)
    let dir = resolve(expand(g:vim . '/' . a:for))

    call s:mkdir_p(dir)
    return dir
  endfunction
" }}}

" Utility Functions {{{
  " Execute a command without moving or clobbering search.
  " Stolen from bling.vim <3
  function! Preserve(command)
    " Preserve the position and search.
    let old_search = @/
    let cursor_l = line('.')
    let cursor_c = col('.')

    " Do the dirty work.
    execute a:command

    " Restore the old data.
    let @/ = old_search
    call cursor(cursor_l, cursor_c)
  endfunction

  function! KillTrailingWhitespace()
      call Preserve('%s/\s\+$//e')
  endfunction
" }}}

"
" Plugins
"

" Set runtimepath.
silent execute 'set runtimepath+=' . g:vim

" Set paths.
let s:autoload   = s:cache_for('autoload')
let s:plug       = s:autoload . '/plug.vim'
let s:plug_cache = s:cache_for('plugged')

" Install vim-plug {{{
  " Clone vim-plug if we can.
  if s:is_empty(s:plug)
    silent execute '!curl -fLo ' . s:plug . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  endif
" }}}

" Run vim-plug {{{
  " Set defaults.
  set nocompatible

  " Load vim-plug.
  call plug#begin(s:plug_cache)
" }}}

  " Plugins {{{
    " Libraries {{{
      " Background and asynchronous process support.
      Plug 'Shougo/vimproc', { 'do': 'make' }
      " Async adapters for running Vim's compiler plugins, or arbitrary commands.
      Plug 'tpope/vim-dispatch'

      " Psuedo-command line support.
      Plug 'junegunn/vim-pseudocl'
      " Repeat support for arbitrary plugins.
      Plug 'tpope/vim-repeat'
      " A library for making text objects.
      Plug 'kana/vim-textobj-user'
    " }}}

    " Fixes/Tweaks {{{
      " Sane defaults.
      Plug 'tpope/vim-sensible'

      " Restore/preserve views.
      Plug 'kopischke/vim-stay'
      " More conservative fold updates.
      Plug 'Konfekt/FastFold'

      " Auto-detect indent settings.
      Plug 'tpope/vim-sleuth'
      " Auto detect the build command.
      Plug 'johnsyweb/vim-makeshift'
      " Open files to line:column.
      Plug 'kopischke/vim-fetch'

      " Close buffers without changing the layout.
      Plug 'moll/vim-bbye'
      " Use intuitive resize directions.
      Plug 'talek/obvious-resize'

      " Smooth scrolling.
      Plug 'terryma/vim-smooth-scroll'
      " Fix terminal key sequences.
      Plug 'drmikehenry/vim-fixkey'

      " Make Vim's build in character info command support more things.
      Plug 'tpope/vim-characterize'
    " }}}

    " Unite {{{
      " Unified fuzzy interface to any (implemented) source.
      Plug 'Shougo/unite.vim'

      Plug 'Shougo/unite-session'
      Plug 'Shougo/neomru.vim'
      Plug 'Shougo/unite-outline'
      Plug 'tsukkee/unite-tag'
      Plug 'thinca/vim-unite-history'
      Plug 'Shougo/unite-help'
" }}}

    " Editing {{{
      " Commentary adds key bindings to easily comment and uncomment code.
      Plug 'tpope/vim-commentary'
      " Align text with verbs!
      Plug 'junegunn/vim-easy-align'

      " Surround.vim adds support for manipulating the surroundings of a text object,
      " such as adding/removing quotes, replacing in brackets, and more.
      Plug 'tpope/vim-surround'
      " Automatically close quotes, parenthesis, braces, and other delimiters.
      Plug 'Raimondi/delimitMate'
      " Automatically end block constructs in supported languages.
      Plug 'tpope/vim-endwise'

      " Easy exchange operator.
      Plug 'tommcdo/vim-exchange'
      " Split and join statements intelligently.
      Plug 'AndrewRadev/splitjoin.vim'
      " Speeddating adds support for incrementing and decrementing dates.
      Plug 'tpope/vim-speeddating'
      " Handy bracket-prefixed pairs of mappings that @tpope finds useful.
      Plug 'tpope/vim-unimpaired'

      " Abolish brings bracket substitutions to Vim abbreviations, searches, and
      " substitutions.
      Plug 'tpope/vim-abolish'
    " }}}

    " Completion {{{
      " Completion engine supporting almost anything. Also it's fast.
      Plug 'Shougo/neocomplete.vim'

      " A powerful snippet engine, with support for nested snippets.
      Plug 'Shougo/neosnippet.vim'
      Plug 'Shougo/neosnippet-snippets'
      Plug 'honza/vim-snippets'
    " }}}

    " Support {{{
      " A powerful C/C++ completion enegine.
      Plug 'Rip-Rip/clang_complete', { 'for': ['c','cpp'], 'do': 'make' }
      " Tools for working with Go, and a powerful Go completion engine.
      Plug 'fatih/vim-go', { 'for': 'go' }
      " Tools for working with Node.js.
      Plug 'moll/vim-node', { 'for': 'javascript' }
      " Tools for working with Python.
      Plug 'klen/python-mode', { 'for': 'python' }
      " A powerful Python completion engine.
      Plug 'davidhalter/jedi-vim', { 'for': 'python', 'do': 'git submodule update --init --recursive' }
      " Tools for working with Ruby on Rails.
      Plug 'tpope/vim-rails', { 'for': 'ruby' }
      " A powerful Ruby completion engine.
      Plug 'supermomonga/neocomplete-rsense.vim', { 'for': 'ruby' }

      " A combination of common syntax and support files.
      Plug 'sheerun/vim-polyglot'
      " Syntax for Ansible YAML files.
      Plug 'chase/vim-ansible-yaml', { 'for':  'ansible' }
      " Syntax for BrightScript, the Roku programming language.
      Plug 'chooh/brightscript.vim'
      " Syntax for Fish, the Friendly Interactive SHell.
      Plug 'dag/vim-fish', { 'for': 'fish' }

      " Support for GnuPG/PGP-encrypted files.
      Plug 'jamessan/vim-gnupg'

      " Tools and syntax for working with the Git DVCS.
      Plug 'tpope/vim-fugitive'

      " NASM assembly language
      Plug 'helino/vim-nasm'
    " }}}


    " Movement {{{
     " Sneak is the missing motion(tm) for Vim.
      Plug 'justinmk/vim-sneak'
      " Movements to the end of a motions/text object.
      Plug 'tommcdo/vim-ninja-feet'
      " A better /...
      Plug 'junegunn/vim-oblique'
      " Simple, manual jump-stack.
      Plug 'tommcdo/vim-kangaroo'

      " Multiple cursors and selection.
      Plug 'terryma/vim-multiple-cursors'
      " Syntactically expand the selection.
      Plug 'terryma/vim-expand-region'

      " A collection of useful text objects (including 'remote' and
      " 'delimiter'-based objects).
      Plug 'wellle/targets.vim'
      " Text object for between two characters.
      Plug 'thinca/vim-textobj-between'
      " Text object for comments.
      Plug 'glts/vim-textobj-comment',
      " Text object for the current indent level.
      Plug 'kana/vim-textobj-indent'
      " Text object for the indent block (whitespace).
      Plug 'glts/vim-textobj-indblock'
      " Text object for the entire line.
      Plug 'kana/vim-textobj-line'
      " Text object for the entire file.
      Plug 'kana/vim-textobj-entire'
    " }}}

    " Navigation {{{
      " A file browser and sidebar for Vim.
      Plug 'Shougo/vimfiler'
      " A ctags browser as a sidebar.
      Plug 'majutsushi/tagbar'
      " A undo tree as a sidebar.
      Plug 'mbbill/undotree'

      " Quick access to a file browser.
      Plug 'tpope/vim-vinegar'

      " Various utilities for *nix (and maybe Windows) systems, such as renaming and
      " deleting files, or changing file permissions.
      Plug 'tpope/vim-eunuch'
    " }}}

    " UI {{{
      " A sweet, lightweight status bar.
      Plug 'bling/vim-airline'

      " Show markers for indents.
      Plug 'Yggdroot/indentLine'
      " Color parenthesis differently.
      Plug 'luochen1990/rainbow'

      " Signature.vim adds visual marks in the gutter, as well as shortcuts for
      " managing marks.
      Plug 'kshenoy/vim-signature'
      " Git diff in the gutter.
      Plug 'airblade/vim-gitgutter'
    " }}}
    
      " School {{{
      Plug 'vimwiki/vimwiki'
      Plug 'jtratner/vim-flavored-markdown'
    " }}}
      " IRC {{{
      Plug 'vim-scripts/VimIRC.vim'
    " }}}
    " Colors {{{
      " The best colorscheme, ever.
      Plug 'tomasr/molokai'
    " }}}

    " Unused {{{
    " }}}
  " }}}

" End vim-plug {{{
  call plug#end()
" }}}

"
" Settings
"

" Setup {{{
  " Set up and clear my autocmmand group.
  augroup vimrc
    autocmd!
  augroup end

  " Don't load a bunch of 'standard' plains.
  let g:loaded_netrwPlugin   = 1
  let g:loaded_2html_plugin  = 1
  let g:loaded_vimballPlugin = 1
" }}}

" Input {{{
  " Timeout {{{
    " Make escape/keybinds faster.
    set ttimeoutlen=50 timeoutlen=300
" }}}

  " Mouse {{{
    " Enable the mouse, but hide it when typing.
    set mouse=a mousehide
  " }}}

  " Keyboard {{{
    " Fix the Mac option key.
    if s:is_macvim
      set macmeta
    endif
  " }}}
" }}}

" Output {{{
  " Allow backgrounding buffers.
  set hidden

  " Assume a fast TTY.
  set ttyfast
" }}}

" Editing {{{
  " Search/Replace {{{
    " Enable escape characters.
    set magic
    " Show searches as they are typed.
    set hlsearch incsearch

    " Quick substitute.
    nnoremap <leader>s :%s/<c-r><c-w>//gc<left><left><left>
  " }}}

  " Selection {{{
    " Use the system clipboard.
      set clipboard=unnamedplus

    " Allow the cursor to go beyond the line and to make true blocks.
    set virtualedit+=all

    " Yank from cursor to end of line.
    nnoremap Y y$
    " Reselect pasted text in visual mode.
    nnoremap pv V`]
    vnoremap p p`]

    " Region expansion.
    vmap K <Plug>(expand_region_expand)
    vmap J <Plug>(expand_region_shrink)
  " }}}

  " Alignment {{{
    " Interactive alignment of text.
    nmap gl <Plug>(EasyAlign)
    vmap <Enter> <Plug>(EasyAlign)
  " }}]

  " Split/Join {{{
    " Use splitjoin
    nnoremap <silent> J :SplitjoinJoin<cr>
    nnoremap <silent> S :SplitjoinSplit<cr>
  " }}}

  " Indent {{{
    " Retain selection when indenting in Visual mode (sugar for gv).
    vnoremap < <gv
    vnoremap > >gv
  " }}}

  " Completion {{{
    " Enable automatically and at startup.
    let g:neocomplete#enable_at_startup = 1

    " Auto-select the first completion.
    let g:neocomplete#enable_auto_select = 1
    " Use smart-case.
    let g:neocomplete#enable_smart_case = 1
    " Require 3 characters to complete.
    let g:neocomplete#sources#syntax#min_keyword_length = 3

    " Buffers to not complete in.
    let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

    " Set up dicts.
    let g:neocomplete#keyword_patterns = {
          \ 'default': '\h\w*'
          \ }

    " Don't conflict with endwise.
    let g:endwise_no_mappings = 1

    function! s:tab()
      if neosnippet#jumpable()
        return "\<plug>(neosnippet_jump)"
      elseif pumvisible()
        return "\<c-n>"
      elseif neocomplete#complete_common_string() != ''
        return neocomplete#complete_common_string()
      else
        return "\<tab>"
      endif
    endfunction
    function! s:cr()
      if pumvisible()
        if neosnippet#expandable()
          return "\<plug>(neosnippet_expand)"
        else
          return neocomplete#close_popup()
        endif
      else
        return "\<cr>\<plug>DiscretionaryEnd"
      endif
    endfunction

    imap <expr> <cr> <sid>cr()
    imap <expr> <tab> <sid>tab()
    inoremap <expr> <esc> pumvisible() ? neocomplete#cancel_popup() : '<esc>'
    inoremap <expr> <c-c> pumvisible() ? neocomplete#cancel_popup() : '<c-c>'
    inoremap <expr> <c-f> neocomplete#complete_common_string()

    " Set up extra snippets.
    let g:neosnippet#enable_snipmate_compatibility = 1
    let g:neosnippet#snippets_directory = s:plug_cache . '/vim-snippets/snippets'

    " Set up filetype-specific options.
    let g:neocomplete#sources#omni#functions      = {}
    let g:neocomplete#sources#omni#input_patterns = {}
    let g:neocomplete#force_omni_input_patterns   = {}

    " C/C++ {{{
      " Set up neocomplete to use clang_complete.
      let g:neocomplete#force_omni_input_patterns.c =
            \ '[^.[:digit:] *\t]\%(\.\|->\)\w*'
      let g:neocomplete#force_omni_input_patterns.cpp =
            \ '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
      let g:neocomplete#force_omni_input_patterns.objc =
            \ '\[\h\w*\s\h\?\|\h\w*\%(\.\|->\)'
      let g:neocomplete#force_omni_input_patterns.objcpp =
            \ '\[\h\w*\s\h\?\|\h\w*\%(\.\|->\)\|\h\w*::\w*'

      " Tell clang_complete to not hijack neocomplete.
      let g:clang_default_keymappings = 0
      let g:clang_complete_auto       = 0
      let g:clang_auto_select         = 0
    " }}}

    " Go {{{
      " Set up neocomplete to use gocode.
      let g:neocomplete#sources#omni#functions.go      = 'go#complete#Complete'
      let g:neocomplete#sources#omni#input_patterns.go = '[^.[:digit:] *\t]\.\w*'
    " }}}

    " Python {{{
      " Set up neocomplete to use Jedi.
      let g:neocomplete#force_omni_input_patterns.python =
            \ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'

      " Override PythonComplete.
      autocmd vimrc FileType python setlocal omnifunc=jedi#completions
      " Disable Pymode Rope so Jedi doesn't have a fit.
      let g:pymode_rope = 0
      " Tame Jedi to not hijack neocomplete.
      let g:jedi#auto_vim_configuration = 0
      let g:jedi#completions_enabled    = 0

      " Use buffers and splits.
      let g:jedi#use_tabs_not_buffers   = 0
      let g:jedi#use_splits_not_buffers = "left"

      " Don't show call signatures.
      let g:jedi#show_call_signatures = 0
      " Don't show docstrings when completing.
      autocmd vimrc FileType python setlocal completeopt-=preview
    " }}}

    " Vim {{{
      " Make vim help work.
      autocmd vimrc FileType vim setlocal keywordprg=:help
    " }}}
  " }}}

 " Spelling {{{
    " Disable spell checking by default.
    set nospell spelllang=en
    " ...but start it on some filetypes.
    autocmd vimrc FileType gitcommit setlocal spell
    autocmd vimrc FileType markdown setlocal spell
    autocmd vimrc FileType text setlocal spell 
    autocmd vimrc FileType wiki setlocal spell
  " }}}
 
  " Case {{{
    " Ignore case when searching, unless a uppercase letter is present.
    set ignorecase smartcase
    " When completing infer case.
    set infercase
  " }}}

  " Wrapping {{{
    " Hard wrap at 80 characters by default.
    set textwidth=79
    " Wrap over lines.
    set whichwrap=h,l,<,>,[,],b,s
    set backspace=indent,eol,start

    " Move over virtual lines (wrapped lines).
    nnoremap j gj
    nnoremap k gk
  " }}}

  " Splits {{{
    " Open to the right.
    set splitright
    " Allow squishing splits.
    set winminheight=0

    " Resize intiuitively!
    noremap <silent> <c-w>+ :ObviousResizeUp<cr>
    noremap <silent> <c-w>- :ObviousResizeDown<cr>
    noremap <silent> <c-w>< :ObviousResizeLeft<cr>
    noremap <silent> <c-w>> :ObviousResizeRight<cr>
  " }}}
" }}}

  " Sneaking {{{
    " Enable streak (EasyMotion) mode.
    let g:sneak#streak = 1
    " Be clever: if I press s in a match, seek to the next match.
    let g:sneak#s_next = 1

    " Replace f with sneak.
    nmap f <Plug>Sneak_s
    nmap F <Plug>Sneak_S
    xmap f <Plug>Sneak_s
    xmap F <Plug>Sneak_S
    omap f <Plug>Sneak_s
    omap F <Plug>Sneak_S
    " Replace t with sneak.
    nmap t <Plug>Sneak_t
    nmap T <Plug>Sneak_T
    xmap t <Plug>Sneak_t
    xmap T <Plug>Sneak_T
    omap t <Plug>Sneak_t
    omap T <Plug>Sneak_T
  " }}}

  " Scrolling {{{
    noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<cr>
    noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<cr>
    noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<cr>
    noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<cr>
  " }}}

  " Jumping {{{
    nmap <tab> %
  " }}}
" }}}

" Navigation {{{
  " Unite {{{
    " Set the unite cache.
    let g:unite_data_directory      = s:cache_for('unite')
    " Set the neomru cache.
    let g:neomru#file_mru_path      = s:cache_for('unite/neomru') . '/file'
    let g:neomru#directory_mru_path = s:cache_for('unite/neomru') . '/directory'

    " Save sessions automatically.
    let g:unite_source_session_enable_auto_save = 1

    " Use the fuzzy matcher for everything
    call unite#filters#matcher_default#use(['matcher_fuzzy'])
    " Use the rank sorter for everything
    call unite#filters#sorter_default#use(['sorter_rank'])

    " Enable history yank source.
    let g:unite_source_history_yank_enable = 1

    " Grep with ag.
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--line-numbers --nocolor --nogroup --hidden'
    let g:unite_source_grep_recursive_opt = ''

    " Shorten the default update time of 500ms.
    let g:unite_update_time = 200

    " Use defaults like CtrlP.
    call unite#custom#profile('default', 'context', {
    \   'start_insert': 1,
    \   'direction': 'botright',
    \   'winheight': 10,
    \ })

    " Make the prompt nicer.
    let g:unite_prompt = '>>> '

    " Set Unite prefix.
    nnoremap [unite] <Nop>
    nmap <space> [unite]

    " General fuzzy finder.
    nnoremap <silent> [unite]<space> :Unite -buffer-name=fuzzy -no-split buffer bookmark file_mru file_rec/async:!<cr>
    " Quick access to buffers.
    nnoremap <silent> [unite]b :Unite -buffer-name=buffers -quick-match buffer<cr>
    " Quick access to commands.
    nnoremap <silent> [unite]c :Unite -buffer-name=commands command<cr>
    " Quick access to cd.
    nnoremap <silent> [unite]d :Unite -buffer-name=directories directory_mru directory_rec/async:!<cr>
    " Quick access to files.
    nnoremap <silent> [unite]f :Unite -buffer-name=files file_mru file_rec/async:!<cr>
    " Quick access to help.
    nnoremap <silent> [unite]h :Unite -buffer-name=help help<cr>
    " Quick access to includes.
    nnoremap <silent> [unite]i :Unite -buffer-name=include file_include<cr>
    " Quick access to bookmarks.
    nnoremap <silent> [unite]k :Unite -buffer-name=bookmarks bookmark<cr>
    " Quick access to lines.
    nnoremap <silent> [unite]l :Unite -buffer-name=line line<cr>
    " Quick access to MRU files.
    nnoremap <silent> [unite]m :Unite -buffer-name=mru file_mru<cr>
    " Quick access to new files.
    nnoremap <silent> [unite]n :Unite -buffer-name=new file/new<cr>
    " Quick access to an outline.
    nnoremap <silent> [unite]o :Unite -buffer-name=outline -vertical -auto-preview outline<cr>
    " Quick access to registers.
    nnoremap <silent> [unite]r :Unite -buffer-name=register register<cr>
    " Quick access to sessions.
    nnoremap <silent> [unite]s :Unite -buffer-name=sessions session<cr>
    " Quick access to tags.
    nnoremap <silent> [unite]t :Unite -buffer-name=tags -vertical -auto-preview tag/include<cr>
    " Quick access to sources.
    nnoremap <silent> [unite]u :Unite -buffer-name=sources source<cr>
    " Quick access to yanks.
    nnoremap <silent> [unite]y :Unite -buffer-name=yanks history/yank<cr>
    " Quick snippets.
    nnoremap <silent> [unite]<tab> :Unite -buffer-name=snippets neosnippet<cr>
    " Quick grep.
    nnoremap <silent> [unite]/ :Unite -buffer-name=grep grep:.<cr>
    " Quick find.
    nnoremap <silent> [unite]\ :Unite -buffer-name=find find:.<cr>

    " Load settings in Unite buffers.
    function! s:unite_settings()
      nnoremap <buffer> <esc> <plug>(unite_exit)
    endfunction
    autocmd vimrc FileType unite call s:unite_settings()
  " }}}

  " Grep {{{
    set grepprg=ag\ ---column\ --line-numbers\ --nocolor\ --nogroup
    set grepformat=%f:%l:%c%m
  " }}}

  " Files {{{
    " Use vimfiler instead of netrw.
    let g:vimfiler_as_default_explorer = 1
  " }}}

  " Syntax {{{
    " Turn on syntax highlighting.
    syntax on

    " Less annoying MatchParen.
    highlight MatchParen cterm=bold ctermbg=NONE ctermfg=NONE
    highlight MatchParen gui=bold guibg=NONE guifg=NONE

    " Enable rainbow delimiters!
     let g:rainbow_active = 1 
     let g:rainbow_conf = {
    \   'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
    \   'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
    \   'operators': '_,_',
    \   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
    \   'separately': {
    \       '*': {},
    \       'tex': {
    \           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
    \       },
    \       'lisp': {
    \           'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
    \       },
    \       'vim': {
    \           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
    \       },
    \       'html': {
    \           'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
    \       },
    \       'css': 0,
    \   }
    \}
  " }}}

  " Hidden {{{
    " Show hidden characters.
    set list
    " Totally conceal if no replacement exists, but in normal/command mode.
    set conceallevel=2 concealcursor=nc
  " }}}

  " Search {{{
    " Show matched characters.
    set showmatch
  " }}}

  " Folding {{{
    " Turn on folding based on syntax plugins.
    set foldenable foldmethod=syntax
    " ...and unfold when needed.
    set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo

    " Enable some syntax folding methods.
    let g:tex_fold_enabled=1
    let g:tex_conceal = ""
    let g:vimsyn_folding='af'
    let g:xml_syntax_folding = 1
    let g:php_folding = 1
    let g:perl_fold = 1
  " }}}

  " Wrapping {{{
    " Enable virtual wrapping, but only between words and only when out of room.
    set wrap linebreak wrapmargin=0
    " Wrap to the current indent level.
    set breakindent
  " }}}

  " Ruler {{{
    " Turn on line numbers.
    set number
  " }}}

  " Status Bar " {{{
    " Disable the built in mode indicator, and don't show the last command.
    set noshowmode noshowcmd
    "use pretty fonts
    let g:airline_powerline_fonts = 1
    if !exists('g:airline_symbols')
      let g:airline_symbols = {}
    endif
    " Enable some nice extensions.
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#whitespace#enabled = 1
  " Messages {{{
    " Turn off bells.
    set noerrorbells novisualbell
    " Use abbreviations and disable 'Press Enter to Continue' messages.
    set shortmess+=filmnrxoOtT
  " }}}

" Caches {{{
  " Use swapfiles, backups, and persist undo data.
  set swapfile backup undofile

  " Save the marks for the last 50 files, and 1000 register lines.
  set viminfo='50,<1000,h
  " Save 100 lines of command-line and search history.
  set history=100
  " Save view/session to view/session files.
  set viewoptions=cursor,folds,slash,unix
  set sessionoptions=curdir,folds,blank,buffers,tabpages,resize,winsize,winpos

  let &directory = s:cache_for('swap')
  let &backupdir = s:cache_for('backup')
  let &undodir   = s:cache_for('undo')
  let &viewdir   = s:cache_for('view')
" }}}

"some wiki stuff 
let wiki_settings={
            \ 'template_path': 'vimwiki-assets/',
            \ 'template_default': 'default',
            \ 'template_ext': '.html',
            \ 'auto_export': 0,
            \ 'nested_syntaxes': {
            \ 'js':'javascript' }}

command! -nargs=1 -range SuperRetab <line1>,<line2>s/\v%(^ *)@<= {<args>}/\t/g
 
command! -range=% -nargs=0 Tab2Space execute '<line1>,<line2>s#^\t\+#\=repeat(" ", len(submatch(0))*' . &ts . ')' 
command! -range=% -nargs=0 Space2Tab execute '<line1>,<line2>s#^\( \{'.&ts.'\}\)\+#\=repeat("\t", len(submatch(0))/' . &ts . ')'
 
" Allow :Wq and :W to do the same as :wq and :w respectively 
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))

" To open a new empty buffer
" This replaces :tabnew which I used to bind to this mapping
nmap <leader>T :enew<cr>

" Move to the next buffer
nmap <Tab> :bnext<CR>

" Move to the previous buffer
nmap <BS> :bprevious<CR>

" Close the current buffer and move to the previous one
" This replicates the idea of closing a tab
nmap <leader>bq :bp <BAR> bd #<CR>

" Show all open buffers and their status
nmap <leader>bl :ls<CR>

nmap + :VimFilerSplit<CR>

"color scheme
 colorscheme molokai

"utf8
set encoding=utf-8

autocmd Filetype java set makeprg=javac\ %
set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
map <F9> :make<Return>:copen<Return>
map <F10> :cprevious<Return>
map <F11> :cnext<Return>
