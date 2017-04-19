# vim script note

The first entrance
```vim
:h vim-script-intro
:help function
:help function-list
```

Create **N**ormal key **MAP**
```vim
function! ToggleSyntax()
	if exists("g:syntax_on")
		syntax off
	else
		syntax on
	endif
endfunction
nmap ts :call ToggleSyntax()<CR>
```

Vertical bar to execute multiple statements in single line
```vim
function! Phase(phase)
	echo "Phase " . a:phase
endfunction
:echo "Starting" | call Phase(1) | call Phase(2) | call Phase(3)
```

Case-sensitive `==#` and case-insensitive `==?` string comparing


Execute command on selected text
```vim
:'<,'>:w !command<CR>
```
