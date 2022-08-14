Register-EngineEvent -SourceIdentifier  'PSReadlineSessionScopeEvent' {
    $line = $event.SourceArgs.line
    $cursor = $event.SourceArgs.cursor

    $scope = $event.SourceArgs.scope
    $lastScope = $event.SourceArgs.lastScope
    Write-Debug "PSReadlineSessionScopeEvent: $scope, $lastScope, $line, $cursor"
    # cylically set last steps
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
  