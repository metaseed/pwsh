function Get-AllPwshFiles {
  [CmdletBinding()]
  param (
      [Parameter()]
      [string]
      $path
  )
  # use @() to make sure return is an array, even 1 or no item
  $All = @(Get-ChildItem $path\*.ps1 -ErrorAction SilentlyContinue -Recurse -Exclude _* |
   ? { $_.fullname -notmatch '\\_.*\\' }) 
  return $All
}
# Export-ModuleMember Get-AllPwshFiles
