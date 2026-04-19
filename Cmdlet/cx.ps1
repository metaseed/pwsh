# coding on dir
[CmdletBinding()]
param (
	[Parameter(ValueFromPipeline = $true)]
	[string]
	$Dir
)
process {
	if(!$Dir) {$Dir= '.'}
	else {$Dir = zz $Dir}

	cc $Dir
	cs $Dir
	cv $Dir
}