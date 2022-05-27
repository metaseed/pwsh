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
    $msg = "${command} $('' -eq $message ? '': ": $message")"
    Write-Action $msg $replay
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
