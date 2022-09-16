using namespace Terminal.Gui
function Watch-Table {
  # https://blog.ironmansoftware.com/tui-powershell/
  [CmdletBinding()]
  [alias('wct')]
  param (
    [Parameter()]
    [ScriptBlock]
    $Script = { Get-Process },

    # period in seconds
    [Parameter()]
    [double]
    $period = 1,

    # Title
    [Parameter()]
    [string]
    $Title = 'Monitoring'
  )

  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Data.Common')

  Import-Module Microsoft.PowerShell.ConsoleGuiTools
  if (!$?) {
    Install-Module Microsoft.PowerShell.ConsoleGuiTools -force
  }

  $module = (Get-Module Microsoft.PowerShell.ConsoleGuiTools -List).ModuleBase
  Add-Type -Path (Join-path $module Terminal.Gui.dll)

  $typeGetter = [OutGridView.Cmdlet.TypeGetter]::new($PSCmdlet)
  # Initialize the "GUI".
  # Note: This must come before creating windows and controls.
  [Application]::Init()
  # change color: https://github.com/gui-cs/Terminal.Gui/issues/148
  [Colors]::Base.Normal = [Application]::Driver.MakeAttribute([Color]::Green, [Color]::Black);

  $win = [Window] @{
    Title = $Title
  }
  $FilterLablel = [Label]@{
    Text = 'Filter(Regex): '
  }
  $win.Add($FilterLablel)

  $edt = [TextField] @{
    X     = [Pos]::Right($FilterLablel)
    Width = [Dim]::Fill()
    # Text = 'This text will be returned'
  }
  # $edt.Add_TextChanged({
  #   param($text)
  #   [Console]::WriteLine($text)
  # })
  $win.Add($edt)

  # $btn = [Button] @{
  #   X = [Pos]::Center()
  #   Y = [Pos]::Center() + 1
  #   Text = 'Quit'
  # }
  # $win.Add($btn)
  $tableView = [TableView] @{
    X      = 0
    Y      = 2
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

  # $objs = & $Script
  # $table = $typeGetter.CastObjectsToTableView($objs)

  $update = {
    $objs = & $Script
    $dataTable = [Data.DataTable]::new()
    $table = $typeGetter.CastObjectsToTableView($objs)
    $table.DataColumns | % {
      [void]$dataTable.Columns.Add($_.Label)
    }
    $table.Data | % {
      $values = $_.Values.Values | select -ExpandProperty DisplayValue
      $filter = '.*'
      $txt = $edt.Text.ToString()
      if ($txt) {
        $filter = $txt
      }
      $match = $false
      $values | % {
        if ($_ -match $filter) {
          # write-host $_
          $match = $true
        }
      }
      if ($match) {
        [void]$dataTable.Rows.Add($values)
      }
    }

    $tableView.Table = $dataTable
    $tableView.update() # otherwise no data shown, until got focus
    [void][Application]::MainLoop.AddTimeout([TimeSpan]::FromSeconds($period),
      $update
    )
  }
  . $update

  [Application]::Top.Add($win)
  # https://github.dev/gui-cs/Terminal.Gui/blob/28718e9c3ce0793b95be6846dc5f491644875baa/Terminal.Gui/Core/Event.cs#L61
  $statusBar = [StatusBar]@{
    Visible = $true
    Items = @(

    # not work
      # [StatusItem]::new(
      #   [Key]99 -bor  [Key]0x40000000,#[Key]::CtrlMask, # ctrl-c c:99
      #    "~CTRL-C~ Close",
      #   {
      #     [Application]::RequestStop();
      #   }
      #  ),
       [StatusItem]::new(
        [Key]27,# can not use [Key]::Esc too on my vm, so have to use value
         "~ESC~ Close",
        {
          [Application]::RequestStop();
        }
       ),
      [StatusItem]::new(
        # we have [Key]::F and [Key]::f defined in the enum, and pwsh is case insensitive, so error
        [Key]102 -bor [Key]0x40000000, #[Key]::CtrlMask, #not work if [Key]::f have to use 102
        "~CTRL-F~ Filter",
        {
          $edt.SetFocus()
        }
      )
    )
  }
  [Application]::Top.Add($statusBar)
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
  $edt.SetFocus()

  [Application]::Run()

  # As of 1.0.0-pre.4, at least on macOS, the following two statements
  # are necessary on in order for the terminal to behave properly again.
  [Application]::Shutdown() # Clears the screen too; required for being able to rerun the application in the same session.

  # Output something
  # $edt.Text.ToString()

  #tput reset # To make PSReadLine work properly again, notably up- and down-arrow.
}