function Start-Explorer {
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$path = '.',
		[Parameter()]
		[switch]
		$Admin
	)

	$isAdmin = Test-Admin
	if($isAdmin -xor $Admin){write-host "Already in $($admin ? 'admin': 'user') state"; return}

	if($isAdmin -and !$Admin) { # to user
		gps explorer -ErrorAction Ignore |spps
		start $path
		return
	}

	# to admin
	Assert-Admin
	do {
		$inAdmin = $true
		gps explorer -ErrorAction Ignore |
		? { !(Test-ProcessElevated $_) }
		| % {
			Write-Verbose 'stop the explorer run in normal mode'
			spps $_
			$inAdmin = $false
		}

		if (!$inAdmin) {
			Write-Verbose 'start the explorer in admin mode'
			explorer.exe /nouaccheck #"`"$path`""
			start $path
		}
		if($inAdmin) {write-host "Explorer runs in admin mode now."}
	} while (!$inAdmin)
}

Set-Alias stea Start-ExplorerInAdmin