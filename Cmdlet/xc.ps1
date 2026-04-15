# coding on dir
[CmdletBinding()]
param (
	[Parameter(ValueFromPipeline = $true)]
	[string]
	$Dir
)
process {
	if(!$Dir) {$Dir= '.'}
	$Dir = Resolve-Path $Dir

	cc $Dir
	cs $Dir
	cv $Dir
}