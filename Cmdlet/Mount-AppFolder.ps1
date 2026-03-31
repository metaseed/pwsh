Assert-Admin
$App = "C:\App"
$AppSource = "M:\App"
$MAppExists = Test-Path $AppSource
if (-not $MAppExists) {
    Write-Warning "The '$AppSource' folder is not exist!"
}
else {
    Write-Host "App source folder: $AppSource"
}
if (-not (Test-Path $App)) {
    if ($MAppExists) {
        New-Item $App -ItemType SymbolicLink -Value $AppSource
        Write-Host "'$App' symble link folder created from $AppSource"
        # Add-PathEnv $App 'User'
    }
    else {
        New-Item $App -ItemType Directory
        Write-Host "'$App' folder created"
    }
}
if ($MAppExists -and (gi c:\app ).LinkType -ne 'symboliclink') {
    Write-Attention "C:\app is there but it is not a symbolic link"
}

$env:MS_App = $App
[System.Environment]::SetEnvironmentVariable("MS_App", $App, 'User')

Add-PathEnv "$env:MS_App" -Scope User
Add-PathEnv "$env:MS_App\_shim" -Scope User # folder  to store app
Add-PathEnv "$env:MS_App\software" -Scope User

Write-Host "'$App' mapped!"

# shmake -i C:\App\7-Zip\7z.exe -o C:\app\_shim\7z.exe -a "%s"
# shmake -i C:\App\ILSpy\ILSpy.exe -o C:\app\_shim\ILSpy.exe -a "%s"