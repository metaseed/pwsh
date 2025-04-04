lf (as in "list files") is a terminal file manager written in Go with a heavy inspiration from ranger file manager.
[Document](https://github.com/gokcehan/lf/blob/master/doc.md)
# quick start
`ctrl+o` or `lf` to invoke
> `ctrl+o` is configured in `PSReadlineConfig.ps1`
> the `lfrc` config file for more info

> with powershell, we can not pass argument parameters

# tips

glob: ? * [] [^]:  '*' matches any sequence, '?' matches any character, and '[...]' or '[^...] matches character sets or ranges.
if a pattern starts with '!', then its matches are excluded from hidden files.

* $env:f : file/folder at cursor
* $env:fx : files/folders selected or file/folder at cursor if no selection
> note: $f is current hightlighed file, $fs is selected files, $fx is $fs if select many else it is $f
> the separator in $fx is configured in 'filesep' option

shell          (modal)   (default '$')
shell-pipe     (modal)   (default '%')
shell-wait     (modal)   (default '!')  ! to wait after the command executed, and press any key to return to lf
shell-async    (modal)   (default '&')