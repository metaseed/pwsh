function Test-ParameterValidateSet {
	param (
		[string]$FunctionName,
		[string]$ParameterName,
		[string]$ValueToTest
	)

	# Get the parameter metadata for the specified function and parameter
	$param = (Get-Command -Name $FunctionName).Parameters[$ParameterName]

	# Find the ValidateSet attribute, if it exists
	$validateSet = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }

	if ($null -eq $validateSet) {
		Write-Output "Parameter '$ParameterName' in function '$FunctionName' does not have a ValidateSet attribute."
		return $false
	}

	# Check if the value is in the ValidateSet
	if ($validateSet.ValidValues -contains $ValueToTest) {
		Write-Output "$ValueToTest is valid for parameter '$ParameterName' in function '$FunctionName'."
		return $true
	} else {
		Write-Output "$ValueToTest is not valid for parameter '$ParameterName' in function '$FunctionName'."
		return $false
	}
  }