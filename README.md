## install
```powershell
iwr https://pwsh.page.link/0 |iex
```

## auto install
> for using it in your script, then you could use its cmd-lets and modules

```powershell
if(!$env:MS_PWSH) {iwr https://pwsh.page.link/0 |iex} else {. $env:MS_PWSH\up.ps1}
```