Function Sleep-Computer {
  <#
  .SYNOPSIS
  Place your computer into Sleep mode
  .DESCRIPTION
  Since there is not a cmdlet that will 'sleep' your computer, the Sleep-Computer function was born. You can use
  the force option to override/clear your hibernate setting and then sleep if you need to...
  .EXAMPLE
  Sleep-Computer -WhatIf
  What if: Performing operation “Sleep-Computer” on Target Computer.
  .EXAMPLE
  Sleep-Computer -Confirm -Force
  Confirm
  Are you sure you want to perform this action?
  Performing operation “Sleep-Computer” on Target “V-RONEES-W8MBP”.
  [Y] Yes [A] Yes to All [N] No [L] No to All [S] Suspend [?] Help (default is “Y”):
  #>
  [cmdletbinding(SupportsShouldProcess = $True, ConfirmImpact = “Low”)]
  param (
    [parameter()][switch]$Force
  )

  if ($pscmdlet.ShouldProcess($env:COMPUTERNAME)) {
    if ($Force.IsPresent) {
      if ($pscmdlet.ShouldProcess(“Turning off hibernation”)) {
        & powercfg -hibernate off
      }
    }

    $rundll = Join-Path -Path ($env:windir) -ChildPath “System32\rundll32.exe”
    & ($rundll) powrprof.dll, SetSuspendState 0, 1, 0
  }
}