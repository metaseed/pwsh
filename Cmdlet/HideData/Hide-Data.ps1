# function Hide-Data {
[CmdletBinding()]
param (
    # image/mp3/video/exe file path
    [Parameter(Mandatory = $true)]
    [string]
    $ImagePath,
    # data files to merge
    [Parameter(Mandatory = $true)]
    [string[]]
    $dataPath,
    [string]
    $outPath
)
    
process {
    $tempFolder = "$env:temp\compressData"
    $dataZip = "$tempFolder\data.zip"
    $imageName = Split-Path $ImagePath -LeafBase
    $imageExt = Split-Path $ImagePath -Extension

    if (!$outPath) { $outPath = ".\$imageName.m$imageExt" } # name.m.jpg
    if (Test-Path $outPath) {
        $confirm = Read-Host "$outPath already exist! remove?[y/n]"
        if ($confirm -eq 'y') {
            Remove-Item $outPath -Force -ErrorAction SilentlyContinue
        }
        else {
            'Nothing changed!'
            return
        }
    }

    Remove-Item $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory $tempFolder

    Compress-Archive $dataPath -DestinationPath $dataZip -Force

    # copy cmd way- works!
    # $pathes = (@("`"$ImagePath`"") + (@($dataZip, $hiddenZip) | ? { Test-Path $_ } | % { "`"$_`"" }) ) -join ' + '
    # $cmd = "copy /b $pathes `"$outPath`""
    # $cmd
    # cmd /c $cmd

    gc $ImagePath, $dataZip -AsByteStream -ReadCount 2000 | Set-Content -AsByteStream $outPath
    "File output: $outPath"
    "open it with 7zfm.exe"
}
# }
# Hide-Data M:\keyboard.jpeg  $PSScriptRoot\assert-admin.ps1, $PSScriptRoot\Add-Path.ps1
# note: only the first zip could be seen and edit in 7zfm.exe, if add content behind the zip, then the first zip content can be viewed but can not be edited in 7zfm.exe
# so here we set all content in one zip and then attach it.
# no password method provided by Compress-Archive and dotnet System.IO.Compression, although we do could directly use 7zip to support this.