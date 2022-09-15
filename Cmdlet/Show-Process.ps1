using namespace Terminal.Gui
# https://blog.ironmansoftware.com/tui-powershell/
[CmdletBinding()]
param (
  [Parameter()]
  [ScriptBlock]
  $Script = { Get-Process },

  # period in miliseconds
  [Parameter()]
  [double]
  $period = 1000
)

[void][System.Reflection.Assembly]::LoadWithPartialName('System.Data.Common')


Import-Module Microsoft.PowerShell.ConsoleGuiTools
$module = (Get-Module Microsoft.PowerShell.ConsoleGuiTools -List).ModuleBase
Add-Type -Path (Join-path $module Terminal.Gui.dll)

$typeGetter = [OutGridView.Cmdlet.TypeGetter]::new($PSCmdlet)
# Initialize the "GUI".
# Note: This must come before creating windows and controls.
[Application]::Init()

$win = [Window] @{
  Title = 'Monitor Processes'
}

# $edt = [TextField] @{
#     X = [Pos]::Center()
#     Y = [Pos]::Center()
#     Width = 20
#     Text = 'This text will be returned'
# }
# $win.Add($edt)

# $btn = [Button] @{
#   X = [Pos]::Center()
#   Y = [Pos]::Center() + 1
#   Text = 'Quit'
# }
# $win.Add($btn)
$tableView = [TableView] @{
  X      = 0
  Y      = 0
  Width  = [Dim]::Fill()#100
  Height = [Dim]::Fill()#10
  Style  = @{
    AlwaysShowHeaders            = $true
    ShowVerticalHeaderLines      = $false
    ShowVerticalCellLines        = $false
    ShowHorizontalHeaderOverline = $false
  }
}
$win.Add($tableView)

$dataTable = [Data.DataTable]::new()
$tableView.Table = $dataTable
$objs = & $Script
$table = $typeGetter.CastObjectsToTableView($objs)
$table.DataColumns | % {
  [void]$dataTable.Columns.Add($_.Label)
}

function update {
  $objs = & $Script
  $table = $typeGetter.CastObjectsToTableView($objs)
  $table.Data | % {
    $values = $_.Values.Values | select -ExpandProperty DisplayValue
    [void]$dataTable.Rows.Add($values)
  }
}
update

[void][Application]::MainLoop.AddTimeout([TimeSpan]::FromSeconds(1),
  {
    $dataTable.Clear()
    update
    $tableView.update() # otherwise no data shown, until got focus
  });


[Application]::Top.Add($win)

# Attach an event handler to the button.
# Note: Register-ObjectEvent -Action is NOT an option, because
# the [Application]::Run() method used to display the window is blocking.
# $btn.add_Clicked({
#   # Close the modal window.
#   # This call is also necessary to stop printing garbage in response to mouse
#   # movements later.
#   [Application]::RequestStop()
# })

# Show the window (takes over the whole screen).
# Note: This is a blocking call.
$tableView.SetFocus()

[Application]::Run()

# As of 1.0.0-pre.4, at least on macOS, the following two statements
# are necessary on in order for the terminal to behave properly again.
[Application]::Shutdown() # Clears the screen too; required for being able to rerun the application in the same session.

# Output something
# $edt.Text.ToString()

#tput reset # To make PSReadLine work properly again, notably up- and down-arrow.