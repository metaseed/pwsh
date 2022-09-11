
function Get-CallerVariable {
  param([Parameter(Position=1)][string]$Name)
  $PSCmdlet.SessionState.PSVariable.GetValue($Name)
}

[cmdletbinding()]
function Set-CallerVariable {
  param(
      [Parameter(ValueFromPipeline)][string]$Value,
      [Parameter(Position=1)]$Name
  )
  process { $PSCmdlet.SessionState.PSVariable.Set($Name,$Value)}
}

Export-ModuleMember Get-CallerVariable