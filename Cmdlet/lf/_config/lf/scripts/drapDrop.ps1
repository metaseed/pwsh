param ($0) # $0 or any name is ok
# Show-MessageBox "the args[0]:$($args[0])" # we can not use name to reference the argument
# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create OpenFileDialog object
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog

# Configure the dialog properties
$openFileDialog.Title = "Drag/Drop"
$openFileDialog.InitialDirectory = "$env:pwd"
$openFileDialog.Filter = "All Files (*.*)|*.*"
$openFileDialog.FilterIndex = 1 # Default to first filter
$openFileDialog.RestoreDirectory = $true
$openFileDialog.Multiselect = $true

$result = $openFileDialog.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $selectedFilePath = $openFileDialog.FileName

    Write-Host "Selected File: $selectedFilePath"
}
else {
    Write-Host "No file was selected."
}