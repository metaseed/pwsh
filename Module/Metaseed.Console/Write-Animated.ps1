<#
.SYNOPSIS
  Writes animated text
.DESCRIPTION
  This PowerShell script writes animated text.
.EXAMPLE
  write-animated "Hello World"
  write-animated "Hello World" -position start
  write-animated "Hello World" -position end
#>
function Write-Animated { 
  param(
    [string]$Line,
    [ValidateSet('start', 'center', 'end')]
    [string]$position = 'start',
    [int]$Speed = 30,
    # forely set a small width, if your terminal is too wide.
    [int]$TerminalWidth = $Host.UI.RawUI.WindowSize.Width,
    [string]$ForegroundColor = $HOST.UI.RawUI.ForegroundColor,
    [string]$BackgroundColor = $HOST.UI.RawUI.BackgroundColor
  )

  if($line -eq '') {
    Write-Animated "Welcome to metaseed pwsh script world"
    Write-Host ''
    Write-Animated "This repository contains useful and PowerShell scripts."
    Write-Host ''
    Write-Host ''
    Write-Animated "please gave the text to animate" 'start' -ForegroundColor blue
    Write-Host ''
    Write-Host ''
    Write-Animated "regards," 'end'
    Write-Animated "--metasong" 'end'
    return
  }

  $StartPosition = $HOST.UI.RawUI.CursorPosition

  if ($Line -eq "") { return }
  foreach ($Pos in 1 .. $line.Length) {
    # always write to the center of the TerminalWith
    if ($position -eq 'start') {
      $TextToDisplay = $Line.Substring(0, $Pos)
    }
    elseif ($position -eq 'end') {
      $text = $Line.Substring(0, $Pos)
      $TextToDisplay = ' ' * ($TerminalWidth - $text.length) + $text
    }
    else {
      $TextToDisplay = ' ' * ($TerminalWidth / 2 - $pos / 2) + $Line.Substring(0, $Pos)
    }
    write-host -nonewline $TextToDisplay -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    start-sleep -milliseconds $Speed
    $HOST.UI.RawUI.CursorPosition = $StartPosition
  }
  Write-Host ''
}