function Compress-Data {
    [CmdletBinding()]
    param (
        # jpg file path
        [Parameter(Mandatory = $true)]
        [string]
        $ImagePath,
        # data files to merge
        [Parameter(Mandatory = $true)]
        [string[]]
        $dataPath,
        # hiden files
        [Parameter()]
        [string[]]
        $hiddenDataPath
    )
    
    process {
        $temp = "$env:temp\compressData"
        $dataZip = "$temp\data.zip"
        $hiddenZip = "$temp\hidden.zip"
        $imageName = Split-Path $ImagePath -LeafBase
        $imageExt = Split-Path $ImagePath -Extension
        $outPath = ".\$imageName.m$imageExt"

        if (Test-Path $outPath) {
            $confirm = Read-Host "$outPath already exist! remove?[y/n]"
            if ($confirm -eq 'y') {
                Remove-Item $outPath -Force -ErrorAction SilentlyContinue
            }
            else {
                return
            }
        }
        Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory $temp

        Compress-Archive $dataPath -DestinationPath $dataZip -Force
        if ($hiddenDataPath) { Compress-Archive $hiddenDataPath -DestinationPath $hiddenZip -Force }

        $pathes = (@("`"$ImagePath`"") + (@($dataZip, $hiddenZip) | ? { Test-Path $_ } | % { "`"$_`"" }) ) -join ' + '
        $cmd = "copy /b $pathes `"$outPath`""
        $cmd
        cmd /c $cmd
    }
    
}
Compress-Data M:\keyboard.jpeg    $PSScriptRoot\admin.ps1, $PSScriptRoot\Add-Path.ps1 $PSScriptRoot\New-Pack.ps1, $PSScriptRoot\Get-Appx.ps1
# note: only the first zip coudl be seen in 7zfm.exe