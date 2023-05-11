Assert-Admin
# to show the drive in Explorer, after map in admin mode
# Because of the UAC, and the Shell runs with standard user permissions, it can't see mapped drives which were configured by your application running with admin rights.
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLinkedConnections' -Value 1
net use Z: /delete /y
# net use M: \\tsclient\M /Persistent:yes # have to share the M drive in the local resources when connect the the VM, this make the vm slow so not using
# username: dir\jsong12
# https://lazyadmin.nl/it/net-use-command/
# above link fix: after restart the map connection is lost, have to manually map in explorer
# have to share M disk from host, The only problem with this is that the password is forgotten after a reboot. So you will need to reenter the password every time you open the network connection. We can solve this by using the parameter /savecred.
# net use Z: \\SLB-7X23TT3\C$\VM\VMData /Persistent:yes /user:dir\jsong12 *
net use Z: \\SLB-7X23TT3\VMData /Persistent:yes /savecred # however, to use /savecred you must not supply the username and password.
# New-PSDrive -Persist -Name M -PSProvider FileSystem -Root "\\SLB-7X23TT3\VMData"
# maybe need to restart

# run in common user
# net use z: \\localhost\C$\VM\VMData /Persistent:yes
# subst z: C:\VM\VMData
# subst z: \\SLB-7X23TT3\VMData
# subst z: \D