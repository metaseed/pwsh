Assert-Admin
$App = "C:\App"
$AppSource = "M:\App"
if(-not (Test-Path $AppSource)) {
    Write-Error "make sure the M: disk is mapped!"
    return
}
if(-not (Test-Path $App)) {
    New-Item $App -ItemType SymbolicLink -Value $AppSource
    Write-Host "'$App' symble link folder created from $AppSource"
    # Add-PathEnv $App 'User'
    return
}
if((gi c:\app ).LinkType -ne 'symboliclink') {
    Write-Attention "C:\app is there but it is not a symbolic link"
}

$env:MS_App = $App
[System.Environment]::SetEnvironmentVariable("MS_App", $App, 'User')

Add-PathEnv "$env:MS_App" -Scope User
Add-PathEnv "$env:MS_App\_shim" -Scope User # folder  to store app
Add-PathEnv "$env:MS_App\software" -Scope User

Write-Host "'$App' already mapped!"

# shmake -i C:\App\7-Zip\7z.exe -o C:\app\_shim\7z.exe -a "%s"
# shmake -i C:\App\ILSpy\ILSpy.exe -o C:\app\_shim\ILSpy.exe -a "%s"