using namespace System.Collections.Generic;

. $PSScriptRoot\foreach-combination.ps1

function Get-UsableFirstDimensionCodeChars {
	param([string[]]$CodeChars, [string] $BufferText, [int[]]$TargetMatchIndexes, [int] $TargetTextLength)

	$usableCodeChars = @()
	foreach ($charCode in $CodeChars) {
		$keepThisCharCode = $true
		foreach ($idx in $TargetMatchIndexes) {
			$nextChar = $BufferText[$idx + $TargetTextLength] # note str[out of range] returns $null
			# use -eq not -ceq, so 'T' -eq 't'
			# if T is next char, and t in code, we should filter out of the code t
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
	# the first dimension is special, the shape is [$firstDimLen, $commonDimLen, $commonDimLen, ..., $commonDimLen]
	param([int[]]$TargetMatchIndexes, [string[]]$firstDimCodeChars, [string[]]$commonDimCodeChars, [string[]]$AdditionalSingleCodeChars = @())

	$codesRt = @()
	$targetCount = $TargetMatchIndexes.Count;

	if ($targetCount -eq 0) { return $codesRt }

	$firstDimLen = $firstDimCodeChars.Count
	$commonDimLen = $commonDimCodeChars.Count
	$remainTargetCount = $targetCount - $AdditionalSingleCodeChars.Count

	# 1-len codes: $firstCharCodeSet + $AdditionalSingleCodeChars
	# $dimensions = 1
	if ($targetCount -le ($firstDimLen + $AdditionalSingleCodeChars.Count)) {
		# Single char codes
		$signalCharCodeSetOfAll = $firstDimCodeChars + $AdditionalSingleCodeChars
		return $signalCharCodeSetOfAll[0..($targetCount - 1)]
	}

	# $remainTargetCount > 0  and > $firstDimLen here.
	# $dimension >= 2 here
	$countPerFirstDimElem = $remainTargetCount / $firstDimLen
	# note: it can NOT handle the special 1-dim case well too: when $countPerFirstDimElem is (0,1], i.e.  log(0.1, 10) == -1, +1 == 0
	$dimensions = [Math]::Ceiling([Math]::Log($countPerFirstDimElem, $commonDimLen)) + 1
	# it can handle the case of dimensions is >=2:
	# note: $midDims = -1 if $dimensions == 1
	$midDims = $dimensions - 1<#first dimension#> - 1 <#highest dimension#>
	# note: when dim = 1, the ceiling result is 1. should be 0, so not work.
	$lowDimsElementCount = $firstDimLen * [Math]::Pow($commonDimLen, $midDims)
	# note: but here we should use $firstDimLen to replace $commonDimLen when dim is 1. so we do 1 dim handler above specially.
	$usedInLowDim_Count = [Math]::Ceiling(($remainTargetCount - $lowDimsElementCount) / ($commonDimLen - 1<# high dim's elements growing from every elements of the lower dims#>))
	# $global:_MetaJumpDebug.GetJumpCodes = @{
	# 	TargetMatchIndexes = $TargetMatchIndexes
	# 	firstDimCodeChars = $firstDimCodeChars
	# 	dimensions = $dimensions
	# 	midDims = $midDims
	# 	lowDimsElementCount = $lowDimsElementCount
	# 	usedInLowDim_Count = $usedInLowDim_Count
	# 	firstCharCodeSetCount = $firstDimLen
	# 	commonDimLen = $commonDimLen
	# 	commonDimCodeChars = $commonDimCodeChars
	# 	AdditionalSingleCodeChars = $AdditionalSingleCodeChars
	# 	targetCount = $targetCount
	# }
	function Get-CodeOfFullDimensions {
		param($skips = 0, $dimensionCount = $dimensions, $totalCodesToGet = -1)

		if (-1 -eq $totalCodesToGet) {
			$totalCodesToGet = $firstDimLen * [Math]::Pow($commonDimLen, $dimensionCount - 1)
		}
		elseif ($totalCodesToGet -le 0) {
			return @()
		}

		$fullDimCodes = [List[string]]::new()
		$dimensionList = @($firstDimLen) + @($commonDimLen) * ($dimensionCount - 1)

		$state = @{ skipsCounter = 0 }# pass by reference

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
		if ($usedInLowDim_Count -lt $lowDimsElementCount) {
			# $a = @(1,2,3,4,5,6,7,8,9) $a[7..8] is @(8,9); one remain: $a[8..8] is 9, (all used: $a[9..8] is 9: wrong)
			# pwsh's range index design is bad! too many surprise!
			$codesRt += $firstDimCodeChars[$usedInLowDim_Count .. ($lowDimsElementCount - 1)]
		}
		# not needed s dims is 2
		# if ($codesRt.Count -gt $targetCount) {
		# 	return $codesRt[0..($targetCount - 1)]
		# }
		$codesRt += $AdditionalSingleCodeChars
		# not needed as dims is 2
		# if ($codesRt.Count -gt $targetCount) {
		# 	return $codesRt[0..($targetCount - 1)]
		# }
		$codesRt += Get-CodeOfFullDimensions -totalCodesToGet ($targetCount - $codesRt.Count)
		return $codesRt
	}

	# for dimensions >= 3, the code length is 2 or more
	# additional single char codes + the lower dimensional codes + high dimension codes
	$codesRt += $AdditionalSingleCodeChars
	# not needed s dims >=3
	# if ($codesRt.Count -gt $targetCount) {
	# 	return $codesRt[0..($targetCount - 1)]
	# }
	$codesRt += Get-CodeOfFullDimensions -skips $usedInLowDim_Count -dimensionCount ($dimensions - 1)

	$codesRt += Get-CodeOfFullDimensions -totalCodesToGet ($targetCount - $codesRt.Count)

	return $codesRt
}

function Get-JumpCodesForWave {
	# target is filter text
	param([string[]]$CodeChars, [int[]]$TargetMatchIndexes, [string] $BufferText, [int]$TargetTextLength, [string[]]$AdditionalSingleCodeChars = @(), [int]$CursorIndex = 0)

	# usable code chars for the first jump code char, avoid chars that are same as next char after filter
	$usableCodeCharsOfFirstDim = Get-UsableFirstDimensionCodeChars -CodeChars $CodeChars -BufferText $BufferText -TargetMatchIndexes $TargetMatchIndexes -TargetTextLength $TargetTextLength

	if ($usableCodeCharsOfFirstDim.Count -eq 0) {
		throw "please continue ripple-typing, or press 'enter' then navigating. (all code chars used by following chars, no enough code chars)" # cannot avoid next char conflict, return empty, continue doing ripple typing, to avoid confusion with codeSet
	}
	$codesRt = Get-JumpCodes -TargetMatchIndexes $TargetMatchIndexes -firstDimCodeChars $usableCodeCharsOfFirstDim -commonDimCodeChars $CodeChars -AdditionalSingleCodeChars $AdditionalSingleCodeChars

	# align codes around cursor since we have cursor index and targetMatchIndexes
	$codesRt = Align-CodesAroundCursor -Codes $codesRt -TargetMatchIndexes $TargetMatchIndexes -CursorIndex $CursorIndex

	return $codesRt
}

function Align-CodesAroundCursor {
	param (
		[string[]]$Codes,
		[int[]]$TargetMatchIndexes,
		[int]$CursorIndex
	)
	if ($Codes.Length -ne $TargetMatchIndexes.Length) {
		throw "MetaJump: Code count mismatch:  codes($($Codes.L)) != TargetMatchIndexes($(TargetMatchIndexes.Length))"
	}

	if ($CursorIndex -le $TargetMatchIndexes[0]) {
		return $Codes
	}
	if ($CursorIndex -ge $TargetMatchIndexes[-1]) {
		# reverse the codes
		$newCodes = $Codes[($Codes.Count - 1)..0]
		return $newCodes
	}
	# here: $TargetMatchIndexes.Length >=2 and $CursorIndex in the middle
	$newCodes = [string[]]::new($Codes.Count)
	# find the index in TargetMatchIndexes of the first match that is after the cursor
	$left = 0
	for ($i = 0; $i -lt $TargetMatchIndexes.Count; $i++) {
		if ($TargetMatchIndexes[$i] -gt $CursorIndex) {
			$left = $i - 1
			break
		}
	}
	$right = $left + 1
	$index = 0

	while ($left -ge 0 -and $right -lt $TargetMatchIndexes.Count) {
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
	# $global:_MetaJumpDebug.AlignCodesAroundCursor = @{
	# 	Codes              = $Codes
	# 	TargetMatchIndexes = $TargetMatchIndexes
	# 	CursorIndex        = $CursorIndex
	# 	NewCodes           = $newCodes
	# }
	return $newCodes
}
