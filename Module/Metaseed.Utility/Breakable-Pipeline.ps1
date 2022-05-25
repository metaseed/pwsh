function Breakable-Pipeline([ScriptBlock]$ScriptBlock) {
  do {
      . $ScriptBlock
  } while ($false)
}

# Breakable-Pipeline { Get-ChildItem|% { $_;break } }