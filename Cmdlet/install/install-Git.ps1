Install-FromGithub 'git-for-windows\git' '64-bit.exe$' -getLocalVerScript {
  $version = $null
  $git = gcm 'git' -ErrorAction Ignore
  if ($git) {
    $version = $git.version
  }
  return $version
} -installScript {
  [CmdletBinding()]
  param($downloadedFilePath, $ver_online)

  Write-Notice "installation started in background, please wait..."
  Start-Process $downloadedFilePath -ArgumentList '/SILENT /NORESTART' -NoNewWindow -Wait

  Write-Step "config git"

  "add git utilities to user path"
  # use append to lower cmd finding pority. i.e. dd command will not be the dd.exe in 'C:\Program Files\Git\usr\bin'
  # cmd /c where dd
  # note: 'gcm dd' just return the first found one
  Add-PathEnv "$env:ProgramFiles\Git\cmd" User -append
  # Add-PathEnv "$env:ProgramFiles\Git\usr\bin" User -append # is added by installation, git.exe,bash.exe,sh.exe is here
  Add-PathEnv "$env:ProgramFiles\Git\mingw64\bin" User -append
  Update-EnvVar

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
}



