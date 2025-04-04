function Test-AppInstallation {
  [CmdletBinding()]
  param (
    # app
    [Parameter()]
    [string]
    $appName,
    [Parameter()]
    [version]
    $versionLocal,
    # online version
    [Parameter()]
    [Version]
    $versionOnline,
    [switch]$force
  )

  if (!$versionLocal) {
    Write-Host "$appName is not installed, try to install the latest ${appName}: $versionOnline"
  }
  else {
    if ($versionOnline -le $versionLocal) {
      Write-Notice "You are using the latest version of $appName.`n$versionLocal is the latest version available."
      if (!$force) {
        return $false
      }
      Write-Warning "As you wish, forcedly install the latest version..."
    }

    Write-Notice "You are using $appName $versionLocal"
    Write-Notice "The latest version is $versionOnline."

  }
  return $true
}