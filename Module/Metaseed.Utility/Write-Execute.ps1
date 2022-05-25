function Write-Execute {
  <#
  .SYNOPSIS
  Write command to execute and excute command; if error then Exit
  #>
  param (
    [string]$command,
    [string]$message,
    [switch]$noThrow
  )
  process {
    # Write-Progress -Activity "${command}" -status "$('' -eq $message ? ' ': ": $message")" -Id 2 -ParentId 0
    $icon = $env:WT_SESSION ? '-->': '―→'
    Write-Host " $icon ${command} $('' -eq $message ? '': ": $message")" -ForegroundColor Blue
    # note: if put parenthesis around: return (iex $command), the output would be no color
    # i.e. Write-Execute 'git status', if there are modification, no red text for modification files
    return iex $command
  }
  end {
    if (0 -ne $LASTEXITCODE) {
      Write-Error "Error execute command: $command"
      if ($noThrow) {
        Exit
      } else {
        throw
      }
    }
  }
}