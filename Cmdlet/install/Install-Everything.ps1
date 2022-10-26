[CmdletBinding()]
param (
  [Parameter()]
  [switch]
  $force
)
ipmo metaseed.management -fo;
$url = 'https://www.voidtools.com/downloads'
$name = 'everything'
spps -n $name -ErrorAction Ignore
$resp = iwr $url
if ($resp.Content -match '<a .*href="(.*)".*>\s*Download Portable Zip 64-bit') {
  $zip = $Matches[1]
  $zip -match '\d+\.\d+\.?\d*\.?\d*' > $null
  $verOnline = [Version]::new($Matches[0])
  $localInfo = Get-LocalAppInfo $name $env:MS_App
  $localVer = $localInfo.ver

  $localFolder = $localInfo.folder ?? "$env:MS_App\software"
  copy-item "$localFolder\$name\$name.ini" "\_$name.ini" -Force -ErrorAction Ignore

  $r = Test-AppInstallation $name $localVer $verOnline -force:$force
  if ($r) {

    $zipUrl = "https://www.voidtools.com$zip"
    $path = "$env:temp$($zip)"
    iwr $zipUrl -OutFile $path
    install-app $path $verOnline $name $localFolder
    move-item "\_$name.ini" "$localFolder\$name\$name.ini" -Force
  }
} else {
write-error 'can not parse the returned html to install everything.exe'
}
$name = 'everyting-cmd'
if ($resp.Content -match '<a .*href="(.*)".*>\s*ES-\d+\.\d+\.?\d*\.?\d*\.zip') {
  $zip = $Matches[1]
  $zip -match '\d+\.\d+\.?\d*\.?\d*' > $null
  $verOnline = [Version]::new($Matches[0])
  $localInfo = Get-LocalAppInfo $name $env:MS_App
  $localVer = $localInfo.ver

  $localFolder = $localInfo.folder ?? "$env:MS_App"
  # copy-item "$localFolder\$name\$name.ini" "\_$name.ini" -Force -ErrorAction Ignore

  $r = Test-AppInstallation $name $localVer $verOnline -force:$force
  if (!$r) { return }

  $zipUrl = "https://www.voidtools.com$zip"
  $path = "$env:temp$($zip)"
  iwr $zipUrl -OutFile $path
  install-app $path $verOnline $name $localFolder
  # move-item "\_$name.ini" "$localFolder\$name\$name.ini" -Force
  return
}
write-error 'can not parse the returned html, to install commandline version of everything'