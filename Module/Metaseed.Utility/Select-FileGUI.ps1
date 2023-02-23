function Select-FileGUI() {
    [CmdletBinding()]
    param (
        [String] $Description = "Select a file",
        [String] $InitialDirectory = $home,
		# "txt files (*.txt)|*.txt|All files (*.*)|*.*"
		[String] $Filter = "All files (*.*)|*.*"
    )

    [Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $FolderName = [Windows.Forms.OpenFileDialog]::new()
	$FolderName.Filter = $Filter
    $FolderName.InitialDirectory = $InitialDirectory
    $Response = $FolderName.ShowDialog()

    If ($Response -eq "OK") {
        $Folder = "$($FolderName.FileName)"
        Write-Host "File Selected: $Folder"
    } ElseIf ($Response -eq "Cancel") {
        Write-Host "Aborting folder selection..."
    }

    return $Folder
  }