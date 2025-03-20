<#
.SYNOPSIS
    Extracts a path or string from the command line at the current cursor position.

.DESCRIPTION
    This function analyzes the PowerShell command line to identify a path or string at the current cursor position.
    It handles quoted strings (both single and double quotes) and determines the boundaries of the text.

.PARAMETER line
    The current command line text.

.PARAMETER cursor
    The current cursor position within the command line.

.PARAMETER leftCursor
    A reference parameter that will be set to the left boundary position of the identified text.

.PARAMETER rightCursor
    A reference parameter that will be set to the right boundary position of the identified text.

.OUTPUTS
    Returns the extracted path or string with quotes removed, or $null if no valid text is found.

.EXAMPLE
    $line = "Get-Content 'C:\path\to\file.txt'"
    $cursor = 15
    $left = [ref]0
    $right = [ref]0
    $path = Find-PsReadlinePath -line $line -cursor $cursor -leftCursor $left -rightCursor $right
    # $path will contain "C:\path\to\file.txt"
	$line.Substring($left.value, $right.value-$left.value+1)
	# 'C:\path\to\file.txt'
#>
function Find-PsReadlinePath {
	param([string]$line,[int]$cursor,[ref]$leftCursor,[ref]$rightCursor)

	if ($line.Length -eq 0) {
		$leftCursor.Value = $rightCursor.Value = 0
		return ''
	}

	if ($cursor -ge $line.Length) {
		$leftCursorTmp = $cursor - 1
	} else {
		$leftCursorTmp = $cursor
	}

	:leftSearch for (;$leftCursorTmp -ge 0;$leftCursorTmp--) {
		if ([string]::IsNullOrWhiteSpace($line[$leftCursorTmp])) {
			if (($leftCursorTmp -lt $cursor) -and ($leftCursorTmp -lt $line.Length-1)) {
				$leftCursorTmpQuote = $leftCursorTmp - 1
				$leftCursorTmp = $leftCursorTmp + 1
			} else {
				$leftCursorTmpQuote = $leftCursorTmp
			}
			for (;$leftCursorTmpQuote -ge 0;$leftCursorTmpQuote--) {
				if (($line[$leftCursorTmpQuote] -eq '"') -and (($leftCursorTmpQuote -le 0) -or ($line[$leftCursorTmpQuote-1] -ne '"'))) {
					$leftCursorTmp = $leftCursorTmpQuote
					break leftSearch
				}
				elseif (($line[$leftCursorTmpQuote] -eq "'") -and (($leftCursorTmpQuote -le 0) -or ($line[$leftCursorTmpQuote-1] -ne "'"))) {
					$leftCursorTmp = $leftCursorTmpQuote
					break leftSearch
				}
			}
			break leftSearch
		}
	}
	:rightSearch for ($rightCursorTmp = $cursor;$rightCursorTmp -lt $line.Length;$rightCursorTmp++) {
		if ([string]::IsNullOrWhiteSpace($line[$rightCursorTmp])) {
			if ($rightCursorTmp -gt $cursor) {
				$rightCursorTmp = $rightCursorTmp - 1
			}
			for ($rightCursorTmpQuote = $rightCursorTmp+1;$rightCursorTmpQuote -lt $line.Length;$rightCursorTmpQuote++) {
				if (($line[$rightCursorTmpQuote] -eq '"') -and (($rightCursorTmpQuote -gt $line.Length) -or ($line[$rightCursorTmpQuote+1] -ne '"'))) {
					$rightCursorTmp = $rightCursorTmpQuote
					break rightSearch
				}
				elseif (($line[$rightCursorTmpQuote] -eq "'") -and (($rightCursorTmpQuote -gt $line.Length) -or ($line[$rightCursorTmpQuote+1] -ne "'"))) {
					$rightCursorTmp = $rightCursorTmpQuote
					break rightSearch
				}
			}
			break rightSearch
		}
	}
	if ($leftCursorTmp -lt 0 -or $leftCursorTmp -gt $line.Length-1) { $leftCursorTmp = 0}
	if ($rightCursorTmp -ge $line.Length) { $rightCursorTmp = $line.Length-1 }
	$leftCursor.Value = $leftCursorTmp
	$rightCursor.Value = $rightCursorTmp
	$str = -join ($line[$leftCursorTmp..$rightCursorTmp])
	return $str.Trim("'").Trim('"')
}
