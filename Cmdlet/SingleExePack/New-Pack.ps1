# function New-Pack {
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
        $OutExeName,
        [Parameter()]
        [switch]
        [Alias('k')]
        $keepConsole

    )

    $dir = gl
    $FolderWithExe = Resolve-Path $FolderWithExe
    Push-Location -Path $PSScriptRoot
    try {
        Write-Action 'Creating new pack...'
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
        .\_Pack\warp-packer.exe --arch windows-x64 --input_dir $FolderWithExe --exec $StartExe --output $tempExe

        if (-not $keepConsole) {
            write-action "remove cmd window..."
            $VsWherePath = "`"${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe`""
            $config = Invoke-Expression "& $VsWherePath -latest -format json" | ConvertFrom-Json
            $base = $config.InstallationPath
            . "$base\Common7\Tools\Launch-VsDevShell.ps1"
            editbin /subsystem:windows $tempExe
            sl $PSScriptRoot
        }

        write-action "set icon..."
        .\_Pack\resource_hacker\ResourceHacker.exe -open $exePath -action extract -mask ICONGROUP, IDI_ICON1, -save $iconPath
        sleep 1
        if(test-path $iconPath) {
            .\_Pack\resource_hacker\ResourceHacker.exe -open $tempExe -save $OutPath -action addskip -mask ICONGROUP, MAINICON, -res $iconPath
            sleep 1
        } else {
            copy-item $tempExe $OutPath -Force
        }
        
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

# }