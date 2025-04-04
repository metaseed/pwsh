function Invoke-OnPsLine {
	[CmdletBinding()]
	param (
		[Parameter()]
		[switch]$isSelections,
		[Parameter()]
		[switch]$isDir,
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

	# from `ctrl+s`
	if ($isSelections) {
		$lastSelections = $onQuit.lastSelections
		if($lastSelections) {
			$pathStr = ($lastSelections | % { "'$_'" }) -join ','
			if ($pathStr -ne $pathAtCursor) {
				[Microsoft.PowerShell.PSConsoleReadLine]::Insert($pathStr)
			}
		}
		return
	}
	# from `ctrl+d`
	elseif ($isDir) {
		if ([string]::IsNullOrWhiteSpace($line) ) {
			if ("$lfWorkingDir" -ne "$pwd") {
				sl "$lfWorkingDir"
				# [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
				return
			}
		}
		else {
			$pathAtCursorIsDir = Test-Path -PathType Container $pathAtCursor
			if ($pathAtCursorIsDir) {
				# Show-MessageBox "$lfWorkingDir and $pwd"
				if ($lfWorkingDir -ne $pathAtCursor) {
					# replace dir it to $lfWorkingDir
					[Microsoft.PowerShell.PSConsoleReadLine]::Replace($leftCursor, $rightCursor - $leftCursor + 1, $lfWorkingDir)
					return
				}
			}
			# not a dir
			else {
				if ($isDir -or $isSelections) {
					[Microsoft.PowerShell.PSConsoleReadLine]::Insert($lfWorkingDir)
				}
			}
		}
	}
	# from `lf` command
	else {
		# Show-MessageBox "line: $line"
		if ('lf' -eq $line) {
			# Show-MessageBox "lf working dir: $lfWorkingDir"
			# and not the same dir then switch
			if ($lfWorkingDir -ne $pwd) {
				sl "$lfWorkingDir"
				# [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
				return
			}
			else {
				#	do nothing #return $lfWorkingDir
			}
		}
		# something not 'lf' on line
		else {
			return $lfWorkingDir
		}
	}

}
