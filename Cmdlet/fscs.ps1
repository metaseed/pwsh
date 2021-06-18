<#
compile fs to dll and open it with ilspy to investigate

could compile fs file
could not compile complex fsx
#>
[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $file
)
$file = Resolve-Path $file
$dir = Split-Path $file
$name = Split-Path $file -LeafBase
$dll = "$dir\bin\$name.dll"
dotnet "C:\Program Files\dotnet\sdk\5.0.102\FSharp\fsc.exe" $file -o $dll
if($LASTEXITCODE -eq 0) {
    kill -n ILSpy -f -ErrorAction SilentlyContinue
    ILSpy.exe $dll
}