<#
.SYNOPSIS
Show messaage box

.EXAMPLE
# Message box with custom message, OK button only, and default title and icon
$null = Show-MessageBox 'some message'

# Message box with custom message and title, buttons OK and cancel, and
# the Stop icon (critical error)
# Return value is the name of the button chosen.
$buttonChosen = Show-MessageBox 'some message' 'a title' -Buttons OKCancel -Icon Stop

.NOTES
On macOS, AppleScript's display alert command is used to create the message box.

While this command nominally distinguishes between severities informational, warning, and critical, the former two show the same icon - a folder - and the latter overlays the folder icon only with an exclamation mark.
For cross-platform consistency the output value is a string, namely the name of the button pressed by the user.

-DefaultButtonIndex is the 0-based index of the button that will be pressed when the user just presses Enter.

Windows: If a Cancel button is present, Esc presses it.
macOs: If a No, Abort or Cancel button is present and it isn't the default button, Esc presses it.
#>
function Show-MessageBox {
  [CmdletBinding(PositionalBinding=$false)]
  param(
    [Parameter(Mandatory, Position=0)]
    [string] $Message,
    [Parameter(Position=1)]
    [string] $Title,
    [Parameter(Position=2)]
    [ValidateSet('OK', 'OKCancel', 'AbortRetryIgnore', 'YesNoCancel', 'YesNo', 'RetryCancel')]
    [string] $Buttons = 'OK',
    [ValidateSet('Information', 'Warning', 'Stop')]
    [string] $Icon = 'Information',
    [ValidateSet(0, 1, 2)]
    [int] $DefaultButtonIndex
  )

  # So that the $IsLinux and $IsMacOS PS Core-only
  # variables can safely be accessed in WinPS.
  Set-StrictMode -Off

  $buttonMap = @{
    'OK'               = @{ buttonList = 'OK'; defaultButtonIndex = 0 }
    'OKCancel'         = @{ buttonList = 'OK', 'Cancel'; defaultButtonIndex = 0; cancelButtonIndex = 1 }
    'AbortRetryIgnore' = @{ buttonList = 'Abort', 'Retry', 'Ignore'; defaultButtonIndex = 2; ; cancelButtonIndex = 0 };
    'YesNoCancel'      = @{ buttonList = 'Yes', 'No', 'Cancel'; defaultButtonIndex = 2; cancelButtonIndex = 2 };
    'YesNo'            = @{ buttonList = 'Yes', 'No'; defaultButtonIndex = 0; cancelButtonIndex = 1 }
    'RetryCancel'      = @{ buttonList = 'Retry', 'Cancel'; defaultButtonIndex = 0; cancelButtonIndex = 1 }
  }

  $numButtons = $buttonMap[$Buttons].buttonList.Count
  $defaultIndex = [math]::Min($numButtons - 1, ($buttonMap[$Buttons].defaultButtonIndex, $DefaultButtonIndex)[$PSBoundParameters.ContainsKey('DefaultButtonIndex')])
  $cancelIndex = $buttonMap[$Buttons].cancelButtonIndex

  if ($IsLinux) {
    Throw "Not supported on Linux."
  }
  elseif ($IsMacOS) {

    $iconClause = if ($Icon -ne 'Information') { 'as ' + $Icon -replace 'Stop', 'critical' }
    $buttonClause = "buttons { $($buttonMap[$Buttons].buttonList -replace '^', '"' -replace '$', '"' -join ',') }"

    $defaultButtonClause = 'default button ' + (1 + $defaultIndex)
    if ($null -ne $cancelIndex -and $cancelIndex -ne $defaultIndex) {
      $cancelButtonClause = 'cancel button ' + (1 + $cancelIndex)
    }

    $appleScript = "display alert `"$Title`" message `"$Message`" $iconClause $buttonClause $defaultButtonClause $cancelButtonClause"            #"

    Write-Verbose "AppleScript command: $appleScript"

    # Show the dialog.
    # Note that if a cancel button is assigned, pressing Esc results in an
    # error message indicating that the user canceled.
    $result = $appleScript | osascript 2>$null

    # Output the name of the button chosen (string):
    # The name of the cancel button, if the dialog was canceled with ESC, or the
    # name of the clicked button, which is reported as "button:<name>"
    if (-not $result) { $buttonMap[$Buttons].buttonList[$buttonMap[$Buttons].cancelButtonIndex] } else { $result -replace '.+:' }
  }
  else { # Windows
    Add-Type -Assembly System.Windows.Forms
    # Show the dialog.
    # Output the chosen button as a stringified [System.Windows.Forms.DialogResult] enum value,
    # for consistency with the macOS behavior.
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, $Buttons, $Icon, $defaultIndex * 256).ToString()
  }

}