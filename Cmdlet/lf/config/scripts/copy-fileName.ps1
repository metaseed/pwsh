$file = ($env:f).trim('"')
$file -split "`n"|%{split-path $_ -leaf}|Set-Clipboard

