PWSH is a set of PowerShell modules/cmdlets to help automating the daily routine task.
The goal is to save us time, effort and improve efficiency.

It is created with the script-mindset: Don't Repeat Yourself - DRY, repeat by scripts.
## requirement
powershell 7 or later

## install
```powershell
iwr https://pwsh.page.link/0 |iex
```

> then you could use its cmd-lets and modules


### install latest and auto update
```powershell
if($env:MS_PWSH) {. $env:MS_PWSH\upgrade.ps1} else {iwr https://pwsh.page.link/0|iex}
# \up.ps1 1: check update every 1 day, default is 0: immediately
```
### install specific version
```powershell
# $v = latest
$v = 1.0.2
"&{$(iwr https://pwsh.page.link/0)} $v"|iex
```



## Mis
### posh-git
the profile contains posh-git config, to install posh-git
```powershell
setup-poshGit
```
https://github.com/dahlbyk/posh-git

## Development

### Installation for developer
if you want to contribute to the development, and always using the latest code from the master branch.

```powershell
"& {$(iwr https://pwsh.page.link/dev)} c:\" |iex
```
> it will clone into `c:\pwsh` folder, replace `c:\` to your own folder that used to contain the source code

> note: it will clone the repo to the folder, and setup the profile.

### release
```powershell
./release.ps1
```
