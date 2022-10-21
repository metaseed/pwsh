$file = ($env:f).trim('"')
$file -split ';'|%{split-path $_ -leaf}|Set-Clipboard

