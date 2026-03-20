function Get-VersionFromString {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]$str
	)

	# try dotted version: 1.2.3, 5.4.7
	if ($str -match '(\d+\.\d+\.?\d*\.?\d*)') {
		return [Version]::new($Matches[1].TrimEnd('.'))
	}

	# try underscore-separated version: 4_25, 4_25_1
	if ($str -match '(\d+_\d+_?\d*_?\d*)') {
		$ver = $Matches[0].Replace('_', '.').TrimEnd('.')
		return [Version]::new($ver)
	}

	# try single number: treat as major.0
	if ($str -match '^\d+$') {
		return [Version]::new($Matches[0] + '.0')
	}

	return $null
}
