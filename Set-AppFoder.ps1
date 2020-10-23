Assert-Admin
$Program = "C:\App"
$ProgramSource = "M:\App"
if(-NOT (Test-Path -Path $ProgramSource)) {
    Write-Error "make sure the m: disk is mapped!"
}
if(-NOT (Test-Path -Path $Program)) {
    New-Item $Program -ItemType SymbolicLink -Value $ProgramSource
    Write-Information "'$Program' symble link folder created"
    Update-PathEnv $Program
    return
}
Write-Information "'$Program' already there!"