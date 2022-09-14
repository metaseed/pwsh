
$UI = $Host.UI.RawUI

function New-Size {
  param([int]$width, [int]$height)

  new-object System.Management.Automation.Host.Size $width,$height
}

function New-Rectangle {
  param(
      [int]$left,
      [int]$top,
      [int]$right,
      [int]$bottom
  )

  $rect = new-object System.Management.Automation.Host.Rectangle
  $rect.left= $left
  $rect.top = $top
  $rect.right =$right
  $rect.bottom = $bottom

  $rect
}
function New-Position(
	[int]$X,
	[int]$Y
)
{
	$Position = $UI.WindowPosition
	$Position.X += $X
	$Position.Y += $Y
	$Position
}

function New-Coordinate {
  param([int]$x, [int]$y)

  new-object System.Management.Automation.Host.Coordinates $x, $y
}

function Get-BufferCell {
  param([int]$x, [int]$y)

  $rect = new-rectangle $x $y $x $y

  [System.Management.Automation.Host.buffercell[,]]$cells = $host.ui.RawUI.GetBufferContents($rect)

  $cells[0,0]
}

function Set-BufferCell {
  [outputtype([System.Management.Automation.Host.buffercell])]
  param(
      [int]$x,
      [int]$y,
      [System.Management.Automation.Host.buffercell]$cell
  )

  $rect = new-rectangle $x $y $x $y

  # return previous
  get-buffercell $x $y

  # use "fill" overload with single cell rect
  $host.ui.rawui.SetBufferContents($rect, $cell)
}

function New-BufferCell {
  param(
      [string]$Character,
      [consolecolor]$ForeGroundColor = $(get-buffercell 0 0).foregroundcolor,
      [consolecolor]$BackGroundColor = $(get-buffercell 0 0).backgroundcolor,
      [System.Management.Automation.Host.BufferCellType]$BufferCellType = "Complete"
  )

  $cell = new-object System.Management.Automation.Host.BufferCell
  $cell.Character = $Character
  $cell.ForegroundColor = $foregroundcolor
  $cell.BackgroundColor = $backgroundcolor
  $cell.BufferCellType = $buffercelltype

  $cell
}


function New-BufferCellArray(
	[string[]]
	$Content,
	[System.ConsoleColor]
	$ForegroundColor = $UI.ForegroundColor,
	[System.ConsoleColor]
	$BackgroundColor = $UI.BackgroundColor
)
{
	, $UI.NewBufferCellArray($Content, $ForegroundColor, $BackgroundColor)
}

function New-RecoverableBuffer(
	[System.Management.Automation.Host.Coordinates]
	$Position
	,
	[System.Management.Automation.Host.BufferCell[,]]
	$Buffer
)
{
	$BufferBottom = $BufferTop = $Position
	$BufferBottom.X += ($Buffer.GetUpperBound(1))
	$BufferBottom.Y += ($Buffer.GetUpperBound(0))

	$OldTop = New-Object System.Management.Automation.Host.Coordinates 0, $BufferTop.Y
	$OldBottom = New-Object System.Management.Automation.Host.Coordinates ($UI.BufferSize.Width - 1), $BufferBottom.Y
	$OldBuffer = $UI.GetBufferContents((New-Object System.Management.Automation.Host.Rectangle $OldTop, $OldBottom))

	$UI.SetBufferContents($BufferTop, $Buffer)
	$Handle = New-Object System.Management.Automation.PSObject -Property @{
		Content = $Buffer
		OldContent = $OldBuffer
		Location = $BufferTop
		OldLocation = $OldTop
	}
	Add-Member -InputObject $Handle -MemberType ScriptMethod -Name Clear -Value {$UI.SetBufferContents($this.OldLocation, $this.OldContent)}
	Add-Member -InputObject $Handle -MemberType ScriptMethod -Name Show -Value {$UI.SetBufferContents($this.Location, $this.Content)}
	$Handle
}

function Write-Buffer() {
  param (
    [int] $x,
    [int] $y,
    [string]$text,
    [System.ConsoleColor]
    $ForegroundColor = $UI.ForegroundColor,
    [System.ConsoleColor]
    $BackgroundColor = $UI.BackgroundColor
  )
  $position = New-Position $x $y
  $bufferArray = New-BufferCellArray @($text) $ForegroundColor $BackgroundColor
  $UI.SetBufferContents($position, $bufferArray)

}