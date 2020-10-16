Assert-Admin
$Program = "C:\Program"
$ProgramSource = "M:\Program"
if(-NOT (Test-Path -Path $Program)) {
    New-Item $Program -ItemType SymbolicLink -Value $ProgramSource
    Write-Information "'$Program' folder created"
    Update-PathEnv $Program
    return
}
Write-Warning "'$Program' already there!"