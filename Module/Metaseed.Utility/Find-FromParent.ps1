<#
.description
return a FileInfo object for the given file name.
then you can use .FullName to get the string path or "$path" to get fullpath

.example
Find-FromParent .git 'M:\script\pwsh'

#>
function Find-FromParent {
    [CmdletBinding()]
    param (
        # support wildcard
        [Parameter(Position=0, Mandatory)]
        [string]
        $FileOrFolder,
        [Parameter(Position=1)]
        [string]
        $PathFrom = $pwd
  )

  $path = $pathFrom
  if(!$path) {
    return $null
  }
  do {
    # force to show hidden file/folder like .git
    $info = Get-ChildItem $path -force| ? name -like $FileOrFolder
    if ($null -ne $info) { return $info }
    $path = $path | split-path
  } while ($path -ne '')

  if ($null -eq $info) {
    Write-Warning "could not find '$FileOrFolder' from any parent folder of '$pathFrom'"
    return;
  }
}
