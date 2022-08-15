function Get-AllCmdFiles {
  [CmdletBinding()]
  param (
      [Parameter()]
      [string]
      $Directory,
      [string]$filter = '*.ps1'
  )
  # use @() to make sure return is an array, even 1 or no item
  $All = Get-ChildItem $Directory -include $filter -Recurse -Exclude _* -ErrorAction SilentlyContinue |
   ? { $_.fullname -notmatch '\\_.*\\' }
  return @($All)
}
# Export-ModuleMember Get-AllCmdFiles
