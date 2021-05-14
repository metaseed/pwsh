Assert-Admin
$App = "C:\App"
$AppSource = "M:\App"
if(-not (Test-Path $AppSource)) {
    Write-Error "make sure the M: disk is mapped!"
}
if(-not (Test-Path $App)) {
    New-Item $App -ItemType SymbolicLink -Value $AppSource
    Write-Information "'$App' symble link folder created from $AppSource"
    Update-PathEnv $App
    return
}
Write-Information "'$App' already there!"