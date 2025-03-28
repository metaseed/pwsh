# Show-MessageBox $env:fx
# "fullPath"`n"fullPath"
# "fullPath","fullPath"
$env:fx -split "," |
	% { split-path $_.trim('"') -leaf } |
	Set-Clipboard