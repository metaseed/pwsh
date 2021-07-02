## install
```powershell
iwr https://pwsh.page.link/0 |iex
```

## auto install
> for using it in your script, then you could use its cmd-lets and modules

```powershell
if($env:MS_PWSH) {. $env:MS_PWSH\up.ps1 } else {iwr https://pwsh.page.link/0 |iex}
```