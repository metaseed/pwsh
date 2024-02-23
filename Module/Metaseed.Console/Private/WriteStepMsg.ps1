function WriteStepMsg($msg) {
  if ($__PSReadLineSessionScope.lazyStepsInit ) {
    # only clear steps when we call the write-* function in a new interaction, so we can always show last steps, even we run some command that not use write-* after that.
    $__PSReadLineSessionScope.lazyStepsInit = $null
    # clear stored last step values, and do new init
    $__PSReadLineSessionScope.Steps = @()
  }
  # initally is $null; the module register the event when its function is used, so the first session may not receive event, but we know steps is null and not last session
  if($null -eq $__PSReadLineSessionScope.Steps) {
    $__PSReadLineSessionScope.Steps = @()
  }
  $__PSReadLineSessionScope.Steps += $msg
}