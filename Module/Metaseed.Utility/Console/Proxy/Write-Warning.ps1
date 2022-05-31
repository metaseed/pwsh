# Begin of ProxyCommand for command: Write-Warning
Function Write-Warning {
	<#
.SYNOPSIS
	Write-Warning [-Message] <string> [<CommonParameters>]
	
#>


	[CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=2097044', RemotingCapability = 'None')]
	param(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[Alias('Msg')]
		[AllowEmptyString()]
		[string]
		${Message})
 	
	begin {
		try {
			$outBuffer = $null
			if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
				$PSBoundParameters['OutBuffer'] = 1
			}
 	
			$wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Warning', [System.Management.Automation.CommandTypes]::Cmdlet)
			$scriptCmd = { & $wrappedCmd @PSBoundParameters }
 	
			$steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
			$steppablePipeline.Begin($PSCmdlet)
		}
		catch {
			throw
		}
	}
 	
	process {
		try {
			WriteWarning $PSBoundParameters
		}
		catch {
			throw
		}
	}
 	
	end {
		try {
			$steppablePipeline.End()
		}
		catch {
			throw
		}
	}
 	
 	

} # End ProxyFunction for command: Write-Warning

