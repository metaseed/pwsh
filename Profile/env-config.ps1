
# by default it's Chinese Simplified (GB2312), is it because i installed Chinese simplified in the windows system?
# so let change it to UTF8 explicitly
[Console]::OutputEncoding = [Text.Encoding]::UTF8

if ($env:__MS_PWSH_PARENT -ne 'true') {
	$env:__MS_PWSH_PARENT = $true;
	# it will delete all pervious logs, if when run a child `pwsh` process, it will also clear the logs of parent, so we determine to comment out it.
	# Also when in the app `lf`, when we need to switch to the shell to view log, it will reload the profile, then the previous logs are removed.
	# the solution:
	# 1. in `windows terminal` pwsh profile, we use `pwsh -nologo` to launch pwsh (not used)
	# 2. used the inherited env var added in profile.(used)
	Clear-Host;
}


$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
$cl="`e[0m"
"`e[5mpwsh$cl v$($Host.Version) `e[33;3;4m$($IsAdmin ? 'admin':'')`e[0m" #; profile: $PSCommandPath"
if($IsAdmin) {
	if ($PWD.ProviderPath -ieq (Join-Path $env:SystemRoot 'System32')) {
		Set-Location -Path $env:USERPROFILE
	}
}

# not needed if we run pwsh with -noexit, so even we install ms_pwsh from v5 powershell, we still in pwsh.
# fix after install, the env is not updated
# if(-not $env:MS_PWSH) {
#   $env:MS_PWSH = [System.Environment]::GetEnvironmentVariable("MS_PWSH", "User")
# }

# $InformationPreference = 'Continue' # SilentlyContinue (default); to display Write-Information message