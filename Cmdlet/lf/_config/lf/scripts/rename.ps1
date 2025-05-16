# Read-Host "`e[93mddsdf sdfds `e[0m"
$name = ($env:f).trim('"')
$name = Split-Path $name  -Leaf
$hasSpace = $name.Contains(' ')
if ($hasSpace) {
	$name = $name -replace ' ', '<space>'
	c:\app\lf.exe -remote "send $env:id push :rename<space>'$name'"
}
else {
	c:\app\lf.exe -remote "send $env:id push :rename<space>$name"
}