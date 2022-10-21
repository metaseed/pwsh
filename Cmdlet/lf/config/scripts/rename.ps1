$name = ($env:f).trim('"')
$name = Split-Path $name  -Leaf
$name = $name -replace ' ', '<space>'
&"$env:MS_App\lf\lf.exe" -remote "send $env:id push :rename<space>$name"
