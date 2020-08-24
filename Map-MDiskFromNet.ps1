using namespace System.Security.Principal

If (-NOT ([WindowsPrincipal] [WindowsIdentity]::GetCurrent()).IsInRole([WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    throw
} else {
    Write-Host "Powershell runs in admin mode"
}
# to show the drive in Explorer, after map in admin mode
# Because of the UAC, and the Shell runs with standard user permissions, it can't see mapped drives which were configured by your application running with admin rights.
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLinkedConnections' -Value 1
net use M: /delete /y
# net use M: \\tsclient\M /Persistent:yes
net use M: \\slb-fncl5y2\M /Persistent:yes
# maybe need to restart
