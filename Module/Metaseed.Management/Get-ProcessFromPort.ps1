enum PortKind {
	TCP; UDP
}
function Get-ProcessFromPort {
	[CmdletBinding()]
	param (
		# port number
		[Parameter()]
		[int]
		$PortNumber,

		# tcp or udp
		[Parameter()]
		[PortKind]
		$PortKind = [PortKind]::TCP
	)

	if ($PortKind -eq [PortKind]::TCP) {
		Get-Process -Id (Get-NetTCPConnection -LocalPort $PortNumber).OwningProcess
	}
 else {
		Get-Process -Id (Get-NetUDPEndpoint -LocalPort $PortNumber).OwningProcess
	}
}
