Assert-Admin
# to show the drive in Explorer, after map in admin mode
# Because of the UAC, and the Shell runs with standard user permissions, it can't see mapped drives which were configured by your application running with admin rights.
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLinkedConnections' -Value 1
net use M: /delete /y
# net use M: \\tsclient\M /Persistent:yes # have to share the M drive in the local resources when connect the the VM, this make the vm slow so not using
net use M: \\slb-fncl5y2\M /Persistent:yes # have to share M disk from host, 
# maybe need to restart
