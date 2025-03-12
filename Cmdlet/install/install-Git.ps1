Install-FromGithub 'git-for-windows/git' '64-bit.exe$' -getLocalInfoScript {
	$version = $null
	$git = gcm 'git' -ErrorAction Ignore
	if ($git) {
		$version = $git.version
	}
	return @{ver = $version }
} -installScript {
	[CmdletBinding()]
	param($downloadedFilePath, $ver_online)

	Write-Notice "installation started in background, please wait..."
	Start-Process -NoNewWindow -Wait $downloadedFilePath -ArgumentList '/SILENT /NORESTART'

}

Write-Step "config git"

write-host "add git utilities to user path"
# use append to lower cmd finding pority. i.e. dd command will not be the dd.exe in 'C:\Program Files\Git\usr\bin'
# cmd /c where dd
# note: 'gcm dd' just return the first found one
Add-PathEnv "$env:ProgramFiles\Git\cmd" User -append # gitk
# Add-PathEnv "$env:ProgramFiles\Git\usr\bin" User -append # is added by installation, git.exe,bash.exe,sh.exe is here
Add-PathEnv "$env:ProgramFiles\Git\mingw64\bin" User -append # Minimum GNU for Windows 64 bit,  It's the name of a compiler used to build an extra copy of bash that "git for Windows" includes.
Update-ProcessEnvVar

$gitConfig = @"
# included config
[include]
path = M:\\tools\\git\\.gitconfig
; https://git-scm.com/docs/git-config#_includes
; put slb repos in the 'SLB' folder
; git config --show-origin --get user.email
;/i: case-insensitively
[includeIf "gitdir/i:SLB/"]
path = M:\\tools\\git\\.slb.gitconfig
"@

$conf = gc $home/.gitconfig -raw
if (!$conf.contains($gitConfig)) {
	$gitConfig >> $home/.gitconfig
}
else {
	write-host 'no action, git already configured'
}

