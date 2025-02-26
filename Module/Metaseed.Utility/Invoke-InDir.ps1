function Invoke-InDir {
	<#
    .SYNOPSIS
    Invokes a script block in a specified directory.

    .DESCRIPTION
    This function executes a given script block in a specified directory. It supports
    WhatIf and Confirm parameters for better control over execution.

    .PARAMETER ScriptBlock
    The script block to be executed.

    .PARAMETER Path
    The directory path where the script block will be executed. Defaults to the current directory.

    .PARAMETER WhatIf
    Shows what would happen if the script block were executed without actually executing it.

    .PARAMETER Confirm
    Prompts for confirmation before executing the script block.

    .EXAMPLE
    Invoke-InDir -ScriptBlock { Get-ChildItem } -Path "C:\Temp"
    .EXAMPLE
    Invoke-InDir -ScriptBlock { Get-ChildItem } -Path "C:\Temp" -Confirm
    .EXAMPLE
    Invoke-InDir -ScriptBlock { New-Item "test.txt" } -Path "C:\Temp" -WhatIf
    #>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[ScriptBlock]$ScriptBlock,

		[Parameter()]
		[ValidateScript({ Test-Path -Path $_ -PathType Container })]
		[string]$Path = "."
	)

	begin {
		# Set the current location to the specified path
		Set-Location -Path $Path
	}

	process {
		try {
			if (!$PSCmdlet.ShouldProcess(": Executing script block in directory: $Path")) {
				# support both -whatif and -confirm
				if ($WhatIfPreference) {
					# only -whatif
					Write-Host "What would happen: Executing '$ScriptBlock' in '$Path'"
				}
			}
			else {
				# Execute the script block
				. $ScriptBlock
			}

		}
		catch {
			Pop-Location
			Write-Error "An error occurred while executing the script block: $_"
			throw
		}
	}

	end {
		# Return to the original location
		# note the end block is not executed when exception is thrown in process block
	}
}
#Invoke-InDir -ScriptBlock { New-Item "test.txt" -Force 1>$null } -Path "C:\Temp"