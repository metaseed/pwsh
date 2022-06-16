Assert-Admin
$App = "C:\App"
$AppSource = "M:\App"
if(-not (Test-Path $AppSource)) {
    Write-Error "make sure the M: disk is mapped!"
}
if(-not (Test-Path $App)) {
    New-Item $App -ItemType SymbolicLink -Value $AppSource
    Write-Host "'$App' symble link folder created from $AppSource"
    Add-Path $App 'User'
    return
}
Write-Host "'$App' already there!"