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

c:\app\lf.exe -remote "send $env:id echomsg 'path copied: $env:fx'"
