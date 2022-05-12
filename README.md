## requirement
powershell 7 or later

## install
```powershell
iwr https://pwsh.page.link/0 |iex
```

> for using it in your script, then you could use its cmd-lets and modules

### install latest and auto update
```powershell
if($env:MS_PWSH) {. $env:MS_PWSH\up.ps1} else {iwr https://pwsh.page.link/0|iex}
# \up.ps1 1: check update every 1 day, default is 0: immediately
```
### install specific version
```powershell
# $v = latest
$v = 1.0.2 
if(!$env:MS_PWSH){"&{$(iwr https://pwsh.page.link/0)} $v"|iex
```

## dev
### release
```powershell
./release.ps1
```

## Mis
### posh-git
the profile contains posh-git config, to install posh-git
```powershell
PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
```
to update
```powershell
PowerShellGet\Update-Module posh-git
```
https://github.com/dahlbyk/posh-git
