function Write-Blinking {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $text
  )
  
  Write-Output "`e[5;36m$text`e[0m";
}