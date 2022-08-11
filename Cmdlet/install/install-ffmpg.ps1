
# https://ffmpeg.org/download.html#build-windows
# https://github.com/GyanD/codexffmpeg/releases/


[CmdletBinding()]
param (
  # version
  [Parameter()]
  [string]
  $version = 'stable'
)
Assert-Admin
Breakable-Pipeline {
  Get-GithubRelease -OrgName 'GyanD' -RepoName 'codexffmpeg' -Version $version -fileNamePattern '-full_build.zip$' |
  % {
    $assets = $_
    if ($assets.Count -ne 1 ) {
      foreach ($asset in $assets) {
        Write-Host $asset.name
      }
      Write-Error "Expected one asset, but found $($assets.Count)"
      break;
    }

    $_.name -match "-(\d+\.\d+\.\d+\.*\d*)-" >$null
    $ver_online = [Version]::new($matches[1])

    $d = gci 'c:\app' -Directory -Filter 'ffmpg-*'
    if ($d) {
      $d.Name -match "-(\d+\.\d+\.\d+\.*\d*)-" >$null
      $version = [Version]::new($matches[1])
    }

    if (!($d)) {
      Write-Host "install the latest ffmpg: $ver_online"
    }
    else {
      if ($ver_online -le $version) {
        Write-Host "You are using the latest version of ffmpg.`n $version is the latest version available."
        break
      }
      write-host "You are using ffmpg $version.`n The latest version is $ver_online."
    }
    return $_
  } |
  Download-GithubRelease | 
  % {
    gci 'c:\app' -Directory -Filter 'ffmpg-*' |
    Remove-Item -Recurse -Force

    Expand-Archive "$_" -DestinationPath "c:\app"
    "done!"
  }
}
  
