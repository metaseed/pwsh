## Description
* Cyclically changing Windows Terminal's background image at configured interval via settings.json.
* Play a gif for a while on the background to show status/message/notification to users.

## Setup
in your powershell profile:
```powershell
if ($env:WT_SESSION) {
  Start-WTCyclicBgImg
}
```
it will use the default setting, inside the $env:MS_WTBackground/_bin/settings.json, you could use it as a blueprint and modify it to get yours.
$env:MS_WTBackground is the Metaseed.Terminal module path, it is set when load the module.

or use your own settings
```powershell
if ($env:WT_SESSION) {
  Start-WTCyclicBgImg $PSScriptRoot\settings.json
}
```

## Show-WTBackgroundImage
show a gif for while.
the image could be a web gif, i.e.
```
Show-WTBackgroundImage https://media.giphy.com/media/h4fRaq5CW5Ll3FLPq0/giphy.gif
```
or a absolute image path on disk.

or a file name in the folder configured at the environment variable `MS_WTBackground`:
there could be sub folders inside the $env:MS_WTBackground.
if the parameter is a folder/sub-folder name, a radom image inside the folder would be used.
and there is default images, inside the default folder: $env:MS_WTBackground\res\gifs
```
Show-WtBackgroundImage success # would radom use a image in the folder 'success'
```
you could look at the folder structure in the $env:MS_WTBackground\res\gifs, to config your own $env: MS_WTBackground

## matrixRain.gif
https://codepen.io/metasong/full/WNzodaB
