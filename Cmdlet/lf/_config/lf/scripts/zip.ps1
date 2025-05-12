<#
to create .zip file need to provide a name with .zip, if no extension, it will be .7z
if start with .xx mean we want use create a .xx file
#>

param ($0) # $0 or any name is ok
# Show-MessageBox "the args[0]:$($args[0])" # we can not use name to reference the argument
$zipFiles = $env:fx -split ','
if($zipFiles.Length -eq 0) {$zipFiles = @($env:f)}

# Show-MessageBox "a$($args[0])a"
$zipName = $args[0]

function Name ($files) {
	if($files.Length -gt 1){
		$Name = Split-Path $env:pwd.Trim('"') -leaf
	} else {
		$Name = Split-Path $env:f.Trim('"') -LeafBase
	}
	return $Name
}


if (!$zipName) { # empty: -> Name.7z
	$zipName = "$(Name $zipFiles).7z"
} elseif($zipName.StartsWith('.')) { # .xx: -> Name.xx
	$zipName = "$(Name $zipFiles)$zipName"
} # use the explicitly set name

# Show-MessageBox "7z a $zipName $($zipFiles -join ' ')"
# need to wait it finish: 7z a $zipName ($zipFiles -join ' ')
# start process is async, but `&` is sync and also stream the outputs
& 7z -- a $zipName ($zipFiles -join ' ')

c:\app\lf.exe -remote "send $env:id echomsg 'zipped $zipName!'"

c:\app\lf.exe -remote "send $env:id select `"$zipName`""