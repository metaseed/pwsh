. $PSScriptRoot\foreach-combination.ps1

function Get-UsableFirstDimensionCodeChars {
	param([string[]]$CodeChars, [string] $BufferText, [int] $TargetTextLength, [int[]]$TargetMatchIndexes)

	$usableCodeChars = @()
	foreach ($charCode in $CodeChars) {
		$keepThisCharCode = $true
		foreach ($idx in $TargetMatchIndexes) {
			$nextChar = $BufferText[$idx + $TargetTextLength] # note str[out of range] returns $null
			if ($charCode -eq $nextChar) {
				$keepThisCharCode = $false
				break
			}
		}
		if ($keepThisCharCode) {
			$usableCodeChars += $charCode
		}
	}
	return $usableCodeChars
}

function Get-JumpCodes{
	# the first dimension is special, the shape is [$firstCharCodeSetCount, $commonDimLen, $commonDimLen, ..., $commonDimLen]
	param([int[]]$TargetMatchIndexes, [string[]]$firstDimCodeChars,[string[]]$commonDimCodeChars, [string[]]$AdditionalSingleCodeChars = @())

	$codes = @()
	$targetCount = $TargetMatchIndexes.Count;

	if ($targetCount -eq 0) { return $codes }
	$commonDimLen = $commonDimCodeChars.Count
	$remainTargetCount = $targetCount - $AdditionalSingleCodeChars.Count

	$firstCharCodeSetCount = $firstDimCodeChars.Count

	# 1-len codes: $firstCharCodeSet + $AdditionalSingleCodeChars
	if ($targetCount -le ($firstCharCodeSetCount + $AdditionalSingleCodeChars.Count)) {
		# Single char codes
		$signalCharCodeSetOfAll = $firstDimCodeChars + $AdditionalSingleCodeChars
		return $signalCharCodeSetOfAll[0..($targetCount - 1)]
		# $dimensions = 1
		# $usedInLowDim_Count = 1
	}

	# $remainTargetCount > 0  and > $firstCharCodeSetCount here.
	$remainDimensionsShares = $remainTargetCount / $firstCharCodeSetCount
	# $dimension >= 2 here
	# note: it can handle the special case well too: when $remainDimensionsShares == 1, by calculation the $dimensions is 1, because log(1, any) == 0
	$dimensions = [Math]::Ceiling([Math]::Log($remainDimensionsShares, $commonDimLen)) + 1
	# it can handle the case of dimensions is 2:
	# note: $midDims = -1 if $dimensions == 1
	$midDims = $dimensions - 1<#first dimension#> - 1 <#highest dimension#>
	# note: with Ceiling the lower dim of 0 dim's elements is 1, when dims is 1
	$lowDimsElementCount = [Math]::Ceiling($firstCharCodeSetCount * [Math]::Pow($commonDimLen, $midDims))
	# note: but here we should use $firstCharCodeSetCount to replace $commonDimLen when dim is 1. so we do 1 dim handler above specially.
	$usedInLowDim_Count = [Math]::Ceiling(($remainTargetCount - $lowDimsElementCount) / ($commonDimLen - 1<# high dim's elements growing from every elements of the lower dims#>))

	function Get-CodeOfFullDimensions {
		param($skips = 0, $dimensionCount = $dimensions, $totalCodesToGet = $null)
		if ($totalCodesToGet -le 0) { return @() }

		$fullDimCodes = @()
		$dimensionList = @($firstCharCodeSetCount)
		for ($i = 1; $i -lt $dimensionCount - 1; $i++) { $dimensionList += $commonDimLen }

		if ($null -eq $totalCodesToGet) {
			$totalCodesToGet = $firstCharCodeSetCount * [Math]::Pow($commonDimLen, $dimensionCount - 1)
		}
		$skipsCounter = 0

		foreach-combination -Dimensions $dimensionList -Action {
			param([int[]]$indexes) # x, y, z, ... low to high
			if ($skipsCounter -lt $skips) { $skipsCounter++; return }

			$code = $firstDimCodeChars[$indexes[0]]
			for ($j = 1; $j -lt $indexes.Count; $j++) {
				$code += $commonDimCodeChars[$indexes[$j]]
			}
			$fullDimCodes += $code
			if ($fullDimCodes.Count -eq $totalCodesToGet) {
				return $false # break
			}
		}

		return $fullDimCodes
	}

	if ($dimensions -eq 2) {
		# the remaining single char codes(lower dimension codes) + additional single char codes + high dimension codes
		if ($usedInLowDim_Count -le $lowDimsElementCount) {
			$codes += $firstDimCodeChars[$usedInLowDim_Count .. ($lowDimsElementCount - 1)]
			if ($codes.Count -gt $targetCount) {
				return $codes[0..($targetCount - 1)]
			}
		}
		$codes += $AdditionalSingleCodeChars
		if ($codes.Count -gt $targetCount) {
			return $codes[0..($targetCount - 1)]
		}
		$codes += Get-CodeOfFullDimensions -totalCodesToGet ($targetCount - $codes.Count)
		return $codes
	}

	# for dimensions >= 3, the code length is 2 or more
	# additional single char codes + the lower dimensional codes + high dimension codes
	$codes += $AdditionalSingleCodeChars
	if ($codes.Count -gt $targetCount) {
		return $codes[0..($targetCount - 1)]
	}
	$codes += Get-CodeOfFullDimensions -skips $usedInLowDim_Count -dimensionCount $dimensions - 1 -totalCodesToGet ($targetCount - $codes.Count)

	$codes += Get-CodeOfFullDimensions -totalCodesToGet ($targetCount - $codes.Count)

	return $codes
}

function Get-JumpCodesForWave {
	# target is filter text
	param([string[]]$CodeChars, [int[]]$TargetMatchIndexes, [string] $BufferText, [int]$TargetTextLength, [string[]]$AdditionalSingleCodeChars = @())

		# usable code chars for the first jump code char, avoid chars that are same as next char after filter
	$usableCodeCharsOfFirstDim = Get-UsableFirstDimensionCodeChars -CodeChars $CodeChars -BufferText $BufferText -TargetTextLength $TargetTextLength -TargetMatchIndexes $TargetMatchIndexes

	if ($usableCodeCharsOfFirstDim.Count -eq 0) {
		return "please continue ripple-typing, or press 'enter' then navigating. (all code chars used by following chars, no enough code chars)" # cannot avoid next char conflict, return empty, continue doing ripple typing, to avoid confusion with codeSet
	}
	$codes = Get-JumpCodes -TargetMatchIndexes $TargetMatchIndexes -firstDimCodeChars $usableCodeCharsOfFirstDim -CodeChars $CodeChars -AdditionalSingleCodeChars $AdditionalSingleCodeChars
	return $codes
}