function Get-LocalAppInfo {
	[CmdletBinding()]
	param(
		[string] $appName,
		[string] $toLocation = $env:MS_App,
		[string] $newName
	)

	$versionLocal = $null
	$appFolder = $null
	$installationTime = $null

	Write-Verbose "appName: $appName; toLocation: $toLocation; newName: $newName"
	# get version info from the app's property
	if (!$versionLocal) {
		$it = @(gci $toLocation -Filter "$appName*.exe" -File -FollowSymlink -Depth 2 -ErrorAction Ignore)
		if ($it) {
			if ($it.count -gt 1) {
				Write-Warning "find more than one app in $toLocation : $($it.FullName) "
				# break
			}

			Write-Verbose "find $appName in $toLocation : $($it.FullName)"
			$app = $it[0]
			$installationTime = $app.Lastwritetime
			$appFolder = $app.Directory.FullName
			if ($app.Directory.Name -like "$appName*") {
				$appFolder = $app.Directory.Parent.FullName
			}
			try {
				Write-Verbose "query local version via 'gcm $app'"
				$cmd = gcm "$app"
				$versionLocal = [Version]::new($cmd.FileVersionInfo.ProductVersion)
			}
			catch {
				try {
					Write-Verbose "query local version via ProductVersion property"
					$app.VersionInfo.ProductVersion -match "^[\d\.]+" > $null
					$versionLocal = [Version]::new($matches[0])

				}
				catch {
					$r = $app.VersionInfo.FileVersion -match "^[\d\.]+"
					Write-Verbose "query local version via FileVersion property(full): $($app.VersionInfo.FileVersion)"
					if ($r) {
						# the matches is not exist if match failed here
						# test-path variable:matches
						Write-Verbose "query local version via FileVersion property(matched): $($matches[0])"
						$versionLocal = [Version]::new($matches[0])
					}
					else {
						Write-Verbose "can not query version from exe file: $it"
					}
				}
			}
		}

		# folder has a info.json, test folder in $tolocaltion and it's direct subfolder
		if (!$versionLocal ) {
			Write-Verbose "toLocation: $toLocation, appName: $appName"
			$it = @(gci $toLocation -Filter "${appName}*" -Directory -Depth 1 -FollowSymlink -ErrorAction Ignore | ? { "$_" -notmatch '\\_|/_' })
			# Write-Host $it
			if ($it.Count -gt 1) {
				write-error "find more than one $appName in dir in $toLocation : $($it.FullName) "
				break
			}
			elseif ($it.Count -eq 0) {
				Write-Verbose "can not find dir named $appName in $toLocation"
			}
			else {
				$dir = $it[0]
				$jsonFile = gi "$dir\info.json" -ErrorAction Ignore
				if ($jsonFile) {
					$installationTime = $jsonFile.Lastwritetime
					Write-Verbose "query local version via the info.json in dir $($dir.FullName)"
					$info = Get-Content -Raw "$jsonFile" | ConvertFrom-Json
					$versionLocal = $info.version
					$appFolder = $jsonFile.Directory.Parent.FullName
				}
			}

		}

		# file or dir directly in app folder and the name has version info
		if (!$versionLocal ) {
			$it = @(gci $toLocation -Filter "$appName*")
			if ($it) {
				# Write-Host $it
				if ($it.count -gt 1) {
					write-error "find more than one dir/file in $toLocation : $($it.name) "
					break
				}

				$dir = $it[0]
				$versionRegex = "(\d+\.\d+\.?\d*\.?\d*)"
				$installationTime = $dir.Lastwritetime
				Write-host "dir/file name: $($dir.name)"

				if ($dir.Name -match $versionRegex) {
					Write-Verbose "query local version via dir/file name: $($dir.name)"
					$versionLocal = [Version]::new($matches[1])
					$appFolder = $toLocation

				}
				else {
					write-Host "no version info in directory name: $($dir.name)"
				}

			}
		}
	}

	Write-Host "local version: $versionLocal, installationTime: $installationTime, appFolder: $appFolder"

	if (!$versionLocal -and $newName) {
		Write-Verbose "try to get info with new name: $newName"
		$PSBoundParameters.appName = $newName
		$PSBoundParameters.newName = $null
		return Get-LocalAppInfo @PSBoundParameters
	}
	# the folder is where app.exe or app folder located
	return @{ver = $versionLocal; folder = $appFolder; }
}