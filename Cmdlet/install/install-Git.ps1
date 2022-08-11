
[CmdletBinding()]
param (
  # version
  [Parameter()]
  [string]
  $version = 'stable'
)
Assert-Admin
$app = 'git'
Breakable-Pipeline {
  Get-GithubRelease -OrgName 'git-for-windows' -RepoName $app -Version $version -fileNamePattern '64-bit.exe$' |
  % {
    $assets = $_
    if ($assets.Count -ne 1 ) {
      foreach ($asset in $assets) {
        $asset.name
      }
      Write-Error "Expected one asset, but found $($assets.Count)"
      break;
    }

    $_.name -match "-(\d+\.\d+\.\d+\.*\d*)-" >$null
    $ver_online = [Version]::new($matches[1])
    if (gcm $app -ErrorAction Ignore) {
      $version = $git.version
      if ($ver_online -le $version) {
        Write-Host "You are using the latest version of $app.`n $version is the latest version available."
        break
      }
      Write-Host "You are using $app $version.`n The latest version is $ver_online."
    }
    else {
      Write-Host  "$app is not installed, the online version is $ver_online"
    }
    return $_
  } |
  Download-GithubRelease | 
  % {
    Write-Notice "installation started in background..."
    Start-Process $_ -ArgumentList '/SILENT /NORESTART' -NoNewWindow -Wait
    "add git utilities to user path"
    $PathOld = [Environment]::GetEnvironmentVariable('Path', 'User')
    [Environment]::SetEnvironmentVariable("Path", "$PathOld;$env:ProgramFiles\Git\cmd;$env:ProgramFiles\Git\mingw64\bin", "User")
   
  }
}

Write-Step "config git"
$gitConfig = @"
# included config
[include]
	path = M:\\tools\\git\\.gitconfig
; put slb repos in the 'SLB' folder
; https://git-scm.com/docs/git-config#_includes
[includeIf "gitdir:**/SLB/**"] ; put slb repos in the 'SLB' folder
	path = M:\\tool\\git\\.slb.gitconfig

"@
$conf = gc $home/.gitconfig -raw
if (! $conf.contains($gitConfig)) {
  $gitConfig >> $home/.gitconfig
}
else {
  write-host 'no action, git already configured'
}
Write-Host 'done!'
  
