[CmdletBinding()]
param (
  # version
  [Parameter()]
  [string]
  $version = 'preview'
)
Assert-Admin
$org = 'BluePointLilac'
$app = 'ContextMenuManager'
$dir = $env:MS_App

$filter = 'ContextMenuManager\.NET\.4\.0\.exe$' # '(?<!\.Light).Portable.x64.zip$'
# $versionRegex = "_(\d+\.\d+\.?\d*\.*\d*)_x64"

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
    
    # $_.name -match $versionRegex >$null
    # $ver_online = [Version]::new($matches[1])
    Write-Verbose "$_"
    $ver_online = [Version]::new( $_.tag_name)

    # $it = gci $dir -Directory -Filter "$app*"
    # if ($it) {
    #   $it.Name -match $versionRegex >$null
    #   $version = [Version]::new($matches[1])
    # }

    $it = gi "$dir\$app*.exe" -ErrorAction SilentlyContinue
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

    # Expand-Archive "$_" -DestinationPath "$dir"
    Move-Item "$_" -Destination $dir
    write-host "done!"
  }
}
  
