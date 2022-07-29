# Adapted from: https://stackoverflow.com/questions/25690038/how-do-i-properly-use-the-folderbrowserdialog-in-powershell

function Select-FolderGUI() {
  [CmdletBinding()]
  param (
      [String] $Description = "Select a folder",
      [String] $InitialDirectory = $home
  )

  [Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
  $FolderName = New-Object Windows.Forms.FolderBrowserDialog
  $FolderName.Description = $Description
  $FolderName.rootfolder = "MyComputer"
  $FolderName.SelectedPath = $InitialDirectory
  $Response = $FolderName.ShowDialog()

  If ($Response -eq "OK") {
      $Folder += $FolderName.SelectedPath
      Write-Host "Folder Selected: $Folder"
  } ElseIf ($Response -eq "Cancel") {
      Write-Host "Aborting folder selection..."
  }

  return $Folder
}
