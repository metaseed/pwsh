# https://www.winhelponline.com/blog/shell-commands-to-access-the-special-folders/
# https://www.winhelponline.com/blog/windows-10-shell-folders-paths-defaults-restore/
function Open-ShellFolder {
  param (
    [Parameter(Position = 0)]
    $FolderName
  )

  # HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\FolderDescriptions
  if (!$FolderName) {
    get-shellFolders
    return
  }
  # https://superuser.com/questions/395015/how-to-open-the-recycle-bin-from-the-windows-command-line
  start "shell:$FolderName"
  # start ::{645FF040-5081-101B-9F08-00AA002F954E}

}
function get-shellFolders($wordToComplete) {
  $folders = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\FolderDescriptions"
  $folders = $folders.Name.replace('HKEY_LOCAL_MACHINE', 'HKLM:')
  $folders = $folders |
  % {
    $folder = Get-ItemPropertyValue $_ -Name Name;
      return @{Name = $folder; Order = 0}
  } |
  ? {
    Test-WordToComplete $_ $wordToComplete
  }|
  sort -Property Order|
  % {
    if($_.Name.contains(' ')) {
      return "'$($_.Name)'"
    } else {
      return $_.Name
    }
  }

  return $folders
}
Register-ArgumentCompleter -CommandName 'Open-ShellFolder' -ParameterName 'FolderName' -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
  $folders = get-shellFolders $wordToComplete
  return $folders
}