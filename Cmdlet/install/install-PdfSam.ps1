[CmdletBinding()]
param (
  # version
  [Parameter()]
  [string]
  $version = 'preview'
)
Assert-Admin
$org = 'torakiki'
$app = 'pdfsam'
$dir = $env:MS_App

$filter = '-windows\.zip$' # '(?<!\.Light).Portable.x64.zip$'

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
    # $versionRegex = "_(\d+\.\d+\.?\d*\.*\d*)_x64"
    # $_.name -match $versionRegex >$null
    # $ver_online = [Version]::new($matches[1])
    Write-Verbose "$_"
    $ver_online = $_.tag_name.trim('v','e','r')
    $ver_online = [Version]::new($ver_online)

    # $it = gci $dir -Directory -Filter "$app*"
    # if ($it) {
    #   $it.Name -match $versionRegex >$null
    #   $version = [Version]::new($matches[1])
    # }

    $it = gi "$dir\$app*\$app*.exe" -ErrorAction SilentlyContinue
    if ($it) {
      $version = [Version]::new($it.VersionInfo.ProductVersion)
    }
    
    if (!($it)) {
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
    # Move-Item "$_" -Destination $dir
    write-host "done!"
  }
}
  
