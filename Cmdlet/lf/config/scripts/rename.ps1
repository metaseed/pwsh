$name = ($env:f).trim('"')
$name = Split-Path $name  -Leaf
$name = $name -replace ' ', '<space>'
lf -remote "send $env:id push :rename<space>$name"