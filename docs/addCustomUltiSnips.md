When you editing some file, you want to add some snippets.

It's very convenient to use the command `UltiSnipsEdit`.

In order to make the snippets you just create to a specified directory, and make the snippets work immediately

the following settings should add to your `~/.vimrc`

```vimrc
let g:UltiSnipsSnippetsDir = $HOME . '/.vim/mycoolsnippets/UltiSnips'
let g:UltiSnipsSnippetDirectories=["UltiSnips", "mycoolsnippets/UltiSnips"]  
```

Why `UltiSnips` doesn't automatically add the snippets search path `UltiSnipsSnippetsDir`?

That's not a good design.
