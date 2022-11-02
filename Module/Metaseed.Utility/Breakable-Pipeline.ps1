<#
https://stackoverflow.com/questions/278539/is-it-possible-to-terminate-or-stop-a-powershell-pipeline-from-within-a-filter#answer-30943992
.EXAMPLE
 Breakable-Pipeline { Get-ChildItem|% { $_;break } }
#>
function Breakable-Pipeline([ScriptBlock]$ScriptBlock) {
  do {
      . $ScriptBlock
  } while ($false)
}
