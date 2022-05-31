function WriteWarning {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, position = 0)]
    [object]
    $warning,
    [switch]$replay
  )
  if (! $replay) {
    WriteStepMsg @{type = 'Warning'; message = $warning; }
  }
  else {
    $indents = ' ' * (($__Session.indents + 1) * $__IndentLength)
    $msg = "${indents}Warning`n"
    $warning.GetEnumerator() | % {
      $msg += "$indents$($_.Key): $($_.Value)`n"
    }
    Write-Host "$msg" -ForegroundColor Yellow
  }
}

# Write-step 'ddd';write-substep 'kkk'; Write-Warning 'iii';