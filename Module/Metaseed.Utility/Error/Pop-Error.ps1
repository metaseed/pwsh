function Pop-Error {
	<#
	.SYNOPSIS
	Restores a previously saved error stack.

	.DESCRIPTION
	Pop-Error restores the error stack to the previous saved state and appends the current errors by default.
	Pop-Error -OmitErrorsAfterPush restores only the last saved error stack, discarding current errors.

	.EXAMPLE
	Write-Error "error 1"
	Write-Error "error 2"
	Push-Error
	try {
		Write-Error "error 3"
		$error # output: error 3
	}
	finally {
		Pop-Error
	}
	$error # output: error 1, error 2, error 3

	.EXAMPLE
	Write-Error "error 1"
	Write-Error "error 2"
	Push-Error
	try {
		Write-Error "error 3"
		$error # output: error 3
	}
	finally {
		Pop-Error -OmitErrorsAfterPush
	}
	$error # output: error 1, error 2
	#>
	[CmdletBinding()]
	[Alias('PopError')]
	param(
		[switch]$OmitErrorsAfterPush
	)

	if (-not $script:ErrorStack -or $script:ErrorStack.Count -eq 0) {
		throw 'No saved error stack to restore. Call Push-Error first.'
	}

	$currentErrors = if ($OmitErrorsAfterPush) { @() } else { @($global:Error) }
	$savedErrors = $script:ErrorStack.Pop()

	$global:Error.Clear()

	for ($i = $savedErrors.Count - 1; $i -ge 0; $i--) {
		$null = $global:Error.Add($savedErrors[$i])
	}

	for ($i = $currentErrors.Count - 1; $i -ge 0; $i--) {
		$null = $global:Error.Add($currentErrors[$i])
	}
}
