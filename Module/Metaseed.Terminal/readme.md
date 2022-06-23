## Description
* Cyclically changing Windows Terminal's background image at configured interval via settings.json.
* Play a 
## Setup
in your powershell profile:
```powershell
if ($env:WT_SESSION) {
  Start-WTCyclicBgImg
}
```
it will use the default setting, inside the $env:WTBackground/_bin/settings.json, you could use it as a blueprint and modify it to get yours.
$env:WTBackground is the Metaseed.Terminal module path, it is set when load the module.

or use your own settings 
```powershell
if ($env:WT_SESSION) {
  Start-WTCyclicBgImg $PSScriptRoot\settings.json
}
```

## Show-WTBGGif
show a gif for while, the Gifs 