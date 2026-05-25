function Push-Error {
	<#
	.SYNOPSIS
	Saves the current error stack and clears it.

	.DESCRIPTION
	Push-Error and Pop-Error are used to manage the error stack.
	Push-Error saves the error stack and clears the error stack.

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
	[Alias('PushErr')]
	param()

	if (-not $script:ErrorStack) {
		$script:ErrorStack = [System.Collections.Stack]::new()
	}

	$null = $script:ErrorStack.Push(@($global:Error))
	$global:Error.Clear()
}
