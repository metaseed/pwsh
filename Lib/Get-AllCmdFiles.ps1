<#
Get all ps1 files except those that start with '_', or live under a folder starting with '_', or under a folder named 'Private'.
#>
function Get-AllCmdFiles {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $Directory,

    [Parameter()]
    [string]
    $filter = '*.ps1'
  )

  $Directory = [IO.Path]::GetFullPath($Directory).TrimEnd('\')

  $All = Get-ChildItem $Directory -File -include $filter -Recurse -Exclude _* -ErrorAction SilentlyContinue |
  ? {
    # if parent dirs of $Directory contains '_', it's valid
    $partialDir = $_.fullname.StartsWith($Directory) ? $_.FullName.Substring($Directory.Length) : $_.FullName
    $partialDir -notmatch '(^|\\)_[^\\]*\\' -and $partialDir -notmatch '(^|\\)Private\\'
  }

  # use @() to make sure return is an array, even 1 or no item
  return @($All)
}
# Export-ModuleMember Get-AllCmdFiles
