# Show-MessageBox $env:fx
# "fullPath"`n"fullPath"
$env:fx -split "`n" |
	% { split-path $_.trim('"') -leaf } |
	Set-Clipboard