# coding on dir
[CmdletBinding()]
param (
	[Parameter(ValueFromPipeline = $true)]
	[string]
	$Dir
)
process {
	if (!$Dir) { $Dir = '.' }
	else { $Dir = zz $Dir }

	oc $Dir
	os $Dir
	ov $Dir
}