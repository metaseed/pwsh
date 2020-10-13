# https://gallery.technet.microsoft.com/scriptcenter/How-to-automatically-mount-d623ce34
param 
( 
    [String]$Path = "D:\JianzhongSong\metaseed.vhdx"
) 
if(Test-Path -Path $path)
{ 
    $content = "select vdisk file= `"$path`"`nattach vdisk"  
    Out-File -InputObject $content -FilePath "$env:USERPROFILE\MountVHD.txt" -Encoding ascii -Force  
    schtasks /create /tn "MountVHD" /tr "diskpart.exe /s '$env:USERPROFILE\MountVHD.txt'" /sc ONLOGON /ru SYSTEM 
 
    write-host "Task added successfully. The specified VHD file ($Path) will be mounted next logon." 
} 
Else 
{
    Write-Warning "The path is invalid." 
}