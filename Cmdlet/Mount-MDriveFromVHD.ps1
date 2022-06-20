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
    $path = "$env:USERPROFILE\MountVHD.txt"
    Out-File -InputObject $content -FilePath $path -Encoding ascii -Force
    schtasks /create /tn "MountVHD" /sc ONLOGON /ru SYSTEM  /tr "diskpart.exe /s '$path'"
    Write-Information "Task added successfully. The specified VHD file ($Path) will be auto mounted at next logon." 

    $Letter = (Mount-VHD -Path $Path  -PassThru | Get-Disk | Get-Partition | Get-Volume).DriveLetter
    Set-Partition -DriveLetter $Letter -NewDriveLetter M
} 
else {
    Write-Warning "The path is invalid." 
}