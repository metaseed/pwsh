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

Write-Host "'$App' already mapped!"