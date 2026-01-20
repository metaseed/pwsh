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

function Get-JumpCodes {
	# the first dimension is special, the shape is [$firstCharCodeSetCount, $commonDimLen, $commonDimLen, ..., $commonDimLen]
	param([int[]]$TargetMatchIndexes, [string[]]$firstDimCodeChars, [string[]]$commonDimCodeChars, [string[]]$AdditionalSingleCodeChars = @())

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
	# $global:_MetaJumpDebug.GetJumpCodes = @{
	# 	TargetMatchIndexes = $TargetMatchIndexes
	# 	firstDimCodeChars = $firstDimCodeChars
	# 	dimensions = $dimensions
	# 	midDims = $midDims
	# 	lowDimsElementCount = $lowDimsElementCount
	# 	usedInLowDim_Count = $usedInLowDim_Count
	# 	firstCharCodeSetCount = $firstCharCodeSetCount
	# 	commonDimLen = $commonDimLen
	# 	commonDimCodeChars = $commonDimCodeChars
	# 	AdditionalSingleCodeChars = $AdditionalSingleCodeChars
	# 	targetCount = $targetCount

	# }
	function Get-CodeOfFullDimensions {
		param($skips = 0, $dimensionCount = $dimensions, $totalCodesToGet = $null)
		if ($totalCodesToGet -le 0) { return @() }

		$fullDimCodes = [System.Collections.Generic.List[string]]::new()
		$dimensionList = @($firstCharCodeSetCount)
		for ($i = 1; $i -lt $dimensionCount; $i++) { $dimensionList += $commonDimLen }

		if ($null -eq $totalCodesToGet) {
			$totalCodesToGet = $firstCharCodeSetCount * [Math]::Pow($commonDimLen, $dimensionCount - 1)
		}
		$state = @{ skipsCounter = 0 }

		foreach-combination -Dimensions $dimensionList -Action {
			param([int[]]$indexes) # x, y, z, ... low to high
			if ($state.skipsCounter -lt $skips) { $state.skipsCounter++; return }

			$code = $firstDimCodeChars[$indexes[0]]
			for ($j = 1; $j -lt $indexes.Count; $j++) {
				$code += $commonDimCodeChars[$indexes[$j]]
			}
			# $global:_MetaJumpDebug.GetCodeOfFullDimensionsForeach += @(@{index = $indexes; code = $code})
			$fullDimCodes.Add($code)
			if ($fullDimCodes.Count -eq $totalCodesToGet) {
				return $false # break
			}
		}
		# $global:_MetaJumpDebug.GetCodeOfFullDimensions = @{
		# 	skips = $skips
		# 	dimensionList = $dimensionList
		# 	totalCodesToGet = $totalCodesToGet
		# 	dimensionCount = $dimensionCount
		# 	fullDimCodes = $fullDimCodes
		# }
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
	param([string[]]$CodeChars, [int[]]$TargetMatchIndexes, [string] $BufferText, [int]$TargetTextLength, [string[]]$AdditionalSingleCodeChars = @(), [int]$CursorIndex = 0)

	# usable code chars for the first jump code char, avoid chars that are same as next char after filter
	$usableCodeCharsOfFirstDim = Get-UsableFirstDimensionCodeChars -CodeChars $CodeChars -BufferText $BufferText -TargetTextLength $TargetTextLength -TargetMatchIndexes $TargetMatchIndexes

	if ($usableCodeCharsOfFirstDim.Count -eq 0) {
		throw "please continue ripple-typing, or press 'enter' then navigating. (all code chars used by following chars, no enough code chars)" # cannot avoid next char conflict, return empty, continue doing ripple typing, to avoid confusion with codeSet
	}
	$codes = Get-JumpCodes -TargetMatchIndexes $TargetMatchIndexes -firstDimCodeChars $usableCodeCharsOfFirstDim -commonDimCodeChars $CodeChars -AdditionalSingleCodeChars $AdditionalSingleCodeChars

	if ($codes.Count -ne $TargetMatchIndexes.Count) {
            throw "MetaJump: Code count mismatch:  codes($($codes.Count)) != TargetMatchIndexes($(TargetMatchIndexes.Count))"
	}

	# align codes around cursor since we have cursor index and targetMatchIndexes
	$codes = Align-CodesAroundCursor -Codes $codes -TargetMatchIndexes $TargetMatchIndexes -CursorIndex $CursorIndex

	return $codes
}

function Align-CodesAroundCursor {
	param (
		[string[]]$Codes,
		[int[]]$TargetMatchIndexes,
		[int]$CursorIndex
	)
	if($CursorIndex -eq 0) {
		return $Codes
	}
	if($CursorIndex -ge $TargetMatchIndexes[-1]) {
		# reverse the codes
		$newCodes = $Codes[($Codes.Count - 1)..0]
		return $newCodes
	}

	$newCodes = [string[]]::new($Codes.Count)
	# find the index in TargetMatchIndexes of the first match that is after the cursor
	$left = 0
	for ($i = 0; $i -lt $TargetMatchIndexes.Count; $i++) {
		if ($TargetMatchIndexes[$i] -gt $CursorIndex) {
			$left = $i
			break
		}
	}
	$right = $left + 1
	$index = 0

	while($left -ge 0 -and $right -lt $TargetMatchIndexes.Count) {
		$newCodes[$left] = $Codes[$index]
		$newCodes[$right] = $Codes[$index + 1]
		$left--;
		$right++;
		$index += 2
	}
	while ($left -ge 0) {
		$newCodes[$left] = $Codes[$index]
		$left--
		$index++
	}
	while ($right -lt $TargetMatchIndexes.Count) {
		$newCodes[$right] = $Codes[$index]
		$right++
		$index++
	}
	$global:_MetaJumpDebug.AlignCodesAroundCursor = @{
		Codes = $Codes
		TargetMatchIndexes = $TargetMatchIndexes
		CursorIndex = $CursorIndex
		NewCodes = $newCodes
	}
	return $newCodes
}

# $Config = @{
#     CodeChars                 = "k, j, d, f, l, s, a, h, g, i, o, n, u, r, v, c, w, e, x, m, b, p, q, t, y, z" -split ',' | ForEach-Object { $_.Trim() }
#     # only appears as one char decoration codes
#     AdditionalSingleCodeChars = "J,D,F,L,A,H,G,I,N,R,E,M,B,Q,T,Y, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0" -split ',' | ForEach-Object { $_.Trim() }
#     # bgColors for one-length code, two-length code, 3-length code, ect..
#     # if the code length is larger than the array length, the last color is used
#     CodeBackgroundColors      = @("Yellow", "Blue", "Cyan", "Magenta")
#     TooltipText               = "Jump: type target char..."
# }
# Get-JumpCodesForWave $Config.CodeChars