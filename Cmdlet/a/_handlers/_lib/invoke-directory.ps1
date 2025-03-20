function Invoke-Directory([scriptblock] $dirScript = {
	param (
		$pathAtCursor, $inputLine, $cursorLeft, $cursorRight
	)
	$selectedPath = ''
	return  $selectedPath
}) {
	$leftCursor = $null
	$rightCursor = $null
	$line = $null
	$cursor = $null
	[Microsoft.PowerShell.PSConsoleReadline]::GetBufferState([ref]$line, [ref]$cursor)
	$pathAtCursor = Find-PsReadlinePath $line $cursor ([ref]$leftCursor) ([ref]$rightCursor)

	$dir = Invoke-Command -ScriptBlock $dirScript -ArgumentList $pathAtCursor, $line, $leftCursor, $rightCursor

	##
	## returned from lf UI
	##
	if (!(Test-Path -PathType Container "$dir")) {
		write-host "the returned path is not a dir: $dir, pathAtCursor:$pathAtCursor,line:$line,cursorLeft:$leftCursor,rightCursor:$rightCursor"
		return
	}

	if (("$dir" -ne "$pwd") -and [string]::IsNullOrWhiteSpace($line)) {
		sl "$dir"
		[Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
	}
	else {
		$isPath = Test-Path -PathType Container "$pathAtCursor"
		if ($isPath) {
			[Microsoft.PowerShell.PSConsoleReadLine]::Replace($leftCursor, $rightCursor - $leftCursor + 1, $dir)
		}
		else {
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($dir)
		}
		#return [Microsoft.PowerShell.PSConsoleReadLine]::Insert($dir)
	}
}