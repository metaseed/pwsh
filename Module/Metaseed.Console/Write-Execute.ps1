function Write-Execute {
  <#
  .SYNOPSIS
  Write command to execute and excute command; if error then Exit
  .Notes
  we could use -ErrorAction SilentlyContinue to ignore all error
  .OUTPUTS
  -nothrow -nostop: check 0 -ne $LASTEXITCODE
  or stop execute if without -nostop
  or throw exception if without -nothrow
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'stringCmd')]
    [string]$command,
    [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'scriptBlock')]
    [scriptblock]$script,
    [Parameter( Position = 1)]
    [string]$message,
    [switch]$noThrow,
    # to get output msg when error into a variable, or continue execution and test errors
    [switch]$noStop,
    [switch]$replay = $false
  )
  process {
    $msgIcon = $env:WT_SESSION ?  "💬:": "@:"
    $exe = $command ? $command : $script.ToString().Trim()
    $msg = "$exe $($message ? "$msgIcon $message": '')"
    Write-Action $msg $replay
    # note: if put parenthesis around: return (iex $command), the output would be no color
    # i.e. Write-Execute 'git status', if there are modification, no red text for modification files
    if ($command) {
      return iex $command
    }
    else {
      return & $script
    }
  }
  end {
    if (0 -ne $LASTEXITCODE) {
      $errorMsg = "Error execute command: $exe"
      if ($noThrow) {
        if ($noStop) {
          Write-Error $errorMsg
        }
        else {
          # note we can catch the error in the catch block if the -erroraction is set to stop
          Write-Error $errorMsg -ErrorAction stop
        }
      }
      else {
        Write-Error $errorMsg
        throw
      }
    }
  }
}

# $a = Write-Execute { git pu } -noThrow -noStop 2>&1
# write-host "ttt: $a"