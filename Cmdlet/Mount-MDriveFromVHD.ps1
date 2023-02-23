# https://gallery.technet.microsoft.com/scriptcenter/How-to-automatically-mount-d623ce34
param
(
    [String]$Path = "D:\JianzhongSong\metaseed.vhdx"
)

Assert-Admin

if (Test-Path $path) {
    $content = @"
select vdisk file= "$path"
attach vdisk
"@
    $autoPath = "$env:USERPROFILE\MountVHD.txt"
    Out-File -InputObject $content -FilePath $autoPath -Encoding ascii -Force
    schtasks /create /tn "MountVHD" /sc ONLOGON /ru SYSTEM  /tr "diskpart.exe /s '$autoPath'"
    Write-Information "Task added successfully. The specified VHD file ($autoPath) will be auto mounted at next logon."

    if(!(test-path m:)) {
        $Letter = (Mount-VHD -Path $Path  -PassThru | Get-Disk | Get-Partition | Get-Volume).DriveLetter
        Set-Partition -DriveLetter $Letter -NewDriveLetter M
        Write-Notice "please set the key file to unlock the disk partition"
        $keyPath = Select-FileGUI
        manage-bde -unlock M: -recoverykey $keyPath
        # https://pureinfotech.com/change-font-face-windows-terminal/
        manage-bde -autounlock -enable M:
    } else {
        Write-Warning 'already has a disk named M'
    }
}
else {
    Write-Warning "The path($Path) is invalid."
}
