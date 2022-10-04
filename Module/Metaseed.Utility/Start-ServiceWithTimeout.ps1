function Start-ServiceWithTimeout {
[CmdletBinding()]
param (
    [Parameter()]
    [object]
    $service,
    $timeoutSeconds)
  #  write-host "ddd$timeoutSeconds $service"

  $timeSpan = New-Object Timespan 0, 0, $timeoutSeconds
  if ($service -isnot [ServiceProcess.ServiceController]) {
    $service = gsv $service
  }
  Write-Host "Starting Service: $($service.Name) (${timeoutSeconds}s)"
  if ($service.Status -like '*stop*') {
    $service.Start()
    try {
      $service.WaitForStatus([ServiceProcess.ServiceControllerStatus]::Running, $timeSpan)
      write-host "started: $($service.Name)!" -ForegroundColor Green
    }
    catch {
      Write-Warning "service ($($service.Name) is not started within $timeoutSeconds"
    }
  }
}