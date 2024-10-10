function Get-AppInstallation {
	param (
		# app name
		[Parameter()]
		[string]
		$ApplicationName
	)
	Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,
	HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
	Select-Object DisplayName, InstallLocation |
	Where-Object { $_.DisplayName -like $ApplicationName -and $_.InstallLocation } |
	Sort-Object DisplayName
}

# Get-InstallationPath *pdf24*