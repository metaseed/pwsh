function Install-App {
	[CmdletBinding()]
	param($downloadedFilePath, $ver_online, $appName, $toLocation, [switch]$CreateFolder, [string]$newName, $verLocal, [switch]$pickExes)

	Write-Host "Install $appName ..."
	Write-Host "from $downloadedFilePath"
	## delete app
	# ignore error, may not exist
	if ($newName) {
		$app = gci $toLocation -Filter "$newName*"
		if ($app) {
			Remove-Item $app -Recurse -Force
		}
	}

	if (!$newName -or !$app) {
		gci $toLocation -Filter "$appName*" |
		Remove-Item -Recurse -Force
	}
	## is exe file
	# Write-Host "to localtion: $toLocation"
	if ($downloadedFilePath -match '\.exe$') {
		Move-Item "$_" -Destination $toLocation -Force
		if ($newName) {
			$exe = Split-Path "$_" -Leaf
			Rename-Item "$toLocation\$exe" -NewName "$newName.exe"
		}
		return $toLocation
	}

	### is archive file
	## unzip
	Remove-Item $env:temp\temp -Force -Recurse -ErrorAction Ignore
	Write-Action "expand archive to $env:temp\temp..."
	if ($downloadedFilePath -match '\.zip|\.zipx|\.7z|\.rar') {
		Expand-Archive $downloadedFilePath -DestinationPath "$env:temp\temp"
	}
	elseif ($downloadedFilePath -match '\.tar\.gz') {
		if (!(test-path $env:temp\temp)) {
			$null = ni $env:temp\temp -ItemType Directory
		}
		tar -xf $downloadedFilePath -C "$env:temp\temp"
	}
	else {
		write-error "$downloadedFilePath is not a know copressed archive!"
		break
	}

	## install
	$children = @(gci "$env:temp\temp")
	while ($children.Count -eq 1 -and $children[0].PSIsContainer) {
		$children = @(gci $children[0])
	}

	if (($children.count -ne 1 -and !$pickExes) -or $CreateFolder) {
		$name = $newName ? $newName : $appName
		$toLocation = "$toLocation\${name}"
		Write-Verbose "to location: $toLocation"
		Move-Item "$($children[0].parent)" -Destination $toLocation
		# _${ver_online}
		$info = @{version = "$ver_online" }
		$info | ConvertTo-Json | Set-Content -path "$toLocation\info.json" -force
	}
	else {
		# only one file: *.exe
		if ($pickExes) {
			$app = gci -Recurse -Filter '*.exe' "$env:temp\temp"
		}
		else {
			$app = @($children[0])
		}
		$app | % {
			$ver_online -match "^[\d\.]+" > $null
			$ver_online = [Version]::new($Matches[0])

			# $app.VersionInfo
			Write-host "install app: $app"
			# $verLocal = if($app.VersionInfo) {$app.VersionInfo.ProductVersion ? $app.VersionInfo.ProductVersion : $app.VersionInfo.FileVersion}

			if ($verLocal) {
				$app.VersionInfo.ProductVersion -match "^[\d\.]+" > $null
				$verLocal = [Version]::new($Matches[0])
				write-host "new local version: $verLocal"

			}

			if (!$verLocal -or $verLocal -ne $ver_online) {
				write-host "modify app version from $verLocal to $ver_online"
				rcedit-x64 "$app" --set-file-version $ver_online --set-product-version $ver_online
			}
			Move-Item $app -Destination $toLocation -Force
			if ($newName) {
				$name = Split-Path $app -Leaf
				$ext = split-path $app -Extension
				write-host "new name: $newName$ext"
				Rename-Item "$toLocation\$name" -NewName "$newName$ext"
			}
		}
		ri "$env:temp\temp" -Recurse -Force

	}
	return "$toLocation"

}