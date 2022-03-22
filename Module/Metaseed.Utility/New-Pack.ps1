function New-Pack {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        [Alias('f')]
        $FolderWithExe,
        [Parameter()]
        [string]
        $StartExe,
        [Parameter()]
        [string]
        $OutPath,
        [Parameter()]
        [string]
        $OutExeName
    )

    $dir = gl
    $FolderWithExe = Resolve-Path $FolderWithExe
    Push-Location -Path $PSScriptRoot
    try {
        # pack
        if (!$StartExe) {
            $exes = gci $FolderWithExe | ? { $_.Name -like '*.exe' }
            $StartExe = $exes[0].Name
        }
        $exeName = Split-Path $StartExe -LeafBase
        $tempFolder = "$env:temp\$exeName"
        $tempExe = "$tempFolder\$StartExe"
        $exePath = "$FolderWithExe\$StartExe"
        $iconPath = "$tempFolder\$exeName.ico"
        if (!$OutExeName) { $OutExeName = $StartExe }
        if (!$OutPath) {
            $OutPath = "$dir/$OutExeName"
        }

        Remove-Item $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory $tempFolder -Force > $null
        .\Pack\warp-packer.exe --arch windows-x64 --input_dir $FolderWithExe --exec $StartExe --output $tempExe

        # remove cmd window
        $VsWherePath = "`"${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe`""
        $config = Invoke-Expression "& $VsWherePath -latest -format json" | ConvertFrom-Json
        $base = $config.InstallationPath
        . "$base\Common7\Tools\Launch-VsDevShell.ps1"
        editbin /subsystem:windows $tempExe
        sl $PSScriptRoot

        # set icon
        .\Pack\resource_hacker\ResourceHacker.exe -open $exePath -action extract -mask ICONGROUP, IDI_ICON1, -save $iconPath
        sleep 1
        .\Pack\resource_hacker\ResourceHacker.exe -open $tempExe -save $OutPath -action addskip -mask ICONGROUP, MAINICON, -res $iconPath
        sleep 1
        
        # display info 
        '==============Result================='
        "$OutPath"
        "{0:N2} MB" -f ((Get-Item $OutPath).Length / 1MB)
        Remove-Item $tempFolder -Recurse -Force
    }
    catch {
        Write-Error $_
    }
    finally {
        Pop-Location
    }

}