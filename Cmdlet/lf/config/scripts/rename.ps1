$name = ($env:f).trim('"')
$name = Split-Path $name  -Leaf
$name = $name -replace ' ', '<space>'

c:\app\lf.exe -remote "send $env:id push :rename<space>$name"