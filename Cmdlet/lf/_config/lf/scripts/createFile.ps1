param ($0) # $0 or any name is ok

# Show-MessageBox "the args[0]:$($args[0])" # we can not use name to reference the argument
$fileName = $args -join ' '
# Show-MessageBox $fileName
$dir = $env:pwd.trim('"')
$filePath = Join-Path $dir $fileName.trim(' ')
# write-host $filePath
$fileName = read-host "file name: "
# Show-MessageBox $filePath
$null = ni -ItemType File $filePath

if ($error) {
	#Show-MessageBox $error
	c:\app\lf.exe -remote "send $env:id echoerr `"error: $error`""
}
else {
	c:\app\lf.exe -remote "send $env:id select `"$fileName`""
	c:\app\lf.exe -remote "send $env:id echomsg 'file created: $filePath'"
}
