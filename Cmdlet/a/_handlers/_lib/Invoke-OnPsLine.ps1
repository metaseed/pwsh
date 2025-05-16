function Invoke-OnPsLine {
	[CmdletBinding()]
	param (
		# [Parameter()]
		# [switch]$isSelections,
		[Parameter()]
		[switch]$isChordTrigger,
		[Parameter()]
		[switch]$PassThru,
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

	$lastSelections = $onQuit.lastSelections
	if ($isChordTrigger) {
		# is selection
		if ($lastSelections) {
			$pathStr = ($lastSelections | % { "'$_'" }) -join ','
			if ($pathStr -ne $pathAtCursor) {
				[Microsoft.PowerShell.PSConsoleReadLine]::Insert($pathStr)
			}

			return
		}
		else { # working dir
			if ([string]::IsNullOrWhiteSpace($line) ) {
				if ("$lfWorkingDir" -ne "$pwd") {
					sl "$lfWorkingDir"
					[Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
					return
				}
			}
			else {
				$pathAtCursorIsDir = Test-Path -PathType Container $pathAtCursor
				if ($pathAtCursorIsDir) {
					# Show-MessageBox "$lfWorkingDir and $pwd"
					if ($lfWorkingDir -ne $pathAtCursor) {
						# replace dir it to $lfWorkingDir
						if($lfWorkingDir.contains(' ')) {
							$lfWorkingDir = "'$lfWorkingDir'"
						}
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
	}
	# from `lf` command
	else {
		if ($PassThru) {
			if ($lastSelections) {
				$pathStr = ($lastSelections | % { "'$_'" }) -join ','
				return $pathStr
			} else {
				return $lfWorkingDir
			}
		}
		else {
			if ($lfWorkingDir -ne $pwd) {
				sl "$lfWorkingDir"
				# [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
				return
			}
			else {
				#	do nothing #return $lfWorkingDir
			}
		}
	}

}
