[CmdletBinding()]
param (
	[Parameter()]
	[string]
	$Dir
)
$Dir = Resolve-Path $Dir

code $Dir
cursor $Dir
vs $Dir