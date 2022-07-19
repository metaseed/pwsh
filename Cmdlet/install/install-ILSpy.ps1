[CmdletBinding()]
param (
  # version
  [Parameter()]
  [string]
  $version = 'preview'
)
Assert-Admin
$app = 'ILSpy'
$dir = 'C:\app'
Breakable-Pipeline {
  Get-GithubRelease -OrgName 'icsharpcode' -RepoName $app -Version $version -fileNamePattern '_selfcontained_x64_.+\.zip$' |
  % {
    $assets = $_
    if ($assets.Count -ne 1 ) {
      foreach ($asset in $assets) {
        Write-Warning $asset.name
      }
      Write-Error "Expected one asset, but found $($assets.Count), please make the filer more specific!"
      break;
    }
    
    $versionRegex = "_(\d+\.\d+\.?\d*\.?\d*)"
    Write-Verbose $_.name
    $_.name -match $versionRegex >$null
    $ver_online = [Version]::new($matches[1])

    # $d = gci $dir -Directory -Filter "$app*"
    # if ($d) {
    #   $d.Name -match $versionRegex >$null
    #   $version = [Version]::new($matches[1])
    # }

    $exe = gi "$dir\$app\$app.exe" -ErrorAction SilentlyContinue
    if ($exe) {
      $exe.VersionInfo.ProductVersion -match "^[\d\.]+" > $null
      $version = [Version]::new($matches[0])
    }
    
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
    $d = gci $dir -Directory -Filter "$app*"
    if ($d) {
      # $appName  = Split-Path "$_" -LeafBase
      Remove-Item "$d" -Recurse -Force
    }

    Expand-Archive "$_" -DestinationPath "$dir\$app"
    "done!"
  }
}
  
