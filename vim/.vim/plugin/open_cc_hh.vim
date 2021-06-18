"""""""""""""""""""""""""""""""""""""""""""""""""""
" open cc & hh file in splited window
"""""""""""""""""""""""""""""""""""""""""""""""""""
"
if exists ("g:loaded_open_split")
	finish
endif

let g:loaded_open_split = 1

func! <SID>OpenSplitCCHH() 
	let file_name = expand("%:t:r")
	let file_ext = expand("%:e")

	if file_ext == "cc" || file_ext == "cpp" || file_ext == "c"
		" find header file...............................

		for path in [ expand("%:p:h"), getcwd()."/include" ]
			for ext in [ ".h", ".hh" ]
				let check_name = path . "/" . file_name . ext

				if filereadable(check_name)
					exec winheight(0)/3 . "new " . check_name
					exec "wincmd w"
					return
				endif
			endfor
		endfor

		for path in [ expand("%:p:h"), getcwd()."/include/imf" ]
			for ext in [ ".h", ".hh" ]
				let check_name = path . "/" . file_name . ext

				if filereadable(check_name)
					exec winheight(0)/3 . "new " . check_name
					exec "wincmd w"
					return
				endif
			endfor
		endfor

		for path in [ expand("%:p:h"), getcwd()."/include/file_manager" ]
			for ext in [ ".h", ".hh" ]
				let check_name = path . "/" . file_name . ext

				if filereadable(check_name)
					exec winheight(0)/3 . "new " . check_name
					exec "wincmd w"
					return
				endif
			endfor
		endfor

	elseif file_ext == "h" || file_ext == "hh"
		" find source file...............................

		let path = expand("%:p:h")
		for ext in [ ".c", ".cc", ".cpp" ]
			let check_name = path . "/" . file_name . ext

			if filereadable(check_name)
				exec "below " . winheight(0)*2 . "new " . check_name
				return
			endif
		endfor

		for path in [ expand("%:p:h"), getcwd()."/lib/file_manager" ]
			for ext in [ ".c", ".cc" ]
				let check_name = path . "/" . file_name . ext

				if filereadable(check_name)
					exec winheight(0)/3 . "new " . check_name
					exec "wincmd w"
					return
				endif
			endfor
		endfor

		for path in [ expand("%:p:h"), getcwd()."/lib/imf" ]
			for ext in [ ".c", ".cc" ]
				let check_name = path . "/" . file_name . ext

				if filereadable(check_name)
					exec winheight(0)/3 . "new " . check_name
					exec "wincmd w"
					return
				endif
			endfor
		endfor

	endif
	
"	if !filereadable(file_hh) && stridx(file_full, "/lib")
"		let file_hh = file_dirname . "/../include/" . expand("%:t:r") . open_ext
"	endif

"	if filereadable(file_hh)
"		exec "e " . file_cc
"		exec "setf cpp"

"		exec winheight(0)/3 . "sp " . file_hh
"		exec "setf cpp"
"		exec "set cin"
"		exec "wincmd w"
	"else
		"exec "e " . file_full
		"exec "setf cpp"
		"exec "set cin"
"	endif
endf


nmap <silent> <F10> :call <SID>OpenSplitCCHH()<cr>

"augroup OpenSplit
	"au!
	"au BufRead {Test}\@![A-Z/]*.cc			call s:RunOpenSplitCC()
"augroup END
