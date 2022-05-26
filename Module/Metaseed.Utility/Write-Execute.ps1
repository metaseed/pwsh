function Write-Execute {
  <#
  .SYNOPSIS
  Write command to execute and excute command; if error then Exit
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$command,
    [Parameter( Position = 1)]
    [string]$message,
    [switch]$noThrow,
    [switch]$replay = $false
  )
  process {
    if (! $replay) {
      $__Session.Steps += @{type = 'Execute'; message = $message; command = $command }
    }

    # Write-Progress -Activity "${command}" -status "$('' -eq $message ? ' ': ": $message")" -Id 2 -ParentId 0
    $icon = $env:WT_SESSION ? '-->': '―→'
    $execute = $__Session.execute++

    $indents = ' ' * (($__Session.indents + 1) * $__IndentLength)
    $msg = "${command} $('' -eq $message ? '': ": $message")"

    Write-Host "${indents}:Execute$execute$icon $msg" -ForegroundColor Blue
    if ($replay) {
      return
    }
    # note: if put parenthesis around: return (iex $command), the output would be no color
    # i.e. Write-Execute 'git status', if there are modification, no red text for modification files
    return iex $command
  }
  end {
    if (0 -ne $LASTEXITCODE) {
      Write-Error "Error execute command: $command"
      if ($noThrow) {
        Exit
      }
      else {
        throw
      }
    }
  }
}