
" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2002 May 28
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc


" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

set nu
set softtabstop=4
set tabstop=4
set shiftwidth=4
set laststatus=2
set hlsearch

set autoindent		" always set autoindenting on

if v:progname =~? "vim"
	set mouse=
	"set foldcolumn=2
endif

let useplugin_acsb = 1
"let useplugin_vcscommand = 1

" no beep -> visualbell mode and no flash 
set vb t_vb=
set t_Co=16
set t_kb=

set encoding=utf-8

" color setting
colorscheme pablo
"colorscheme desert
"colorscheme molokai
"colorscheme elflord
"hi StatusLine ctermfg=4 ctermbg=0
"hi StatusLineNC ctermfg=7
"hi Search ctermfg=0 ctermbg=4
hi Folded ctermfg=8 ctermbg=0
hi FoldColumn cterm=bold ctermfg=8 ctermbg=0
"hi Error cterm=bold ctermbg=1 ctermfg=0
hi ErrorMsg cterm=bold ctermbg=1 ctermfg=4
"hi clear ModeMsg
"hi ModeMsg cterm=bold ctermfg=3
hi LineNr   ctermfg=darkgrey ctermbg=black
hi LineNr   term=underline ctermfg=3 ctermbg=0 guifg=Yellow
hi Normal   ctermfg=15
"hi Comment term=bold ctermfg=4


hi DiffAdd ctermfg=0
hi DiffDelete ctermfg=6
hi DiffChange ctermbg=8 ctermfg=7
"hi DiffText ctermbg=0

"hi Type ctermfg=6
"hi Statement ctermfg=4
"hi Comment ctermfg=2
"hi identifier ctermfg=2

" fold setting
set foldmethod=indent
"set foldmethod=marker
"set foldmarker={,}
set foldnestmax=9
set fillchars=vert:\|,fold:\ 
set foldtext=
"set foldtext='+--\ [\ '.(v:foldend-v:foldstart+1).'\ lines\ ]'

" my tools mapping
nmap <silent> <C-\><C-\>	:cs kill 0<CR>:!rm -f $CSCOPE_DB<CR>:make cscope<CR>:cs add $CSCOPE_DB<CR><CR>
nmap <silent> <C-\><C-\><C-\>	:cs kill 0<CR>:!rm -f cscope.out<CR>:!cscope -b -i cscope.files -f cscope.out<CR>:cs add cscope.out<CR><CR>
nmap <silent> <F5>		:Texplore<CR>
"nmap <silent> <F5>			:wa<CR>:make unittest<CR>
"nmap <silent> <F3>		:cp<CR>
"nmap <silent> <F4>		:cn<CR>
"nmap <F2>		:tabnew<SPACE>
"nmap <F13>		:tabnew<SPACE>
"nmap <F14>		:tabnew<SPACE>

"nmap [2;5~ <Esc>:tabe<SPACE>
"nmap [3;5~ <Esc>:tabc<CR>
"nmap <M-PageUp>		:tabprev<CR>
"nmap <M-PageDown>	:tabnext<CR>
nmap <F7>	:tabprev<CR>
nmap <F8> 	:tabnext<CR>

" alt+pageup
nmap [5;3~		:tabprev<CR>
" alt+pagedown
nmap [6;3~		:tabnext<CR>

"command SS call <SID>nl_ss()
nmap <silent> <F9>	:call SVN_modify_view()<CR>

let Tlist_GainFocus_On_ToggleOpen = 1
augroup VCSCommand
	"au VCSCommand User VCSBufferCreated silent! nmap <unique> <buffer> q :bwipeout<cr> 
	"au VCSCommand User VCSBufferCreated silent! nmap <unique> <buffer> q :VCSClearAndGotoOriginal <cr> 
	au VCSCommand User VCSBufferCreated silent! nmap <unique> <buffer> q :VCSGotoOriginal! <cr> 
augroup END

if 0
" VCScommand setting
let VCSCommandEnableBufferSetup = 1
let VCSCommandEdit = 'edit'
let VCSCommandDeleteOnHide = 1
"let VCSCommandSplit = 'vertical'
let Tlist_GainFocus_On_ToggleOpen = 1

" svncommand setting
"let SVNCommandNameResultBuffers=1

" cvscommand mapping
"let mapleader = '\'
"let CVSCommandEnableBufferSetup = 1
"set statusline=%<%f\ %{CVSGetStatusLine()}\ %h%m%r%=%l,%c%V\ %P
set statusline=%<%f\ %{VCSCommandGetStatusLine()}\ %h%m%r%=%-14.(%l,%c%V%)\ %P
"highlight StatusLine ctermfg=white ctermbg=black  	"status bar select line color 

" VCScommand setting
if exists('useplugin_vcscommand')
	" VCScommand setting
	let VCSCommandEnableBufferSetup = 1
	let VCSCommandEdit = 'edit'
	let VCSCommandDeleteOnHide = 1
	let VCSCommandMapPrefix = '<Leader>s'
	"let VCSCommandSplit = 'vertical'

	nnoremap <silent> <Plug>VCSDiffPrev :VCSDiff PREV COMMITTED<CR>

	let VCSCommandMappings = [
				\['a', 'VCSAdd'],
				\['c', 'VCSCommit'],
				\['d', 'VCSDiff'],
				\['D', 'VCSDiffPrev'],
				\['g', 'VCSGotoOriginal'],
				\['i', 'VCSInfo'],
				\['l', 'VCSLog'],
				\['n', 'VCSAnnotate'],
				\['r', 'VCSReview'],
				\['s', 'VCSStatus'],
				\['u', 'VCSUpdate'],
				\['v', 'VCSVimDiff'],
				\]

	augroup VCSCommand
		"au VCSCommand User VCSBufferCreated silent! nmap <unique> <buffer> q :bwipeout<cr> 
		"au VCSCommand User VCSBufferCreated silent! nmap <unique> <buffer> q :VCSClearAndGotoOriginal <cr> 
		au VCSCommand User VCSBufferCreated silent! nmap <unique> <buffer> q :VCSGotoOriginal! <cr> 
	augroup END

	set statusline=%<%f\ %{VCSCommandGetStatusLine()}\ %h%m%r%=%-14.(%l,%c%V%)\ %P
endif
endif

" taglist mapping...
nmap <silent> <Leader>=		:Tlist<CR>
let Tlist_Show_One_File=1
let Tlist_WinWidth=45
let Tlist_Exit_OnlyWindow=1
let Tlist_Use_Right_Window=1

" project mapping
nmap <silent> <Leader>P		:Project<CR>
nmap <silent> <Leader>\		<Plug>ToggleProject
let g:proj_window_width=100
let g:proj_flags="imstc"
let g:proj_run1=""


" DoxygenToolkit setting
nmap <silent> <Leader>d			:Dox<CR>
let g:DoxygenToolkit_authorName = "dgkim <dgkim@mantech.co.kr>"
let g:DoxygenToolkit_briefTag_funcName = "yes"



" allow backspacing over everything in insert mode
set backspace=indent,eol,start

"if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
"else
"  set backup		" keep a backup file
"endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
"if &t_Co > 2 || has("gui_running")
"  syntax on
"  set hlsearch
"endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  "autocmd BufReadPost *
  "  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  "  \   exe "normal g`\"" |
  "  \ endif

  au BufNewFile,BufRead  TODO*	setf todo | setlocal foldmethod=indent | setlocal ts=2 sts=2 sw=2

  "au BufNewFile,BufRead  svn-commit.* setf svn
  "au BufNewFile,BufRead  svn-log.* setf svn

endif " has("autocmd")
