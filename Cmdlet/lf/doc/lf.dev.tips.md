
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

> the key trigger can be upcase
> i.e. map Q quit

## how to debug lfrc file changes
F4 to open the lfrc file in vscode, then changing and saving,
F5 to reload the lfrc config
> because lf buffer the preview content, we need to fully refresh lf with `ctrl+r` or fully reload the lf with below command
> to redraw the preview
```pwsh
Restore-LfConfig.ps1;spps -n lf; a lf
```
## ways to create commands
* the default shell for windows is cmd, so we can use all cmd commands
* we can use pwsh to write script file
* we can use the 'sh' (C:\msys64\usr\bin\sh.exe) to excute cmd, i.e. `%sh -c '7z a $0 %fx%'` and `%sh -c 'c:/app/7-zip/7z  x %f% -o$0'`

## debug
in pwsh script we use `Show-MessageBox`
we can also use the `!command` to waiting for a key press after the command executing to view the log. i.e. from `write-host`
for example:
```pwsh
cmd trash-selected &pwsh -nologo -noninteractive -noprofile -file M:/Script/Pwsh/Cmdlet/lf/config/scripts/trash.ps1
map <delete> trash-selected
```
to debug this script, we change the `&pwsh` to `!pwsh` to see the log from the script to help for debugging

> note: for pwsh script, although we invoke pwsh with `&pwsh -nologo -noninteractive -noprofile -file ...` we can still use the command in the ms_pwsh modules, i.e. call `show-messagebox` command which is defined in 'metaseed.console` module. because the  $env:PSModulePath is still used as configured before.
>

use the `w` to switch to the shell to view the log, and type `exit` to switch to lf
## environment variables
https://github.com/gokcehan/lf/wiki/Tips#use-environment-variables-in-command-or-mapping
https://github.com/gokcehan/lf/blob/master/doc.md#environment-variables
> to view the env value: `w` to launch the shell to view
You can't use environment variables directly in mappings and internal commands. In order to utilize environment variables, lf -remote must be called.
> map gG $lf -remote "send $id cd $GOPATH"
## pass in arguments into the pwsh script
> refer the example `test-args.ps1` and config in lfrc

> it use `space` to separate args, if the arg has `space` in it, need to use `'`,
> we can do ` $args -join ' '` to join all input

## show message
https://github.com/gokcehan/lf/blob/master/doc.md#echomsg
c:\app\lf.exe -remote "send $env:id echomsg 'path copied: $env:fx'"
echoerr to show error

## interaction to read input from user and continue
use $ to execute to make `read-host` work, it will switch to the shell for you to input
> note: the % is even better, it will stay in the lf to read and then continue, but we can not use `write-host` to show message to user
>
 to show log with `write-host` we need to use the `!` to execute and wait to see the pwsh instance outputs

```
cmd createfile $pwsh -NoProfile -nologo -File M:/Script/Pwsh/Cmdlet/lf/_config/lf/scripts/createFile.ps1 $0
```
> note: no `-noninteractive`
and use `read-host` to read input from user, refer the `createFile.ps1`

## to link to another folder
ni -itemtype SymbolLink FolderName -value source-dir-path
> lf can navigate into the folder without change the path(not the source's path)
> lf can not navigate into the `Junction` type
> `symbolLink` is good for link between drives too.
