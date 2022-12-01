function Start-ExplorerInAdmin {
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$path = '.'
	)

	Assert-Admin

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
	}
	start $path
}

Set-Alias stea Start-ExplorerInAdmin