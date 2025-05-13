<#
to create .zip file need to provide a name with .zip, if no extension, it will be .7z
if start with .xx mean we want use create a .xx file
#>

param ($0) # $0 or any name is ok
# Show-MessageBox "the args[0]:$($args[0])" # we can not use name to reference the argument
$zipFiles = @($env:fx -split ','|? {$_.Length})
# Show-MessageBox "$env:fx $($zipFiles.Length)"
# if($zipFiles.Length -eq 0) {$zipFiles = @($env:f)}
# Show-MessageBox "a$($args[0])a"

$zipName = $args[0]

function Name ($files) {

	if($files.Length -gt 1){
		$Name = Split-Path $env:pwd.Trim('"') -leaf

	} else {
		$file = $files[0].Trim('"')
		$result = & 7z t "$file" 2>&1
		if ($LASTEXITCODE -eq 0){ # zip file
			$Name = Split-Path $file -Leaf
		} else {
			$Name = Split-Path $file -LeafBase
		}
	}
	return $Name
}

if (!$zipName) { # empty: -> Name.7z
	$zipName = "'$(Name $zipFiles).7z'"
} elseif($zipName.StartsWith('.')) { # .xx: -> Name.xx
	$zipName = "'$(Name $zipFiles)$zipName'"
} # use the explicitly set name

$zipExist = test-path $zipName.trim("'")
$msg = "zipped file:"
if($zipExist) {
	$answer = read-host "updating the existing file: ${zipName}? (`e[93;44m<enter> for yes, <t> for time appending or any other inputs for appending`e[0m)?"
	if($answer -ne '') { # not updating
		if($answer -eq 't') {
			$appending = get-date -f yyMMdd_HHmmss
		}else {
			$appending = $answer
		}

		$lastDotIndex = $zipName.LastIndexOf('.')
		$zipName = $zipName.Substring(0, $lastDotIndex + 1) + "$appending." + $zipName.Substring($lastDotIndex + 1)
	} else {
		$msg = "updated zip file:"
	}
}

# Show-MessageBox "!!${zipName}!!"
# Show-MessageBox "7z a $zipName $($zipFiles -join ' ')"
# need to wait it finish: 7z a $zipName ($zipFiles -join ' ')
# start process is async, but `&` is sync and also stream the outputs
$files = @($zipFiles|%{$_ -replace '"',"'"}) -join ' '
#Show-MessageBox $files
# & 7z a $zipName @files


c:\app\lf.exe -remote "send $env:id echomsg 'zipping$('.' * 240)'"
Invoke-Expression "7z a $zipName $files"
c:\app\lf.exe -remote "send $env:id select $zipName"
c:\app\lf.exe -remote "send $env:id echomsg $msg $zipName"