function New-Pack {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        [Alias('p')]
        $FolderPath,
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
    $FolderPath = Resolve-Path $FolderPath
    Push-Location -Path $PSScriptRoot
    try {
        # pack
        if (!$StartExe) {
            $exes = gci $FolderPath | ? { $_.Name -like '*.exe' }
            $StartExe = $exes[0].Name
        }
        $exeName = Split-Path $StartExe -LeafBase
        $temp = "$env:temp\$exeName"
        $tempExe = "$temp\$StartExe"
        $exePath = "$FolderPath\$StartExe"
        $iconPath = "$temp\$exeName.ico"
        if (!$OutExeName) { $OutExeName = $StartExe }
        if (!$OutPath) {
            $OutPath = "$dir/$OutExeName"
        }

        Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory $temp -Force > $null
        .\Pack\warp-packer.exe --arch windows-x64 --input_dir $FolderPath --exec $StartExe --output $tempExe

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
        Remove-Item $temp -Recurse -Force
    }
    catch {
        Write-Error $_
        Pop-Location
    }

}