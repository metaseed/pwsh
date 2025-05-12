param ($0) # $0 or any name is ok
# Show-MessageBox "the args[0]:$($args[0])" # we can not use name to reference the argument
$zipFiles = $env:fx -split ',' | % { $_.Trim('"') }
# Show-MessageBox "a$($args[0])a"
$outputFolder = if ($args[0]) { Resolve-Path $args[0] }

$zipFiles | % {
	$zipFile = $_
	$outputFolder ??= (Split-Path $zipFile -LeafBase)

	# Show-MessageBox "zipFile: $_, output:$outputFolder"
	if ($zipFile -match '\.zip|\.zipx') {
		Expand-Archive $zipFile -DestinationPath $outputFolder
	}
	elseif ($zipFile -match '\.7z|\.rar') {
		$7z = "c:\app\7-zip\7z.exe"
		if ( test-path $7z) {
			Invoke-Expression "$7z x '$zipFile' -o$outputFolder"
		}
		else { write-error "can not find: $7z" }
	}
	# the `tar` cmd can directly unzip several levels, but the 7z will create a folder with '.tar' from a '.tar.gz' zip file
	elseif ($zipFile -match '\.tar\.gz') {
		$outputFolder = $outputFolder -replace '.tar$', ''
		if (!(test-path $outputFolder)) {
			$null = ni $outputFolder -ItemType Directory
		}
		tar -xf $zipFile -C $outputFolder
	}
	elseif ($zipFile -match '\.tar\.xz') {
		$outputFolder = $outputFolder -replace '.tar$', ''

		if (!(test-path $outputFolder)) {
			$null = ni $outputFolder -ItemType Directory
		}
		tar -xf $zipFile -C $outputFolder
	}
	else {
		write-error "$zipFile is not a know compressed archive!"
		return
	}
	# write-host 'done!'
	c:\app\lf.exe -remote "send $env:id echomsg 'done'"
}