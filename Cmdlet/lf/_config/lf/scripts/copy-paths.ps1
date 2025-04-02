# Show-MessageBox $env:fx
# "`n"
$env:fx -split ',' |
% {
	if ($_.Contains(' ')) {
		return $_
	}
	return $_.Trim('"')
}|
Set-Clipboard