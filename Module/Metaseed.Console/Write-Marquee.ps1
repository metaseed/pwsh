<#
.SYNOPSIS
	Writes text as marquee
.DESCRIPTION
	This PowerShell script writes text as marquee.
.PARAMETER text
	Specifies the text to write
.PARAMETER speed
	Specifies the marquee speed (60 ms per default)
.EXAMPLE
	PS> ./write-marquee "Hello World"
#>
function Write-Marquee {
 param([string]$text, [int]$speed = 80, [string] $ForegroundColor = $HOST.UI.RawUI.ForegroundColor,
	 [string]$BackgroundColor = $HOST.UI.RawUI.BackgroundColor,
	 # -1: loop
	 [int] $Repeat = 1,
	 # width of the window
	 [int]$Width = 80
	)
	
	$appendLast = $text.Length -lt $Width ? (' ' * ($Width - $text.Length)) : ''
	$append = ' ' * $Width

	# clear-host
	Write-Output ""
	write-host "-$('-' * $Width)--"
	$StartPosition = $HOST.UI.RawUI.CursorPosition
	$StartPosition.X = 1
	write-host "|$(' ' * ($Width + 1))|"
	write-host "-$('-' * $Width)--"

	while ($Repeat) {
		if ($Repeat -eq 1) {
			$textDisplay = $append + $text + $appendLast
		}
		else {
			$textDisplay = $append + $text + $append
		}

		$Length = $textDisplay.Length
		$End = $Length - $Width
		foreach ($Pos in 1 .. $End) {
			$HOST.UI.RawUI.CursorPosition = $StartPosition
			start-sleep -milliseconds $speed
			$textToDisplay = $textDisplay.Substring($Pos, $Width)
			write-host -nonewline $textToDisplay -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
		}
		if ($Repeat -gt 0) {
			$Repeat--
		}
	}
	Write-Output ""
	Write-Output ""

}

# Write-Marquee "Hello World" -ForegroundColor green -Repeat 2 -Width 60
# Write-Marquee "write-host -nonewline textToDisplay -ForegroundColor ForegroundColor -BackgroundColor BackgroundColor PS M:\Script\Pwsh\Module\Metaseed.Console> " -ForegroundColor green -Repeat 2
