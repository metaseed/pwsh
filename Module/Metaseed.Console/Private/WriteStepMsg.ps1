function WriteStepMsg($msg) {
  if ($__Session.lazyStepsInit ) {
    $__Session.lazyStepsInit = $null
    $__Session.Steps = @()
  }
  if($null -ne $__Session.Steps) {
    $__Session.Steps += $msg
  }
}