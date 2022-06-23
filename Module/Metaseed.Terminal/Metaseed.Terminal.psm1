Initialize-WTBgImg
# could not export any function via Export-ModuleMember when have nested module, so put it psd1
# . $env:MS_PWSH/Lib/Export-Functions.ps1
# . Export-Functions $PSScriptRoot
if(!($env:WTBackground) -or  $env:WTBackground -ne $PSScriptRoot ) {
    $env:WTBackground = $PSScriptRoot
    [System.Environment]::SetEnvironmentVariable('WTBackground', $PSScriptRoot, 'User')
}
. $PSScriptRoot/Show-WTBGGif.ps1

# https://download.visualstudio.microsoft.com/download/pr/7989338b-8ae9-4a5d-8425-020148016812/c26361fde7f706279265a505b4d1d93a/dotnet-runtime-6.0.6-win-x64.exe
# https://dotnet.microsoft.com/en-us/download/dotnet/6.0/runtime
$versions = dotnet --list-runtimes |% {$null=$_ -match "\s([0-9]+\.[0-9]+\.[0-9]+)\s";[version]::new($matches[1] )}|?{$_.Major -ge 6}
if($versions.Count -eq 0) {
    Write-Warning "Metaseed.Terminal module: please install dotnet runtime 6.0.0 or later"
    write-host "https://dotnet.microsoft.com/en-us/download/dotnet"
}