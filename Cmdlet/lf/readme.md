[Document](https://github.com/gokcehan/lf/blob/master/doc.md)

> with powershell, we can not pass argument parameters
## tips
glob: ? * [] [^]:  '*' matches any sequence, '?' matches any character, and '[...]' or '[^...] matches character sets or ranges.
if a pattern starts with '!', then its matches are excluded from hidden files.

* $env:f : file/folder at cursor
* $env:fx : files/folders selected or file/folder at cursor if no selection
> note: $f is current hightlighed file, $fs is selected files, $fx is $fs if select many else it is $f

shell          (modal)   (default '$')
shell-pipe     (modal)   (default '%')
shell-wait     (modal)   (default '!')
shell-async    (modal)   (default '&')