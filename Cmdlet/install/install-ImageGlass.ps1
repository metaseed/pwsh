[CmdletBinding()]
param (
  # version
  [Parameter()]
  [string]
  $version = 'preview'
)
Assert-Admin
$org = 'd2phap'
$app = 'ImageGlass'
$dir = $env:MS_App
# ImageGlass_Kobe_8.6.7.13_x64.zip
$filter = '_x64.zip$' # '(?<!\.Light).Portable.x64.zip$'
$versionRegex = "_(\d+\.\d+\.?\d*\.*\d*)_x64"

Breakable-Pipeline {
  Get-GithubRelease -OrgName $org -RepoName $app -Version $version -fileNamePattern $filter |
  % {
    $assets = $_
    if ($assets.Count -ne 1 ) {
      foreach ($asset in $assets) {
        Write-Warning $asset.name
      }
      Write-Error "Expected one asset, but found $($assets.Count), please make the filer more specific!"
      break;
    }
    
    $_.name -match $versionRegex >$null
    $ver_online = [Version]::new($matches[1])

    $d = gci $dir -Directory -Filter "$app*"
    if ($d) {
      $d.Name -match $versionRegex >$null
      $version = [Version]::new($matches[1])
    }

    # $exe = gi "$dir\$app.exe" -ErrorAction SilentlyContinue
    # if ($exe) {
    #   $version = [Version]::new($exe.VersionInfo.ProductVersion)
    # }
    
    if (!($d)) {
      Write-Host "install the latest ${app}: $ver_online"
    }
    else {
      if ($ver_online -le $version) {
        Write-Host "You are using the latest version of $app.`n $version is the latest version available."
        break
      }
      write-host "You are using $app $version.`n The latest version is $ver_online."
    }
    return $_
  } |
  Download-GithubRelease | 
  % {
    gci $dir -Directory -Filter "$app*" |
    Remove-Item -Recurse -Force

    Expand-Archive "$_" -DestinationPath "$dir"
    "done!"
  }
}
  