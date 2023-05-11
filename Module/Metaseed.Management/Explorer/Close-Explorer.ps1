function Close-Explorer {
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$Folder
	)
	Get-Explorer $Folder|% {$_.Quit()}

}