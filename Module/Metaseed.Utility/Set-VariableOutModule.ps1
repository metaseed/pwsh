# https://stackoverflow.com/questions/72378920/access-a-variable-from-parent-scope
# https://stackoverflow.com/questions/46528262/is-there-any-way-for-a-powershell-module-to-get-at-its-callers-scope
function Get-VariableOutModule {
  param([Parameter(Position=1)][string]$Name)
  $PSCmdlet.SessionState.PSVariable.GetValue($Name)
}

function Set-VariableOutModule {
  [Cmdletbinding()]
  param(
      [Parameter(ValueFromPipeline)][string]$Value,
      [Parameter(Position=1)]$Name
  )
  process { $PSCmdlet.SessionState.PSVariable.Set($Name,$Value)}
}

Export-ModuleMember Get-VariableOutModule