function Get-ErrorDetails {
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[System.Management.Automation.ErrorRecord]$ErrorRecord
	)

	return [PSCustomObject]@{
		Exception = $ErrorRecord.Exception.GetType().FullName
		Message = $ErrorRecord.Exception.Message
		Category = $ErrorRecord.CategoryInfo.Category
		Location = $ErrorRecord.InvocationInfo.PositionMessage
		StackTrace = $ErrorRecord.ScriptStackTrace
		Line = $ErrorRecord.InvocationInfo.Line
		LineNumber = $ErrorRecord.InvocationInfo.ScriptLineNumber
		ColumnNumber = $ErrorRecord.InvocationInfo.OffsetInLine
	}
}

function Write-ErrorDetails {
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[System.Management.Automation.ErrorRecord]$ErrorRecord
	)

	 $ErrorRecord| Get-ErrorDetails | Format-List|Out-String|Write-Host
}

Export-ModuleMember -Function Write-ErrorDetails