# note: run this script in VM
Assert-Admin
# to show the drive in Explorer, after map in admin mode
# Because of the UAC, and the Shell runs with standard user permissions, it can't see mapped drives which were configured by your application running with admin rights.
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLinkedConnections' -Value 1
net use M: /delete /y
# net use M: \\tsclient\M /Persistent:yes # have to share the M drive in the local resources when connect the the VM, this make the vm slow so not using
# username: dir\jsong12
# https://lazyadmin.nl/it/net-use-command/
# above link fix: after restart the map connection is lost, have to manually map in explorer
# net use M: \\SLB-7X23TT3\M /Persistent:yes /user:dir\jsong12 * #/savecred # have to share M disk from host,
net use M: \\SLB-7X23TT3\M /Persistent:yes /savecred
# New-PSDrive -Persist -Name M -PSProvider FileSystem -Root "\\slb-fncl5y2\M"
# maybe need to restart

# run in common user
# net use z: \\localhost\C$\VM\VMData /Persistent:yes
# subst z: C:\VM\VMData