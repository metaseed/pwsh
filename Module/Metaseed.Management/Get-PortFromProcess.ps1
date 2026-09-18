function Get-PortFromProcess {
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
		$Process,

		[Parameter()]
		[ValidateSet('TCP', 'UDP')]
		$PortKind = 'TCP'
	)

	process {
		$processes = if ($Process -is [string]) {
			Get-Process -Name $Process -ErrorAction Stop
		}
		else {
			$Process
		}

		foreach ($p in $processes) {
			if ($PortKind -eq 'TCP') {
				Get-NetTCPConnection -OwningProcess $p.Id -State Listen
			}
			else {
				Get-NetUDPEndpoint -OwningProcess $p.Id
			}
		}
	}
}
# Get-PortFromProcess -Process  'Slb.Planck.Modbus.Plugin'