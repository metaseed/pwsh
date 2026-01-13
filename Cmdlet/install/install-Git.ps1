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
	Write-Notice "git-for-windows installed"
}

Write-Step "config git"

write-host "add git utilities to user path"
# use append to lower cmd finding pority. i.e. dd command will not be the dd.exe in 'C:\Program Files\Git\usr\bin'
# cmd /c where dd
# note: 'gcm dd' just return the first found one
# use bash.exe, not use -append, because the windows's wsl bash inside the path: C:\Users\jsong12\AppData\Local\Microsoft\WindowsApps\, we need to override it.
# note: we use wsl command to run the wsl bash, which is recommended by Microsoft, bash is the legacy command of wsl v1.
# note in bash, use ctrl+u to start over
Add-PathEnv "$env:ProgramFiles\Git\bin" User
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
; git config --global init.templateDir 'M:\tools\git\.git-templates'
; for existing repos, run run git-SetupHook
[init]
	templateDir = M:\\Script\\Pwsh\\Module\\Metaseed.Git\\_features\\parent-branch\\resources\\.git-templates
"@

$conf = gc $home/.gitconfig -raw -ErrorAction Ignore
if (!$conf -or !$conf.contains($gitConfig)) {
	$gitConfig >> $home/.gitconfig
} else {
	write-host 'no action, git already configured'
}
# enable long path
git config --system core.longpaths true

