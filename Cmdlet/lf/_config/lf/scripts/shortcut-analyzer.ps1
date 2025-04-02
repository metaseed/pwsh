# shortcut-analyzer.ps1
# Save this file to a location of your choice, for example:
# %USERPROFILE%\.config\lf\scripts\shortcut-analyzer.ps1

param (
    [Parameter(Mandatory=$true)]
    [string]$ShortcutPath
)
Write-Host "ddd"
try {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($ShortcutPath)
    $target = $shortcut.TargetPath

    if (Test-Path -Path $target -PathType Container) {
        # It's a folder
        Write-Output "FOLDER:$target"
    } else {
        # It's an application
        Write-Output "APP:$target"
    }
}
catch {
    Write-Output "ERROR:$($_.Exception.Message)"
}