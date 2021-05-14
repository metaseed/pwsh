# https://gallery.technet.microsoft.com/scriptcenter/How-to-automatically-mount-d623ce34
param 
( 
    [String]$Path = "D:\JianzhongSong\metaseed.vhdx"
) 
if(Test-Path $path)
{
    $content = "select vdisk file= `"$path`"`nattach vdisk"
    $path = "$env:USERPROFILE\MountVHD.txt"
    Out-File -InputObject $content -FilePath $path -Encoding ascii -Force
    schtasks /create /tn "MountVHD" /sc ONLOGON /ru SYSTEM  /tr "diskpart.exe /s '$path'"
 
    write-host "Task added successfully. The specified VHD file ($Path) will be mounted next logon." 
} 
else
{
    Write-Warning "The path is invalid." 
}