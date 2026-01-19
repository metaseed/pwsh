<#
if Action return $false will break the loop
#>
function ForEach-Combination {
	param(
		[int[]]$Dimensions,
		[scriptblock]$Action
	)

	$indices = @(0) * $Dimensions.Length

	while ($true) {
		# Execute action for current combination
		$result = & $Action $indices
		if ($result -eq $false) {
			break
		}
		# Increment indices (like an odometer)
		$pos = $Dimensions.Length - 1
		while ($pos -ge 0) {
			$indices[$pos]++
			if ($indices[$pos] -lt $Dimensions[$pos]) {
				break
			}
			$indices[$pos] = 0
			$pos--
		}

		# If we've rolled over all positions, we're done
		if ($pos -lt 0) {
			break
		}
	}
}

# Usage: Return $false to break
# ForEach-Combination @(3, 4, 5) {
#     param($indices)
#     Write-Host "i=$($indices[0]), j=$($indices[1]), k=$($indices[2])"

#     # Break when i=1 and j=2
#     if ($indices[0] -eq 1 -and $indices[1] -eq 2) {
#         return $false
#     }
#     # by default return $null
# }