function WriteStepMsg($msg) {
  if ($__Session.lazyStepsInit ) {
    $__Session.lazyStepsInit = $null
    $__Session.Steps = @()
  }
  $__Session.Steps += $msg
}