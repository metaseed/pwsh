<#
.EXAMPLE
 Breakable-Pipeline { Get-ChildItem|% { $_;break } }
#>
function Breakable-Pipeline([ScriptBlock]$ScriptBlock) {
  do {
      . $ScriptBlock
  } while ($false)
}
