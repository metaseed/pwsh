Assert-Admin
$Program = "C:\Program"
if(-NOT (Test-Path -Path $Program)) {
    New-Item $Program -ItemType Directory
    $env:Path += ";$Program"
    Update-Path $Program
    Write-Information "$Program folder created and added to `$env:path"
    return
}
Write-Warning "$Program already there!"