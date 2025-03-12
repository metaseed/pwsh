<#
get the explorer opened with it's Folder like the $folder param
#>
function Get-OpenedExplorer {
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$Folder
	)
	$Folder = $Folder.Replace('\', '/')

	$shell = New-Object -ComObject Shell.Application
	# "$(([uri]"$Folder").AbsoluteUri)*"
	$window = $shell.Windows() |? {
		## remove  file:///
		$path = $_.LocationURL.TrimStart('file:///')
		$path -like $Folder
	}
	return $window
}