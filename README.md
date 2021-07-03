## install
```powershell
iwr https://pwsh.page.link/0 |iex
```

## install
> for using it in your script, then you could use its cmd-lets and modules

### install latest and auto update
```powershell
if($env:MS_PWSH) {. $env:MS_PWSH\up.ps1} else {iwr https://pwsh.page.link/0 |iex}
# \up.ps1 1: check update every 1 day, default is 0: immediately
```
### install specific version
```powershell
$v = 1.0.2 # latest
if(!$env:MS_PWSH){"&{$(iwr https://pwsh.page.link/0)} $v"|iex
```

## dev
```bash
git tag -a 1.0.2 -m "release"
git push --tags
```