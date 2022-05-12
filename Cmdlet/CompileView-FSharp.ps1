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
dotnet "$(get-LatestSdkPath)\FSharp\fsc.dll" $file -o $dll
if($LASTEXITCODE -eq 0) {
    spps -n ILSpy -f -ErrorAction SilentlyContinue
    ILSpy.exe $dll
}

function get-LatestSdkPath {
   $a =  dotnet --list-sdks
   $sdk = $a[$a.length-1] # latest: 5.0.301 [C:\Program Files\dotnet\sdk]
   $path = $sdk -split '[\[\]]'
   return "$($path[1])\$($path[0].trim())"
}