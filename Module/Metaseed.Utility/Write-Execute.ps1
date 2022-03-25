function Write-Execute {
  <#
  .SYNOPSIS
  Write command to execute and excute command; if error then Exit
  #>
  param (
    [string]$command,
    [string]$message
  )
  process {
    Write-Host "${command} $('' -eq $message ? '': ": $message")" -BackgroundColor blue -ForegroundColor yellow 
    # note: if put parenthesis around: return (iex $command), the output would be no color
    # i.e. Write-Execute 'git status', if there are modification, no red text for modification files
    return iex $command
  }
  end {
    if (0 -ne $LASTEXITCODE) {
      Write-Error "Error execute command: $command"
      Exit
    }
  }
}