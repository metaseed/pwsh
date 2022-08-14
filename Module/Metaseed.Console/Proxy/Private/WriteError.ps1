function WriteError {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, position = 0)]
    [object]
    $err,
    [switch]$replay
  )
  if (! $replay) {
    WriteStepMsg @{type = 'Error'; message = $err; }
  }
  else {
    $indents = ' ' * (($__PSReadLineSessionScope.indents + 1) * $__IndentLength)
    $errMsg = "${indents}ERROR`n"
    $err.GetEnumerator() | % {
      $errMsg += "$indents$($_.Key): $($_.Value)`n"
    }
    Write-Host "$errMsg" -ForegroundColor Red
  }
}