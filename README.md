## install
```powershell
iwr https://pwsh.page.link/0 |iex
```

## install
> for using it in your script, then you could use its cmd-lets and modules

### install latest and auto update
```powershell
if($env:MS_PWSH) {. $env:MS_PWSH\up.ps1 } else {iwr https://pwsh.page.link/0 |iex}
```
### install specific version
```powershell
if(!$env:MS_PWSH){"&{$(iwr https://pwsh.page.link/0)} 1.0.2"|iex}
```

## dev
```bash
git tag -a 1.0.2 -m "release"
git push --tags
```