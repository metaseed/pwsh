<#
close opened explorers, by default close all.
#>
function Close-Explorer {
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$Folder = '*'
	)
	Get-OpenedExplorer $Folder|% {$_.Quit()}

}