function Invoke-OnPsLine {
	[CmdletBinding()]
	param (
		[Parameter()]
		[switch]$isLastSelections,
		[Parameter()]
		[scriptblock] $dirScript = {
			param (
				$pathAtCursor, $inputLine, $cursorLeft, $cursorRight
			)
			$selectedPath = ''
			return  $selectedPath
		}
	)
	$leftCursor = $null
	$rightCursor = $null
	$line = $null
	$cursor = $null
	[Microsoft.PowerShell.PSConsoleReadline]::GetBufferState([ref]$line, [ref]$cursor)
	$pathAtCursor = Find-PsReadlinePath $line $cursor ([ref]$leftCursor) ([ref]$rightCursor)

	$onQuit = Invoke-Command -ScriptBlock $dirScript -ArgumentList $pathAtCursor, $line, $leftCursor, $rightCursor

	$dir = $onQuit.workingDir
	##
	## returned from lf UI
	##
	if (!(Test-Path -PathType Container "$dir")) {
		write-host "the returned path is not a dir: $dir, pathAtCursor:$pathAtCursor,line:$line,cursorLeft:$leftCursor,rightCursor:$rightCursor"
		return
	}

	if ($isLastSelections) {
		$lastSelections = $onQuit.lastSelections
		$pathStr = ($lastSelections|%{"'$_'"}) -join ','
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert($pathStr)
	}
	else {
		# handle dir
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
}