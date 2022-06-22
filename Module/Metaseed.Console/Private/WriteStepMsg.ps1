function WriteStepMsg($msg) {
  if ($__Session.lazyStepsInit ) {
    # only clear steps when we call the write-* function, so we can always show last steps, even we run some command that not use write-* after that.
    $__Session.lazyStepsInit = $null
    # clear stored last step values
    $__Session.Steps = @()
  }
  # initally is $null; the module register the event when its function is used, so the first session may not receive event, but we know steps is null and not last session
  if($null -eq $__Session.Steps) {
    $__Session.Steps = @()
  }
  $__Session.Steps += $msg
}