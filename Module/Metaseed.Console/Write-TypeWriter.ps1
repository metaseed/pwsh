<#
.SYNOPSIS
	Writes text with the typewriter effect
.DESCRIPTION
	This PowerShell script writes text with the typewriter effect.
.PARAMETER text
	Specifies the text to write
.PARAMETER speed
	Specifies the speed (250 ms by default)
.EXAMPLE
	write-typewriter "Hello World"
#>
function Write-Typewriter {
  param([string]$text = "Hello World!", [int]$speed = 250) # in milliseconds

  try {
    $Random = New-Object System.Random

    $text -split '' | ForEach-Object {
      write-host -nonewline $_
      start-sleep -milliseconds $(1 + $Random.Next($speed))
    }
    write-host ""
  }
  catch {
    "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
  }

}
# write-typewriter