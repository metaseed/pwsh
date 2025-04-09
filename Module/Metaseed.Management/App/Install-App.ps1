function backup($appLocation, $restoreList) {
	$name = split-path $appLocation -leaf
	$toL = "$env:temp\${name}_backup"
	if (!(test-path $toL)) {
		mkdir $toL >$null
	}
	Write-Verbose "backup to: $toL with restoreList $restoreList"

	gci $appLocation | % {
		$childName = $_.Name # with ext
		$any = $restoreList | ? { $childName -like $_ }
		if ($any) {
			Write-Action "backup: $($_.FullName) to $toL, filter: $any"
			Write-Execute { Copy-Item "$($_.FullName)" $toL -Recurse }
		}
	}
}

function restoreFrom($toLocation, $name) {
	$backupLocation = "$env:temp\${name}_backup"

	if (Test-Path $backupLocation) {
		Write-Action "restore from $backupLocation to $toLocation"
		gci $backupLocation | % { Move-Item $_ $toLocation -Force }
		# Write-Execute { Remove-Item $backupLocation -Recurse }
	}
}

function Install-App {
	[CmdletBinding()]
	param(
		$downloadedFilePath,
		$ver_online,
		$appName,
		# folder to store the app
		$toLocation,
		$CreateFolder,
		# one exe: rename the exe file to new name
		# zip: new folder name
		[string]$newName,
		$verLocal,
		# just pickup the files from downloaded files in zip, not folders
		[string[]]$filesToPickup,
		# folders or files in toLocation to backup and restore
		[string[]]$restoreList = @('_'))

	$name = $newName ? $newName : $appName
	Write-Host "Install $appName from $downloadedFilePath"
	## stop app
	$app = "$toLocation\$name.exe"
	gps $name -ErrorAction SilentlyContinue |% {
		Write-Host "force stop app $name"
		spps $_ -Force
	}

	## backup files and delete app
	Wait-Process -Name $name -ErrorAction SilentlyContinue
	if (test-path $app) {
		ri $app -force
	}
	else {
		if (test-path "$toLocation\$name") {
			gi "$toLocation\$name" |
			% {
				backup $_  $restoreList
				# ignore error, may not exist
				Remove-Item $_ -Recurse -Force
			}
		}
	}
	### is exe file
	# Write-Host "to location: $toLocation"
	if ($downloadedFilePath -match '\.exe$') {
		Move-Item $downloadedFilePath -Destination $toLocation -Force
		if ($newName) {
			$exe = Split-Path $downloadedFilePath -Leaf
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
	elseif ($downloadedFilePath -match '\.tar\.xz') {
		if (!(test-path $env:temp\temp)) {
			$null = ni $env:temp\temp -ItemType Directory
		}
		tar -xf $downloadedFilePath -C "$env:temp\temp"
	}
	else {
		write-error "$downloadedFilePath is not a know compressed archive!"
		break
	}

	## install
	$children = @(gci "$env:temp\temp")
	while ($children.Count -eq 1 -and $children[0].PSIsContainer) {
		Write-Verbose "goto $($children[0].FullName)"
		$children = @(gci $children[0])
	}

	# many children and no need to pickup
	if (($children.count -ne 1 -and !$filesToPickup) -or $CreateFolder) {
		$toLocation = "$toLocation\${name}"
		Write-Verbose "from location: $($children[0].Parent) to location: $toLocation"
		$from = $children[0].PSParentPath

		Move-Item $from -Destination $toLocation -Force
		# _${ver_online}
		$info = @{version = "$ver_online" }
		# restore
		restoreFrom $toLocation $name
		$info | ConvertTo-Json | Set-Content -path "$toLocation\info.json" -force
	}
	else {
		# need pickup
		if ($filesToPickup) {
			$app = gci -Recurse -include $filesToPickup "$env:temp\temp\*"
		}
		# only one file: *.exe
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
			gps $baseName -ErrorAction SilentlyContinue | spps
			Move-Item $_ -Destination $toLocation -Force

			if ($newName -and (app.count -eq 1)) {
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