param ($0) # $0 or any name is ok

# Show-MessageBox "the args[0]:$($args[0])" # we can not use name to reference the argument
$dirName =  $args -join ' '
# Show-MessageBox $dirName
$dir = $env:pwd.trim('"')
$dirPath = Join-Path $dir $dirName
# write-host $dirPath
# Show-MessageBox $dirPath
$null = ni -ItemType Directory $dirPath

if ($error) {
	#Show-MessageBox $error
	c:\app\lf.exe -remote "send $env:id echoerr `"error: $error`""
}
else {
	c:\app\lf.exe -remote "send $env:id select `"$dirName`""
	c:\app\lf.exe -remote "send $env:id echomsg 'dir created: $dirPath'"
}
