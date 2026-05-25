$ErrorActionPreference = 'Continue'
$Error.Clear()

. "$PSScriptRoot\..\Push-Error.ps1"
. "$PSScriptRoot\..\Pop-Error.ps1"

function Assert-Equal($Actual, $Expected, [string]$Message) {
	if ($Actual -ne $Expected) {
		throw "$Message`n  expected: $Expected`n  actual:   $Actual"
	}
}

Write-Error "error 1" -EA Continue
Write-Error "error 2" -EA Continue
Push-Error
try { Write-Error "error 3" -EA Continue } finally { Pop-Error }

$messages = @($Error | ForEach-Object { $_.Exception.Message })
Assert-Equal $Error.Count 3 'Pop-Error (default) count'
Assert-Equal ($messages -join ', ') 'error 1, error 2, error 3' 'Pop-Error (default) messages'

$Error.Clear()
Write-Error "error 1" -EA Continue
Write-Error "error 2" -EA Continue
Push-Error
try { Write-Error "error 3" -EA Continue } finally { Pop-Error -OmitErrorsAfterPush }

$messages = @($Error | ForEach-Object { $_.Exception.Message })
Assert-Equal $Error.Count 2 'Pop-Error -OmitErrorsAfterPush count'
Assert-Equal ($messages -join ', ') 'error 1, error 2' 'Pop-Error -OmitErrorsAfterPush messages'

Write-Host 'All Pop-Error tests passed.'
