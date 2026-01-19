. $PSScriptRoot\foreach-combination.ps1
function Get-JumpCodesForWave {
	# target is filter text
	param([string[]]$CodeChars, [int[]]$TargetMatchIndexes, [string] $BufferText, [string] $FilterText, [string[]]$AdditionalSingleCodeChars = @(),  [bool]$AvoidNextCharConflict = $true)

	$codes = @()
	$targetCount = $TargetMatchIndexes.Count;

	if ($targetCount -eq 0) { return $codes }

	$Count = $targetCount - $AdditionalSingleCodeChars.Count

	# usable code chars for the first jump code char, avoid chars that are same as next char after filter
	if ($AvoidNextCharConflict) {
		$usableCodeCharsOfFirstDim = @()
		foreach ($charCode in $CodeChars) {
			$keepThisCharCode = $true
			foreach ($idx in $TargetMatchIndexes) {
				$nextChar = $BufferText[$idx + $FilterText.Length] # note str[out of range] returns $null
				if ($charCode -eq $nextChar) {
					$keepThisCharCode = $false
					break
				}
			}
			if ($keepThisCharCode) {
				$usableCodeCharsOfFirstDim += $charCode
			}
		}

		if ($usableCodeCharsOfFirstDim.Count -eq 0) {
			return $codes # cannot avoid next char conflict, return empty, continue doing ripple typing, to avoid confusion with codeSet
		}
	}
	else {
		$usableCodeCharsOfFirstDim = $CodeChars
	}

	$firstCharCodeSetCount = $usableCodeCharsOfFirstDim.Count

	if ($targetCount -le ($firstCharCodeSetCount + $AdditionalSingleCodeChars.Count)) {
		# Single char codes
		$signalCharCodeSetOfAll = $usableCodeCharsOfFirstDim + $AdditionalSingleCodeChars
		return $signalCharCodeSetOfAll[0..($targetCount - 1)]
		# $dimensions = 1
		# $usedInLowDim = 0
		# $notUsedInLowDim = 0
	}

	# the first dimension is special, the shape is [$firstCharCodeSetCount, $charsetLen, $charsetLen, ..., $charsetLen]
	# $Count > 0  and > $firstCharCodeSetCount here.
	$remainDimensionsShares = $Count / $firstCharCodeSetCount
	# $dimension >= 2 here
	# note: it can handle the special case well too: when $remainDimensionsShares == 1, by calculation the $dimensions is 1, because log(1, any) == 0
	$dimensions = [Math]::Ceiling([Math]::Log($remainDimensionsShares, $charsetLen)) + 1
	# it can handle the case of dimensions is 2:
	$midDims = $dimensions - 1<#first dimension#> - 1 <#highest dimension#>
	$lowDimCount = $firstCharCodeSetCount * [Math]::Pow($charsetLen, $midDims)
	$usedInLowDim_Count = [Math]::Ceiling(($Count - $lowDimCount) / ($charsetLen - 1))

	function Get-CodeOfFullDimensions {
		param($skips = 0, $dimensionCount = $dimensions, $totalCodes = $null)
		# code length of full dimensions
		$fullDimCodes = @()
		if ($totalCodes -le 0) { return $fullDimCodes }

		$dimensionList = @($firstCharCodeSetCount)
		for ($i = 1; $i -lt $dimensionCount - 1; $i++) { $dimensionList += $charsetLen }

		if ($null -eq $totalCodes) {
			$totalCodes = $firstCharCodeSetCount * [Math]::Pow($charsetLen, $dimensionCount - 1)
		}
		$skipsCounter = 0

		foreach-combination -Dimensions $dimensionList -Action {
			param([int[]]$indexes) # x, y, z, ... low to high
			if ($skipsCounter -lt $skips) { $skipsCounter++; return }

			$code = $usableCodeCharsOfFirstDim[$indexes[0]]
			for ($j = 1; $j -lt $indexes.Count; $j++) {
				$code += $CodeChars[$indexes[$j]]
			}
			$fullDimCodes += $code
			if ($fullDimCodes.Count -eq $totalCodes) {
				return $false # break
			}
		}

		return $fullDimCodes
	}

	if ($dimensions -eq 2) {
		# the remaining single char codes(lower dimension codes) + additional single char codes + high dimension codes
		if ($usedInLowDim_Count -le $lowDimCount) {
			$codes += $usableCodeCharsOfFirstDim[$usedInLowDim_Count .. ($lowDimCount - 1)]
			if ($codes.Count -gt $targetCount) {
				return $codes[0..($targetCount - 1)]
			}
		}
		$codes += $AdditionalSingleCodeChars
		if ($codes.Count -gt $targetCount) {
			return $codes[0..($targetCount - 1)]
		}
		$codes += Get-CodeOfFullDimensions -totalCodes ($targetCount - $codes.Count)
		return $codes
	}

	# for dimensions >= 3, the code length is 2 or more
	# additional single char codes + the lower dimensional codes + high dimension codes
	$codes += $AdditionalSingleCodeChars
	if ($codes.Count -gt $targetCount) {
		return $codes[0..($targetCount - 1)]
	}
	$codes += Get-CodeOfFullDimensions -skips $usedInLowDim_Count -dimensionCount $dimensions - 1 -totalCodes ($targetCount - $codes.Count)

	$codes += Get-CodeOfFullDimensions -totalCodes ($targetCount - $codes.Count)

	return $codes
}
