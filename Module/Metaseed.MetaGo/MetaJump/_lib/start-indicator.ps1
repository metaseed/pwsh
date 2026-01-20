function IsFirstCharOfLine($Info){
    return $Info.Cursor -eq 0 -or $Info.Line.Substring(0, $Info.Cursor).LastIndexOf("`n") -eq $Info.Cursor - 1
}
function Show-StartIndicator {
	param($Info, [string]$icon = "🏃")

	# the 🏃is 2 char width, so move back 1 char or better ui view
	$len = $icon.Length
	$halfLen = [Math]::Floor($len / 2)

	$drawLeft = if (IsFirstCharOfLine $Info){ $Info.ConsoleLeft } else { $Info.ConsoleLeft - $halfLen }
	[Console]::SetCursorPosition($drawLeft, $Info.ConsoleTop)
	[Console]::Write($icon)
	[Console]::SetCursorPosition($Info.ConsoleLeft, $Info.ConsoleTop) # Restore cursor
	# write-host "Show-StartIndicator"
	return $icon.Length
}

function Restore-StartIndicator {
	param($Info, $len=2) # len is used of the icon

	$drawLeft = $Info.ConsoleLeft
	$restoreText = $Info.Line[$Info.Cursor..($Info.Cursor + $len - 1)]

	if (-not (IsFirstCharOfLine $Info)) {
		$halfLen = [Math]::Floor($len / 2)
		$drawLeft = $Info.ConsoleLeft - $halfLen
		$restoreText = $Info.Line[($Info.Cursor - $halfLen)..($Info.Cursor + $len - $halfLen - 1)]
	}
	[Console]::SetCursorPosition($drawLeft, $Info.ConsoleTop)

	# Restore 2 chars (width of runner)
	[Console]::Write([string]::new($restoreText))
	[Console]::SetCursorPosition($Info.ConsoleLeft, $Info.ConsoleTop)
}