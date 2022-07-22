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
function Write-Animate {
  param($Line1 = "", $Line2 = "", $Line3 = "", $Line4 = "", $Line5 = "", $Line6 = "", $Line7 = "", $Line8 = "", $Line9 = "", [int]$Speed = 30, 
    [ValidateSet('start', 'center', 'end')]
    [string]$position = 'center')


  if ($Line1 -eq "") {
    $Line1 = 
    $Line2 = " "
    $Line3 = 
    $Line4 = " "
    $Line5 = "Best regards,"
    $Line6 = "--metasong"
  }
  write-host ""
  WriteLine $Line1 $Speed
  WriteLine $Line2 $Speed
  WriteLine $Line3 $Speed
  WriteLine $Line4 $Speed
  WriteLine $Line5 $Speed -position end
  WriteLine $Line6 $Speed -position end
  WriteLine $Line7 $Speed
  WriteLine $Line8 $Speed
  WriteLine $Line9 $Speed
  write-host ""

}

function Write-Animate { 
  param(
    [string]$Line,
    [ValidateSet('start', 'center', 'end')]
    [string]$position = 'center',
    [int]$Speed = 30,
    [string]$ForegroundColor = $HOST.UI.RawUI.ForegroundColor,
    [string]$BackgroundColor = $HOST.UI.RawUI.BackgroundColor
  )

  if($line -eq '') {
    Write-Animate "Welcome to metaseed pwsh script world"
    Write-Host ''
    Write-Animate "This repository contains useful and PowerShell scripts."
    Write-Host ''
    Write-Host ''
    Write-Animate "please gave the text to animate" 'start' -ForegroundColor blue
    Write-Host ''
    Write-Host ''
    Write-Animate "regards," 'end'
    Write-Animate "--metasong" 'end'
    return
  }

  $TerminalWidth = $Host.UI.RawUI.WindowSize.Width # characters

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