## stop and disconnect
// https://learn.microsoft.com/en-us/powershell/module/hyper-v/stop-vm?view=windowsserver2022-ps
stop-vm windows11
stop-vm windows11 -Save
Get-VM | Connect-VM