$env:pwd |
% {
	if ($_.Contains(' ')) {
		return $_
	}
	return $_.Trim('"')
}|
Set-Clipboard