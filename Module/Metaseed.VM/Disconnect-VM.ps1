# stop all vms
import-module Hyper-V -ErrorAction SilentlyContinue
function Disconnect-VM {
	[CmdletBinding(DefaultParameterSetName = 'name')]
	param()
	$connectedVms = gps -n vmconnect
	foreach ($connectedVm in $connectedVms) {
		$title = $connectedVm.MainWindowTitle
		$vmName = ($title -split ' on ')[0]
		stop-vm $vmName
		spps $connectedVm
	}
}

