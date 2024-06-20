function backup($appLocation, $restoreList, $appName) {
	gci $appLocation | % {
		$childName = $_.Name
		$any = $restoreList | ? { $childName -like $_ }
		if ($any) {
			Write-Verbose "restoreList $restoreList"

			$toL = "$env:temp\${appName}_backup"
			Write-Verbose "backukp $toL"
			if (!(test-path $toL)) {
				mkdir $toL >$null
			}
			Write-Action "backup: $($_.FullName) to $toL"
			Write-Execute {Copy-Item "$($_.FullName)" $toL -Recurse}
		}
	}
}

function restoreFrom($backupLocation, $info, $toLocation) {
	if (Test-Path $backupLocation) {
		$info.restoreList = @(Get-ChildItem $backupLocation)
		Write-Action "restore from $backupLocation to $toLocation"
		gci $backupLocation | % { Move-Item $_ $toLocation -Force }
		Write-Execute { Remove-Item $backupLocation }
	}
}

function Install-App {
	[CmdletBinding()]
	param($downloadedFilePath, $ver_online, $appName, $toLocation, [switch]$CreateFolder, [string]$newName, $verLocal, [switch]$pickExes,
		# folders or files in toLocation to backup and restore
		[string[]]$restoreList = @('_'))

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
		% {
			backup $_  $restoreList ($newName ? $newName : $appName)
		} |
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
	if ($downloadedFilePath -match '\.zip|\.zipx') {
		Expand-Archive $downloadedFilePath -DestinationPath "$env:temp\temp"
	}
	elseif ($downloadedFilePath -match '\.7z|\.rar') {
		$7z = "c:\app\7-zip\7z.exe"
		if ( test-path $7z) {
			Invoke-Expression "$7z x '$downloadedFilePath' -o$env:temp\temp"
		}
		else { write-error "can not find: $7z" }
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
		Write-Verbose "goto $($children[0].FullName)"
		$children = @(gci $children[0])
	}

	if (($children.count -ne 1 -and !$pickExes) -or $CreateFolder) {
		$name = $newName ? $newName : $appName
		$toLocation = "$toLocation\${name}"
		Write-Verbose "from location: $($children[0].Parent) to location: $toLocation"
		$children | % {Move-Item $_ -Destination $toLocation -Force}
		# _${ver_online}
		$info = @{version = "$ver_online" }
		# restore
		restoreFrom "$env:temp\${name}_backup"  $info  $toLocation
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
			Write-host "install app: $_"
			# $verLocal = if($app.VersionInfo) {$app.VersionInfo.ProductVersion ? $app.VersionInfo.ProductVersion : $app.VersionInfo.FileVersion}

			if ($verLocal) {
				$_.VersionInfo.ProductVersion -match "^[\d\.]+" > $null
				$verLocal = [Version]::new($Matches[0])
				write-host "new local version: $verLocal"

			}

			if (!$verLocal -or $verLocal -ne $ver_online) {
				write-host "modify app version from $verLocal to $ver_online"
				rcedit-x64 "$_" --set-file-version $ver_online --set-product-version $ver_online
			}
			$baseName = Split-Path $_ -LeafBase
			gps $baseName -ErrorAction SilentlyContinue|spps
			Move-Item $_ -Destination $toLocation -Force
			if ($newName) {
				$name = Split-Path $_ -Leaf
				$ext = split-path $_ -Extension
				write-host "new name: $newName$ext"
				Rename-Item "$toLocation\$name" -NewName "$newName$ext"
			}
		}
		ri "$env:temp\temp" -Recurse -Force

	}
	return "$toLocation"

}