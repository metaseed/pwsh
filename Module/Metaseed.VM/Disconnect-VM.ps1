# stop all vms
import-module Hyper-V -ErrorAction SilentlyContinue
function Disconnect-VM {
	[CmdletBinding(DefaultParameterSetName = 'name')]
	param(
		# save state?
		[Parameter()]
		[switch]
		$Save
	)
	$connectedVms = gps -n vmconnect -ErrorAction Ignore
	if(!$connectedVms) {
		Write-Notice "No openned VM"
		return
	}
	foreach ($connectedVm in $connectedVms) {
		$title = $connectedVm.MainWindowTitle
		$vmName = ($title -split ' on ')[0]
		stop-vm $vmName -Save:$Save
		spps $connectedVm
	}
}

