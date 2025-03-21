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

	$lfWorkingDir = $onQuit.workingDir
	##
	## returned from lf UI
	##
	if (!(Test-Path -PathType Container "$lfWorkingDir")) {
		write-host "the returned path is not a dir: $lfWorkingDir, pathAtCursor:$pathAtCursor,line:$line,cursorLeft:$leftCursor,rightCursor:$rightCursor"
		return
	}

	if ($isLastSelections) {
		$lastSelections = $onQuit.lastSelections
		$pathStr = ($lastSelections | % { "'$_'" }) -join ','
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert($pathStr)
	}
	else {
		# empty line
		if ([string]::IsNullOrWhiteSpace($line)) {
			# and not the same dir then switch
			if ("$lfWorkingDir" -ne "$pwd") {
				sl "$lfWorkingDir"
				[Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
			}
		}
		# something online
		else {
			$isDir = Test-Path -PathType Container "$pathAtCursor"
			if ($isDir) {
				if ("$lfWorkingDir" -ne "$pwd") {
					[Microsoft.PowerShell.PSConsoleReadLine]::Replace($leftCursor, $rightCursor - $leftCursor + 1, $lfWorkingDir)
				}
			}
			# not a dir
			else {
				[Microsoft.PowerShell.PSConsoleReadLine]::Insert($lfWorkingDir)
			}
		}
	}
}