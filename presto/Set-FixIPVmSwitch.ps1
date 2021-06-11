# https://superuser.com/questions/1541599/how-to-configure-static-ip-address-for-a-hyper-v-vm-ubuntu-19-10-quick-create
# https://4sysops.com/archives/native-nat-in-windows-10-hyper-v-using-a-nat-virtual-switch/



# ATTENTION: with this way, the VM can not use internet when connection via GlobalProtect to SLB net.


$name = "VMSwitch"
New-VMSwitch -SwitchName $name -SwitchType Internal
#(note down ifIndex of the newly created switch as INDEX)
$index = (Get-NetAdapter |? Name -Like "*$name*").ifIndex
New-NetIPAddress -IPAddress 192.168.0.1 -PrefixLength 24 -InterfaceIndex $index
New-NetNat -Name "VM_NAT" -InternalIPInterfaceAddressPrefix 192.168.0.0/24

# set switch instead of the default switch for the vm in hyyper-v

# need to set IP manually on VM, because the switch do not DHCP (default switch has DHCP)
<#
ip:     192.168.0.2
mask:   255.255.255.0
gateway: 192.168.0.1

dns: 8.8.8.8
#>

# get ipconfig info in vm
get-vm work |select -ExpandProperty NetworkAdapters

<# use //192.168.0.2 to access shared files from vm#>

<#
This uses 192.168.0.0/24 as the subnet for the virtual switch, where 192.168.0.1 is the IP of the host, which acts as a gateway.

Now, the VM can be connected to the new switch in Hyper-V Manager.

Note that unlike the Default Switch, there is no automatic network configuration via DHCP, so inside the VM, you will have to configure a static IP (e.g., 192.168.0.2) in the VM.
#>