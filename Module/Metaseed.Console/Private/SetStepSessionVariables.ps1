Register-EngineEvent -SourceIdentifier  'SessionScopeEvent' {
    $line = $event.SourceArgs.line
    # $cursor = $event.SourceArgs.cursor
    $scope = $event.SourceArgs.scope
    $lastScope = $event.SourceArgs.lastScope
    # Write-host "SessionScopeEvent: $scope, $line, $cursor"
    $scope.Steps  = $lastScope.Steps
    $scope.lazyStepsInit = $true
    # if ($line -match '^\s*(Show-Steps|ss$)') {
    #   # if is the Show-Steps command, then not clear the Steps value of the session
    #   $scope.Steps  = $lastScope.Steps
    # }
    # else {
    #   $scope.Steps = @()
    # }
  }
  