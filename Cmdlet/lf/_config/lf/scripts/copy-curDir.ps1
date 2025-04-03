$env:pwd |
% {
	if ($_.Contains(' ')) {
		return $_
	}
	return $_.Trim('"')
}|
Set-Clipboard
c:\app\lf.exe -remote "send $env:id echomsg 'dir copied: $env:pwd'"