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
* we can use the 'sh' (C:\msys64\usr\bin\sh.exe) to excute cmd


