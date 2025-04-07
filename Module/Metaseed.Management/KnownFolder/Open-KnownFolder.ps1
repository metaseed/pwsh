# https://www.winhelponline.com/blog/shell-commands-to-access-the-special-folders/
# https://www.winhelponline.com/blog/windows-10-shell-folders-paths-defaults-restore/
. $PSScriptRoot\_lib\get-shellFolders.ps1
function Open-KnownFolder {
  [cmdletBinding()]
  [alias('opkf')]
  param (
    [Parameter(Position = 0)]
    $FolderName
  )

  # HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\FolderDescriptions
  if (!$FolderName) {
    get-shellFolder
    return
  }
  # https://superuser.com/questions/395015/how-to-open-the-recycle-bin-from-the-windows-command-line
  start "shell:$FolderName"
  # start ::{645FF040-5081-101B-9F08-00AA002F954E}
}

Register-ArgumentCompleter -CommandName 'Open-KnownFolder' -ParameterName 'FolderName' -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
  $folders = get-shellFolder $wordToComplete
  return $folders
}
