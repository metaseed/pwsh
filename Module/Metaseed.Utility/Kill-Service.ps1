
function Kill-Service {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [Alias("proc")]
    [string[]]$processes,
    [int]$timeout = 5 # seconds to wait
  )
  
  Write-Information 'try to checking unstopped services...'
  $find = $false
  # Get-Service could not get ProcessID, and Get-Process could not return process where the service's status is StopPending
  Get-CimInstance win32_service |
  Where-Object { 
    foreach ($key in $processes) {
      if ($_.Name -like $key) {
        # have to use write-host in where script-block
        Write-Debug "find: $($_.Name)(pid: $($_.ProcessId)), state: $($_.State)" 
        if ($_.ProcessID -eq 0) { return $false } # 0: stopped service; if status is stopping, the id is not 0
        return $true 
      }
    } 
    return $false
  } | % -ThrottleLimit 10 -Parallel {
    $find = $true
    if ($_.State -eq 'Running') {
      Write-Information "stop service: $($_.Name)" 
      try {
        spsv $_.Name -Force -NoWait -ErrorAction SilentlyContinue
        $srv = gsv $_.Name
        try {
          $srv.WaitForStatus('Stopped', [timespan]::FromSeconds($timeout))
          if ($srv.Status -eq 'Stopped') {
            # "service stopped: $($_.Name)" 
            return 
          }
        }
        catch {
          Write-Warning "exception happens while waiting for service stop: $_"
        }
      }
      catch {
        Write-Warning "exception happens while stopping service: $_"
      }
    }
    Write-Warning "$($_.Name): may have problem, try to kill it..."
    Stop-Process -Force -Id $_.ProcessId -ErrorAction Continue
  }
  if (-not $find) {
    Write-Information "Good: no killing/stopping to $processes"
    return
  }

  start-sleep 1
  spsv $processes -Force -ErrorAction SilentlyContinue
}


