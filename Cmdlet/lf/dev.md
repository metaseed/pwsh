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
## environment variables
https://github.com/gokcehan/lf/wiki/Tips#use-environment-variables-in-command-or-mapping
https://github.com/gokcehan/lf/blob/master/doc.md#environment-variables
> to view the env value: `w` to launch the shell to view
You can't use environment variables directly in mappings and internal commands. In order to utilize environment variables, lf -remote must be called.
> map gG $lf -remote "send $id cd $GOPATH"