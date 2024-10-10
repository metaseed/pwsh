# start https://tools.pdf24.org/en/
$app = Get-AppInstallation *pdf24*
if ($app -eq $null) {
	$url = 'https://creator.pdf24.org/listVersions.php'
	Write-Notice "Please install pdf24 from $url"
	return
}
$path = $app.InstallLocation
$app = gps pdf24-Toolbox -ErrorAction Ignore
if (!$app) {
	start "$path\pdf24-Toolbox.exe"
}
else {
	Show-AppWindow pdf24-Toolbox
}
