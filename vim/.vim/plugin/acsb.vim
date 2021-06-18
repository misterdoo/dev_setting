" Plugin: acsb.vim --- Buffered frontend for CScope
" 
" License:
"   This program is free software; you can redistribute it and/or modify 
"   it under the terms of the GNU General Public License as published by
"   the Free Software Foundation; either version 2 of the License, or 
"   (at your option) any later version. 
"
" Version: 20050501-2
"
" Changelog:
" 2005.05.01-2
" 	o bugfix: removed bad reference to old stack jumping
" 	  function
" 	o bugfix: adjust stack on query deletion
" 	o Text message modifictaions
" 	o Allow to show the ACSB buffers from each other
" 
" Author: Gabor Fekete
" Date: 2005.04.29, Fri
" Email: mocsok@loveable.com
" 
" Description:
" It is a script to interface with cscope.
"
" Features:
" o Multi queries
"   It uses a buffer for listing the results of cscope queries.
" o Multi tag stacks
"   Supports multiple tag stacks for serious code analyzis.
"   The stacks are shown in a buffer.
"
" It can be used parallel with the normal cscope frontend of
" vim because they use different settings, key bindings and
" tag stacks.
" 
" Installation:
" Copy this file into ~/.vim/plugins/
"
" Usage:
" Set up a cscope connection (e.g. with autoload_cscope.vim ;))
"
" Keybindings: The 'symbol' is the word under the cursor.
" You may change these bindings below in this script.
" Ctrl+F1 - Find symbol definition
" Ctrl+F2 - Find functions called by the symbol
" Ctrl+F3 - Find functions calling the symbol
" Ctrl+F4 - Find symbol as text
" Ctrl+F6 - Find symbol as egrep pattern
" Ctrl+F7 - Find symbol as a file
" Ctrl+F8 - Find files including symbol
" Alt+Left - Jump to the previous tag in the tag stack
" Alt+Right - Jump to a most recent tag in the tag stack
" Ctrl+Down - Jump to the next result in the active query
" Ctrl+Up - Jump to the previous result in the active query
"
" Ctrl+q - All query results are put into the [ACSB] buffer.
" If a query results in more than one matches then the [ACSB] buffer
" is shown automatically.
" Keybindings for the [ACSB] buffer:
" d - delete query
" ENTER - jump to query result
" z - open/close fold
" Z - open close all folds
" q - close [ACSB] buffer
" Ctrl+q - close [ACSB] buffer
"
" Ctrl+p - Show the tag stacks
" Keybinsings for the [ACSB-Stacks] buffer:
" d - delete stack
" n - create a new empty stack
" N - create a new named empty stack
" a - make stack the active one
" ENTER - make stack the active one and position the stack pointer
"         to the selected entry.
" z - open/close fold
" Z - open close all folds
" q - close [ACSB-Stacks] buffer
" Ctrl+p - close [ACSB-Stacks] buffer
"
" If a query results in only one match then the [ACSB] buffer is not
" shown and the result is immediately jumped at.
"
" LIMITATIONS:
" o It allows to use only one cscope connection.
" o The syntax highlighting of the [ACSB] and [ACSB-Stacks] buffers
"   is broken.
" o The cscope database MUST be named as 'cscope.out'.
" If you fix these, please send me the result or upload it to
" somewhere because I am interested.
"
" Credits:
" I would like to thank the ideas these people gave me through their
" scripts:
" o Michael Conrad Tilsra, autoload_cscope.vim
" o Jeff Lanzarotta, bufexplorer.vim
" o Shivakumar T, cscope_win.vim
"
" For coders:
" s:acsb_qrescnt_{i} = the number of results belonging to the ith query
" s:acsb_qres_{i}_{j}_1 = The file name of the query result belonging to
"                        the jth result of the ith query.
"                   _2 = The function name
"                   _3 = The line number
"                   _4 = Line contents
" 

let g:acsb_cscope_dir = ""

let s:acsb_using_differnt_srcdir = ""

let s:acsb_query_cnt = 0	" Number of queries.
let s:acsb_active_query = 0	" Queries are numbered from one.
let s:acsb_active_qres = 0

let s:acsb_stack_cnt = 1	" There is always at least 1 stack.
let s:acsb_active_stack = 0	" Stacks are numbered from zero.
let s:acsb_stack_0_top = 0
let s:acsb_stack_0_end = -1	" points at the real item in the top of the stack
let s:acsb_stack_0_name = "anonymous"

let s:acsb_shown = 0		" 1 == either [ACSB] or [ACSB-Stack] is active.
let s:acsb_csres_pattern = "/\=\f "
let s:acsb_prevbuff = 0		" Buffer # of the text buffer before showing [ACSB].
let s:acsb_foldopen = 0		" 1 == there are open folds in [ACSB].

command! -nargs=* ACSBfindsym call ACSB_find_symbol(<f-args>)
if !exists(":ACSBQueries")
  command ACSBQueries keepjumps :call <SID>ACSB_showBuff(0, 0)
endif
if !exists(":ACSBStacks")
  command ACSBStacks keepjumps :call <SID>ACSB_showStackBuff(-1, -1)
endif
if !exists(":ACSBNewStack")
  command -nargs=1 ACSBNewStack keepjumps :call <SID>ACSB_newStack(<f-args>)
endif

" Key bindings ------ CHANGE these to fit your needs --------
"noremap <S-F1> :ACSBfindsym 1 <c-r>=expand("<cword>")<CR>
noremap <C-]> :ACSBfindsym def <c-r>=expand("<cword>")<CR><cr>
noremap <C-\>s :ACSBfindsym ref <c-r>=expand("<cword>")<CR><CR>
noremap <C-\>g :ACSBfindsym def <c-r>=expand("<cword>")<cr><CR>
noremap <C-\>d :ACSBfindsym called <c-r>=expand("<cword>")<cr><CR>
noremap <C-\>c :ACSBfindsym caller <c-r>=expand("<cword>")<cr><CR>
noremap <C-\>t :ACSBfindsym txt <c-r>=expand("<cword>")<cr><CR>
noremap <C-\>e :ACSBfindsym grep <c-r>=expand("<cword>")<cr><CR>
noremap <C-\>f :ACSBfindsym file <c-r>=expand("<cword>")<cr><CR>
noremap <C-\>i :ACSBfindsym inc <c-r>=expand("<cword>")<cr><CR>

noremap <C-Left> :call ACSB_stack_jump(-1)<cr>
noremap <C-Right> :call ACSB_stack_jump(1)<cr>
"noremap <C-Up> :call ACSB_stack_jump(-1)<cr>
"noremap <C-Down> :call ACSB_stack_jump(1)<cr>
"noremap <C-T> :call ACSB_stack_jump(-1)<cr>
map <silent> <C-O> :ACSBQueries<cr>
"imap <silent> <C-\>q <ESC>:ACSBQueries<cr>
"noremap <C-Up> :call <SID>ACSB_iterateQResult(-1)<cr>
"noremap <C-Down> :call <SID>ACSB_iterateQResult(1)<cr>
map <silent> <C-P> :ACSBStacks<cr>
"imap <silent> <C-P> <ESC>:ACSBStacks<cr>
" -----------------------------------------------------------

function! <SID>ACSB_iterateQResult(dir)
	if s:acsb_shown == 1
		echo "Command not supported in this buffer."
		return
	endif
	if s:acsb_query_cnt == 0
		return
	endif
	if s:acsb_active_query == 0
		let s:acsb_active_query = s:acsb_query_cnt
		let s:acsb_active_qres = 0
	endif

	let aq = s:acsb_active_query
	let aqr = s:acsb_active_qres
	
	let aqr = aqr + a:dir
	if aqr > s:acsb_qrescnt_{aq}
		echo "Last entry reached. No more entries for this query!"
		return
	endif
	if aqr < 1
		echo "First entry reached. No more entries for this query!"
		return
	endif
	
	call <SID>ACSB_goto(aq, aqr)
endfunction

function! <SID>ACSB_delquery()
	let pos = line('.')
	let cntr = 0
	let i1 = 1
	while i1 <= s:acsb_query_cnt
		let cntr = cntr + 1
		if cntr == pos
			call s:ACSB_delquery_by_index(i1, pos)
			return
		endif
		let i2 = 1
		while i2 <= s:acsb_qrescnt_{i1}
			let cntr = cntr + 1
			if cntr == pos
				call s:ACSB_delquery_by_index(i1, pos - i2)
				return
			endif
			let i2 = i2 + 1
		endwhile
		let i1 = i1 + 1
	endwhile
endfunction

" After the deletion of a query the stack elements must be readjusted to refer
" to the proper queries.
function! s:ACSB_adjustStack(q)
	let ii = 0
	while ii < s:acsb_stack_cnt
		let jj = 0
		while jj <= s:acsb_stack_{ii}_end
			if s:acsb_stack_{ii}_{jj}_3 == a:q
				let s:acsb_stack_{ii}_{jj}_3 = 0
				let s:acsb_stack_{ii}_{jj}_4 = 0
			elseif s:acsb_stack_{ii}_{jj}_3 > a:q
				let s:acsb_stack_{ii}_{jj}_3 = s:acsb_stack_{ii}_{jj}_3 - 1
			endif
			let jj = jj + 1
		endwhile
		let ii = ii + 1
	endwhile
endfunction

function! s:ACSB_delquery_by_index(qindx, delfrom)
	" pull qres ii+1 over ii
	let ii = a:qindx + 1
	let delnum = s:acsb_qrescnt_{a:qindx} + 1
	while ii <= s:acsb_query_cnt
		let jj = 1
		while jj <= s:acsb_qrescnt_{ii}
			let s:acsb_qres_{ii-1}_{jj}_1 = s:acsb_qres_{ii}_{jj}_1
			let s:acsb_qres_{ii-1}_{jj}_2 = s:acsb_qres_{ii}_{jj}_2
			let s:acsb_qres_{ii-1}_{jj}_3 = s:acsb_qres_{ii}_{jj}_3
			let s:acsb_qres_{ii-1}_{jj}_4 = s:acsb_qres_{ii}_{jj}_4
			unlet s:acsb_qres_{ii}_{jj}_1
			unlet s:acsb_qres_{ii}_{jj}_2
			unlet s:acsb_qres_{ii}_{jj}_3
			unlet s:acsb_qres_{ii}_{jj}_4
			let jj = jj + 1
		endwhile
		" Pull qrescnt
		let s:acsb_qrescnt_{ii-1} = s:acsb_qrescnt_{ii}
		" Pull queryname
		let s:acsb_queryname_{ii-1} = s:acsb_queryname_{ii}
		let ii = ii + 1
	endwhile
	" Unlet unused (last) entries.
	unlet s:acsb_qrescnt_{ii-1}
	unlet s:acsb_queryname_{ii-1}
	let s:acsb_query_cnt = s:acsb_query_cnt - 1
	" Delete text from the [ACSB] buffer
	"setlocal modifiable
	"exec a:delfrom . 'delete' . delnum
	if s:acsb_query_cnt == 0
		let s:acsb_active_query = 0
		let s:acsb_active_qres = 0
	endif
	if s:acsb_active_query == a:qindx
		let s:acsb_active_qres = 1
	endif
	if s:acsb_active_query > s:acsb_query_cnt
		let s:acsb_active_query = s:acsb_query_cnt
	endif
	call s:ACSB_adjustStack(a:qindx)
	call <SID>ACSB_quitBuff()
	call <SID>ACSB_showBuff(0, 0)
	"setlocal nomodifiable
endfunction

function! s:ACSB_adjustActiveQuery(s, se)
	" The query referred to by the stack entry may have been deleted.
	" Do not change to it if it is deleted.
	if s:acsb_stack_{a:s}_{a:se}_3 <= s:acsb_query_cnt
		let s:acsb_active_query = s:acsb_stack_{a:s}_{a:se}_3
		let s:acsb_active_qres = s:acsb_stack_{a:s}_{a:se}_4
	endif
endfunction

function! ACSB_stack_jump(dir)
	if s:acsb_shown == 1
		echo "Command not supported in this buffer."
		return
	endif
	let s = s:acsb_active_stack
	if a:dir == 1
		if s:acsb_stack_{s}_top == s:acsb_stack_{s}_end || s:acsb_stack_{s}_end == -1
			echo "Top reached of stack " . s . "-" . s:acsb_stack_{s}_name
			return
		endif
	elseif a:dir == -1
		if s:acsb_stack_{s}_top == 0
			echo "Bottom reached of stack " . s . "-" . s:acsb_stack_{s}_name
			return
		endif
	endif
	
	let s:acsb_stack_{s}_top = s:acsb_stack_{s}_top + a:dir
	exe "edit " . s:acsb_stack_{s}_{s:acsb_stack_{s}_top}_1
	exe s:acsb_stack_{s}_{s:acsb_stack_{s}_top}_2
	call s:ACSB_adjustActiveQuery(s, s:acsb_stack_{s}_top)
	let s:acsb_shown = 0
endfunction

" Jumps at a query result.
" Opens the file to edit and jumps at the proper line.
"
" The [ACSB] buffer must be the active one when calling
" this function!
function! s:ACSB_resultSelected()
	if s:acsb_query_cnt == 0
		return
	endif
	
	let pos = line('.')
	let cntr = 0
	let i1 = 1
	while i1 <= s:acsb_query_cnt
		let cntr = cntr + 1
		if cntr == pos
			return
		endif
		let i2 = 1
		while i2 <= s:acsb_qrescnt_{i1}
			let cntr = cntr + 1
			if cntr == pos
				" Switch back to the previous buffer
				call <SID>ACSB_quitBuff()
				call s:ACSB_goto(i1, i2)
				return
			endif
			let i2 = i2 + 1
		endwhile
		let i1 = i1 + 1
	endwhile
endfunction

function! s:ACSB_goto(qindx, qresindx)
	let s = s:acsb_active_stack
	" remember the current file and pos
	let s:acsb_stack_{s}_{s:acsb_stack_{s}_top}_1 = expand("%:p")
	let s:acsb_stack_{s}_{s:acsb_stack_{s}_top}_2 = line('.')
	let s:acsb_stack_{s}_{s:acsb_stack_{s}_top}_3 = s:acsb_active_query
	let s:acsb_stack_{s}_{s:acsb_stack_{s}_top}_4 = s:acsb_active_qres
	let s:acsb_stack_{s}_top = s:acsb_stack_{s}_top + 1
	if s:acsb_stack_{s}_top > s:acsb_stack_{s}_end
		let s:acsb_stack_{s}_end = s:acsb_stack_{s}_top
	endif
	
	" [open the file and] goto the line number
	let s:acsb_active_query = a:qindx
	let s:acsb_active_qres = a:qresindx
	let fname = s:acsb_qres_{a:qindx}_{a:qresindx}_1

	if match(fname, "/") != 0
		" if fname is relative then make it absolute
		if s:acsb_using_differnt_srcdir != ""
			let fname = s:acsb_using_differnt_srcdir . fname
		else
			let fname = g:acsb_cscope_dir . fname
		endif
	endif
	exec 'edit ' . fname
	exec s:acsb_qres_{a:qindx}_{a:qresindx}_3
	let s:acsb_shown = 0
	
	" remember the target
	let s:acsb_stack_{s}_{s:acsb_stack_{s}_top}_1 = expand("%:p")
	let s:acsb_stack_{s}_{s:acsb_stack_{s}_top}_2 = line('.')
	let s:acsb_stack_{s}_{s:acsb_stack_{s}_top}_3 = a:qindx
	let s:acsb_stack_{s}_{s:acsb_stack_{s}_top}_4 = a:qresindx
endfunction

" Parses the output of cscope
function! s:ACSB_parse_res(res, qidx)
	let cmd_output = a:res
	"if cmd_output ~= 'cscope: 0 lines'
	"	return 0
	"endif
	" parse line-by-line
	let i = 0
	while cmd_output != ''
		" Extract one line at a time
		let one_line = strpart(cmd_output, 0, stridx(cmd_output, "\n"))
		" Remove the line from the output
		let cmd_output = strpart(cmd_output, stridx(cmd_output, "\n") + 1)
		"if one_line ~= '^cscope:'
			" skip this informational line
		"	continue
		"endif
		let i = i + 1
		let jj = 1
		" A result consists of 3 parts: file name, function name,
		" line number, context.
		while jj <= 3
			let tmp = strpart(one_line, 0, stridx(one_line, " "))
			"if jj == 1 && s:acsb_using_differnt_srcdir != ""
			if jj == 1
				let tmp = substitute(tmp, s:acsb_using_differnt_srcdir, "", "")
				"let tmp = s:acsb_using_differnt_srcdir 
			endif
			let s:acsb_qres_{a:qidx}_{i}_{jj} = tmp
			"let s:acsb_qres_{a:qidx}_{i}_{jj} = strpart(one_line, 0, stridx(one_line, " "))
			let one_line = strpart(one_line, stridx(one_line, " ") + 1)
			let jj = jj + 1
		endwhile
		let s:acsb_qres_{a:qidx}_{i}_{jj} = one_line
	endwhile
	return i
endfunction

function! <SID>ACSB_quitBuff()
	exec "b!" . s:acsb_prevbuff
	let s:acsb_shown = 0
endfunction

function! <SID>ACSB_toggleFolds()
	if s:acsb_foldopen == 0
		exe "0,$foldopen!"
		let s:acsb_foldopen = 1
	else
		exe "0,$foldclose!"
		let s:acsb_foldopen = 0
	endif
endfunction

function! <SID>ACSB_showBuff(q, qr)
	" Save the current buffer only if neither [ACSB] nor [ACSB-Stack] is
	" shown.
	if s:acsb_shown == 0
		let s:acsb_prevbuff = bufnr("%")
	endif
	let qidx = a:q
	let qridx = a:qr
	if a:q == 0
		let qidx = s:acsb_active_query
		let qridx = s:acsb_active_qres
	endif


	if has("win32")
		exe "silent! e [ACSB]"
	else
		exe "silent! e \[ACSB\]"
	endif

	setlocal bufhidden=delete
	setlocal buftype=nofile
	setlocal modifiable
	setlocal noswapfile
	setlocal nowrap

	if has('syntax')
		syntax match QResTitle '^\S\+\s\+\S\+' 
		syntax keyword QResActive ACTIVE

		"syntax match QResFuncName '^\s\+\f\+\s\+\zs\i\+\ze'
		syntax match QResLineNum  '\d\+' contained
		syntax match QResFuncName '\S\+' contained nextgroup=QResLineNum skipwhite
		syntax match QResFileName '^\s\+\zs\S\+\ze' contained nextgroup=QResFuncName skipwhite
		syntax match QResHead     '^\s\+\S\+\s\+\S\+\s\+\d\+' contains=QResFileName,QResFuncName,QResLineNum
		"syntax match QResLineNum '\s\+[1-9][0-9]*\s\+'
		"syntax match QResLineNum '^\(\s\+\S\+\)\{2}\s\+\zs\S\+\ze'

		" Define the highlighting only if colors are supported
		if has('gui_running') || &t_Co > 2
			highlight clear QResTitle
			highlight link QResTitle string
			highlight clear QResActive
			highlight link QResActive keyword
			highlight clear QResFileName
			highlight link QResFileName type
			highlight clear QResFuncName
			highlight link QResFuncName string
			highlight clear QResLineNum
			highlight link QResLineNum keyword
		else
			highlight QResActive term=reverse cterm=reverse
		endif
	endif
	
	exe '0,$delete'

	" Populate the [ACSB] buffer
	let putcurhere = 1
	if s:acsb_query_cnt == 0
		call append(0, "There are no queries.")
	else
		let i1 = 1
		let lnum = 0
		while i1 <= s:acsb_query_cnt
			let line = s:acsb_queryname_{i1} . " results=" . s:acsb_qrescnt_{i1}
			if i1 == s:acsb_active_query
				let line = line . " <ACTIVE> (file, func, line #, line)"
			endif
			call append(lnum, line)
			let lnum = lnum + 1
			let i2 = 1
			while i2 <= s:acsb_qrescnt_{i1}
				if i1 == qidx
					if i2 == qridx
						let putcurhere = lnum + 1
					endif
				endif
				let i3 = 1
				let line = "\t"
				while i3 <= 4
					let line = line . s:acsb_qres_{i1}_{i2}_{i3} . "\t"
					let i3 = i3 + 1
				endwhile
				call append(lnum, line)
				let lnum = lnum + 1
				let i2 = i2 + 1
			endwhile
			let i1 = i1 + 1
		endwhile
	endif
	
	" Folding setup must be done here, otherwise it does not work. (?)
	setlocal foldenable
	setlocal foldmethod=indent
	let s:acsb_foldopen = 1

	" Put the cursor on the active query result and open its fold
	exec putcurhere
	exec "silent! normal zo"
	
	" Key bindings. MUST be here, otherwise the previous fold
	" opening does not work.
	nnoremap <buffer> <silent> Z :call <SID>ACSB_toggleFolds()<cr>
	nnoremap <buffer> <silent> z zA
	nnoremap <buffer> <silent> q :call <SID>ACSB_quitBuff()<cr>
	nnoremap <buffer> <silent> <C-O> :call <SID>ACSB_quitBuff()<cr>
	nnoremap <buffer> <silent> d :call <SID>ACSB_delquery()<cr>
	nnoremap <buffer> <silent> <CR> :call <SID>ACSB_resultSelected()<CR>
	setlocal nomodifiable
	let s:acsb_shown = 1
endfunction

function! s:ACSB_gotoStack(s, se)
	let s:acsb_active_stack = a:s
	let s:acsb_stack_{a:s}_top = a:se
	exe "edit " . s:acsb_stack_{a:s}_{a:se}_1
	exe s:acsb_stack_{a:s}_{a:se}_2
	call s:ACSB_adjustActiveQuery(a:s, a:se)
endfunction

function! s:ACSB_stack_selectEntry(s, se)
	" Switch back to the previous buffer
	call <SID>ACSB_quitBuff()
	call s:ACSB_gotoStack(a:s, a:se)
endfunction

function! s:ACSB_doActivateStack(stack)
	" Switch back to the previous buffer
	call <SID>ACSB_quitBuff()
	let s:acsb_active_stack = a:stack
	call <SID>ACSB_showStackBuff(-1, -1)
endfunction

function! s:ACSB_delstack_by_index(s)
	if s:acsb_stack_cnt == 1
		return
	endif
	" pull stack ii+1 over ii
	let ii = a:s + 1
	while ii < s:acsb_stack_cnt
		let jj = 0
		while jj <= s:acsb_stack_{ii}_end
			let s:acsb_stack_{ii-1}_{jj}_1 = s:acsb_stack_{ii}_{jj}_1
			let s:acsb_stack_{ii-1}_{jj}_2 = s:acsb_stack_{ii}_{jj}_2
			let s:acsb_stack_{ii-1}_{jj}_3 = s:acsb_stack_{ii}_{jj}_3
			let s:acsb_stack_{ii-1}_{jj}_4 = s:acsb_stack_{ii}_{jj}_4
			unlet s:acsb_stack_{ii}_{jj}_1
			unlet s:acsb_stack_{ii}_{jj}_2
			unlet s:acsb_stack_{ii}_{jj}_3
			unlet s:acsb_stack_{ii}_{jj}_4
			let jj = jj + 1
		endwhile
		let s:acsb_stack_{ii-1}_top = s:acsb_stack_{ii}_top
		let s:acsb_stack_{ii-1}_end = s:acsb_stack_{ii}_end
		let s:acsb_stack_{ii-1}_name = s:acsb_stack_{ii}_name
		let ii = ii + 1
	endwhile
	" Unlet unused (last) entries.
	unlet s:acsb_stack_{ii-1}_top
	unlet s:acsb_stack_{ii-1}_end
	unlet s:acsb_stack_{ii-1}_name
	let s:acsb_stack_cnt = s:acsb_stack_cnt - 1
	if s:acsb_active_stack >= s:acsb_stack_cnt
		let s:acsb_active_stack = s:acsb_stack_cnt - 1
	endif
	call <SID>ACSB_quitBuff()
	call <SID>ACSB_showStackBuff(-1, -1)
endfunction

function! <SID>ACSB_stackOperation(op)
	if s:acsb_stack_cnt == 0
		return
	endif
	
	let pos = line('.')
	let cntr = 0
	let i1 = 0
	while i1 < s:acsb_stack_cnt
		let cntr = cntr + 1
		if cntr == pos
			if a:op == 1
				call s:ACSB_doActivateStack(i1)
			elseif a:op == 2
				call s:ACSB_delstack_by_index(i1)
			endif
			return
		endif
		let i2 = 0
		while i2 <= s:acsb_stack_{i1}_end
			let cntr = cntr + 1
			if cntr == pos
				if a:op == 1
					call s:ACSB_doActivateStack(i1)
				elseif a:op == 2
					call s:ACSB_delstack_by_index(i1)
				elseif a:op == 3
					call s:ACSB_stack_selectEntry(i1, i2)
				endif
				return
			endif
			let i2 = i2 + 1
		endwhile
		if s:acsb_stack_{i1}_end == -1
			let cntr = cntr + 1
			if cntr == pos
				if a:op == 1
					call s:ACSB_doActivateStack(i1)
				elseif a:op == 2
					call s:ACSB_delstack_by_index(i1)
				endif
				return
			endif
		endif
		let i1 = i1 + 1
	endwhile
endfunction

" Create a new stack.
function! <SID>ACSB_newStack(name)
	call <SID>ACSB_quitBuff()
	let s = s:acsb_stack_cnt
	let s:acsb_stack_{s}_top = 0
	let s:acsb_stack_{s}_end = -1
	let s:acsb_stack_{s}_name = a:name
	let s:acsb_stack_cnt = s:acsb_stack_cnt + 1
	call <SID>ACSB_showStackBuff(-1, -1)
endfunction

function! <SID>ACSB_showStackBuff(s, se)
	" Save the current buffer only if neither [ACSB] nor [ACSB-Stack] is
	" shown.
	if s:acsb_shown == 0
		let s:acsb_prevbuff = bufnr("%")
	endif
	if a:s == -1
		let sidx = s:acsb_active_stack
	elseif
		let sidx = a:s
	endif
	let seidx = s:acsb_stack_{sidx}_top

	if has("win32")
		exe "silent! e [ACSB-Stack]"
	else
		exe "silent! e \[ACSB-Stack\]"
	endif

	setlocal bufhidden=delete
	setlocal buftype=nofile
	setlocal modifiable
	setlocal noswapfile
	setlocal nowrap

	if has('syntax')
		syntax match QResLineNum '\s\+[1-9][0-9]*\s\+'
		syntax keyword QResTitle Results for
		syntax keyword QResTitle ACTIVE
		syntax match QResFileName '\s\+\f\+\s\+'
		syntax match QResFuncName '\s\+\I\+\i*\s\+'

		" Define the highlighting only if colors are supported
		if has('gui_running') || &t_Co > 2
			highlight clear QResLineNum
			highlight link QResLineNum keyword
			highlight clear QResFuncName
			highlight link QResFuncName string
			highlight clear QResTitle
			highlight link QResTitle keyword
			highlight clear QResFileName
			highlight link QResFileName type
		else
			highlight QResActive term=reverse cterm=reverse
		endif
	endif
	
	exe '0,$delete'

	" Populate the [ACSB-Stack] buffer
	let putcurhere = 1
	let i1 = 0
	let lnum = 0
	while i1 < s:acsb_stack_cnt
		let line = i1 . ". " . s:acsb_stack_{i1}_name . " stack"
		if i1 == s:acsb_active_stack
			let line = line . " <ACTIVE> (file, line #, query, query-item, line)"
		endif
		call append(lnum, line)
		let lnum = lnum + 1
		if s:acsb_stack_{i1}_end == -1
			call append(lnum, "	Empty.")
			let lnum = lnum + 1
			if i1 == sidx
				let putcurhere = lnum
			endif
		else
			let i2 = 0
			while i2 <= s:acsb_stack_{i1}_end
				let i3 = 1
				let line = "\t"
				while i3 <= 4
					let line = line . s:acsb_stack_{i1}_{i2}_{i3} . "\t"
					let i3 = i3 + 1
				endwhile
				" acsb_qres_*_0_4 never exists, so, be silent
				" when that's hit.
				silent! let line = line . s:acsb_qres_{s:acsb_stack_{i1}_{i2}_3}_{s:acsb_stack_{i1}_{i2}_4}_4
				call append(lnum, line)
				let lnum = lnum + 1
				if i1 == sidx
					if i2 == seidx
						let putcurhere = lnum
					endif
				endif
				let i2 = i2 + 1
			endwhile
		endif
		let i1 = i1 + 1
	endwhile
	
	" Folding setup must be done here, otherwise it does not work. (?)
	setlocal foldenable
	setlocal foldmethod=indent
	let s:acsb_foldopen = 1

	" Put the cursor on the active query result and open its fold
	exec putcurhere
	exec "silent! normal zo"
	
	" Key bindings. MUST be here, otherwise the previous fold
	" opening does not work.
	nnoremap <buffer> <silent> Z :call <SID>ACSB_toggleFolds()<cr>
	nnoremap <buffer> <silent> z zA
	nnoremap <buffer> <silent> q :call <SID>ACSB_quitBuff()<cr>
	nnoremap <buffer> <silent> <C-p> :call <SID>ACSB_quitBuff()<cr>
	nnoremap <buffer> <silent> d :call <SID>ACSB_stackOperation(2)<cr>
	nnoremap <buffer> <silent> <CR> :call <SID>ACSB_stackOperation(3)<CR>
	nnoremap <buffer> <silent> n :call <SID>ACSB_newStack("anonymous")<cr>
	nnoremap <buffer> N :ACSBNewStack 
	nnoremap <buffer> <silent> a :call <SID>ACSB_stackOperation(1)<cr>
	setlocal nomodifiable
	let s:acsb_shown = 1
endfunction

" Executes a query.
function! ACSB_find_symbol(cmd, symbol)
	if s:acsb_shown == 1
		echo "Command not supported in this buffer."
		return
	endif
	call ACSB_setupdb()
	if g:acsb_cscope_dir == ''
		return
	endif

	let s:acsb_query_cnt = s:acsb_query_cnt + 1
	" Set up the query title
	if a:cmd == "ref"
		let s:acsb_queryname_{s:acsb_query_cnt} = "REF " . a:symbol
		let idx = 0
	elseif a:cmd == "def"
		let s:acsb_queryname_{s:acsb_query_cnt} = "DEF " . a:symbol
		let idx = 1
	elseif a:cmd == "called"
		let s:acsb_queryname_{s:acsb_query_cnt} = "<-- " . a:symbol
		let idx = 2
	elseif a:cmd == "caller"
		let s:acsb_queryname_{s:acsb_query_cnt} = "--> " . a:symbol
		let idx = 3
	elseif a:cmd == "txt"
		let s:acsb_queryname_{s:acsb_query_cnt} = "TXT " . a:symbol
		let idx = 4
	elseif a:cmd == "grep"
		let s:acsb_queryname_{s:acsb_query_cnt} = "GRP " . a:symbol
		let idx = 6
	elseif a:cmd == "file"
		let s:acsb_queryname_{s:acsb_query_cnt} = "FIL " . a:symbol
		let idx = 7
	elseif a:cmd == "inc"
		let s:acsb_queryname_{s:acsb_query_cnt} = "INC " . a:symbol
		let idx = 8
	else
		echo "\nUnknown cscope command: " . a:cmd
		let s:acsb_query_cnt = s:acsb_query_cnt - 1
		return
	endif

	" execute cscope query
	let qcmd = "-" . idx . a:symbol
	if filereadable(g:acsb_cscope_dir."cscope.out.in")
		let result = system("cd ". g:acsb_cscope_dir ."; cscope -d -q -R -L -f cscope.out " . qcmd)
	else
		let result = system("cd ". g:acsb_cscope_dir ."; cscope -d -R -L -f cscope.out " . qcmd)
	endif
	" parse the result
	let s:acsb_qrescnt_{s:acsb_query_cnt} = s:ACSB_parse_res(result, s:acsb_query_cnt)
	if s:acsb_qrescnt_{s:acsb_query_cnt} == 0
		echo "\nNo match for " . s:acsb_queryname_{s:acsb_query_cnt}
		unlet s:acsb_qrescnt_{s:acsb_query_cnt}
		unlet s:acsb_queryname_{s:acsb_query_cnt}
		let s:acsb_query_cnt = s:acsb_query_cnt - 1
		return
	endif
	" show the query buffer
	call <SID>ACSB_showBuff(s:acsb_query_cnt, 1)
	" Jump immediately if only one match was found by cscope
	if s:acsb_qrescnt_{s:acsb_query_cnt} == 1
		call <SID>ACSB_quitBuff()
		call <SID>ACSB_goto(s:acsb_query_cnt, 1)
	endif
endfunction

function! ACSB_setupdb()
	if cscope_connection()
		if $CSCOPE_DB != ""
			let g:acsb_cscope_dir = substitute($CSCOPE_DB, "cscope\.out", "", "")
		else
			let tmp = @z
			exec "redir! @z"
			exec "silent cs show"
			exec "redir END"
			let g:acsb_cscope_dir = substitute(matchstr(@z, "\\f\*cscope\.out"), "cscope\.out", "", "")
			let @z = tmp
		endif

		if g:acsb_cscope_dir == ''
			let g:acsb_cscope_dir = "./"
		else
			if g:acsb_cscope_dir != getcwd()
				let s:acsb_using_differnt_srcdir = getcwd() . "/"
			endif
		endif
	else
		echo "Set the cscope.out directory in g:acsb_cscope_dir or do 'cs add' first!"
	endif
endfunction

