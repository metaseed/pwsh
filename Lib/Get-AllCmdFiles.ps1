function Get-AllCmdFiles {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $Directory,
    [string]$filter = '*.ps1'
  )
  write-verbose "Get all ps1 files except that start with '_' or in the subfolder that start with '_'."

  $Directory = $Directory.TrimEnd('\')
  # use @() to make sure return is an array, even 1 or no item
  $All = Get-ChildItem $Directory -include $filter -Recurse -Exclude _* -ErrorAction SilentlyContinue |
  ? {
    $partialDir = $_.fullname.StartsWith($Directory) ? $_.FullName.Substring($Directory.Length) : $_.FullName
    $partialDir -notmatch '\\_.*\\'
  }

  return @($All)
}
# Export-ModuleMember Get-AllCmdFiles
