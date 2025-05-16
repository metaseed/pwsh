# for Get-DateFromLunar
Import-Module Metaseed.Utility -DisableNameChecking # remove waring:  include unapproved verbs

# birthday
$global:__birthdayType = if ($env:TERM_NERD_FONT) { "`e[95m`e[0m" } else { ""}
$global:__holidayType = "`e[93m󱁖`e[0m"  #  party poper'🎉' # festeval
$global:__specialDays = @{
	Birthday = @{
		Type                  = $__birthdayType
		DaysToRemindInAdvance = 3
		Dates                 = @(
			# @{
			# 	Lable = 'Test'
			# 	# Lunar = $true
			# 	Month = 4
			# 	Day   = 12
			# },
			@{
				Lable = 'Mom'
				Lunar = $true
				Month = 8
				Day   = 8
			},
			@{
				Lable = 'Dad'
				Lunar = $true
				Month = 9
				Day   = 8
			},
			@{
				Lable = 'Me'
				Lunar = $true
				Month = 9
				Day   = 28
			},
			@{
				Lable = 'Me'
				Lunar = $false
				Month = 11
				Day   = 17
			},
			@{
				Lable = 'Echo'
				Lunar = $false
				Month = 6
				Day   = 21
			},
			@{
				Lable = 'Echo'
				Lunar = $true
				Month = 5
				Day   = 20
			},
			@{
				Lable = 'Qi'
				Lunar = $false
				Month = 8
				Day   = 14
			},

			@{
				Lable = 'He'
				Lunar = $false
				Month = 3
				Day   = 5
			},
			@{
				Lable = 'Mai'
				Lunar = $false
				Month = 3
				Day   = 7
			}
		)
	}
	Holiday = @{
		Type                  = $__holidayType
		DaysToRemindInAdvance = 3
		Dates                 = @(
			@{
				Lable = '元旦'
				Month = 1
				Day   = 1
			},
			@{
				Lable = '春节'
				Lunar = $true
				Month = 1
				Day   = 1
				Days  = 8
			},
			@{
				Lable = '四月十八'
				Lunar = $true
				Month = 4
				Day   = 18
			},
			@{
				Lable = '月季花节'
				Lunar = $false
				Month = 5
				Day   = 15
			},
			@{
				Lable = '端午'
				Lunar = $true
				Month = 5
				Day   = 5
			},
			# @{ replaced by 24 solor terms
			# 	Lable = '清明' # in 4.4、4.5、4.6, use 4.5
			# 	Month = 4
			# 	Day   = 5
			# },
			@{
				Lable = '五一'
				Month = 5
				Day   = 1
				Days  = 3
			},
			@{
				Lable                 = '中秋'
				Lunar                 = $true
				DaysToRemindInAdvance = 3
				Month                 = 8
				Day                   = 15
			},
			@{
				Lable = '十一'
				Month = 10
				Day   = 1
				Days  = 3
			}
		)
	}

}

function global:__Get-SolarTerms {
	param (
		[int]$Year
	)

	# Names of the 24 solar terms in Chinese
	$solarTermNames = @(
		"小寒", "大寒", "立春", "雨水", "惊蛰", "春分",
		"清明", "谷雨", "立夏", "小满", "芒种", "夏至",
		"小暑", "大暑", "立秋", "处暑", "白露", "秋分",
		"寒露", "霜降", "立冬", "小雪", "大雪", "冬至"
	)

	# Constants for calculation
	# a fractional value related to the Earth's orbit
	$daysPerYear = 0.2422
	# specific values for each solar term
	$termCoefficients = @(
		5.4055, 20.12, 3.87, 18.73, 5.63, 20.646,
		4.81, 20.1, 5.52, 21.22, 5.678, 21.94,
		7.108, 22.83, 7.5, 23.13, 7.646, 23.042,
		8.318, 23.438, 7.438, 22.36, 7.18, 21.94
	)

	# Calculate leap year adjustment
	$leapYearAdjustment = [math]::Floor($Year / 4) - 15

	# Calculate and return solar terms
	for ($termIndex = 0; $termIndex -lt 24; $termIndex++) {
		$dayOfMonth = [math]::Floor($Year * $daysPerYear + $termCoefficients[$termIndex]) - $leapYearAdjustment
		$month = [math]::Floor($termIndex / 2) + 1

		# Adjust month if it exceeds 12
		if ($month -gt 12) {
			$month -= 12
		}

		# Create date object and adjust day
		$termDate = Get-Date -Year $Year -Month $month -Day 1
		$termDate = $termDate.AddDays($dayOfMonth - 1)

		# Handle year crossover for first two terms
		if ($termIndex -lt 2 -and $termDate.Month -eq 12) {
			$termDate = $termDate.AddYears(1)
		}

		# Create and output custom object for each term
		[PSCustomObject]@{
			Term = $solarTermNames[$termIndex]
			Date = $termDate #.ToString("yyyy-MM-dd")
		}
	}
}

&{
	$termOfThisYear = __Get-SolarTerms ([DateTime]::now).Year
	$terms = @{
		Type                  = $__holidayType
		DaysToRemindInAdvance = 3
		Dates                 = $termOfThisYear|%{

			return 			@{
				Lable = $_.Term
				Month = $_.Date.Month
				Day   = $_.Date.Day
				Days  = 3
			}
		}
	}
	# write-host $a
	if(!$__specialDays.Contains('SolorTerms')){
		$__specialDays.SolorTerms = $terms
	}
}
function global:__GetSpecialDayStr {
	[CmdletBinding()]
	param (
		[Parameter()]
		[datetime]
		$now = [datetime]::now
	)

	$Today = [datetime]::new($now.Year, $now.Month, $now.Day)


	## play background image
	if ($global:__PSReadLineSessionScope.LastSessionStartTime) {
		$s = ($now - $global:__PSReadLineSessionScope.LastSessionStartTime).totalSeconds
		if ($s -gt 10 * 60) {
			# 10mins
			if ($__birthdayType -in $global:SpecialDayTypes -or $__holidayType -in $global:SpecialDayTypes) {
				Show-WTBackgroundImage fireworksMany
			}
		}
	}

	## save computation
	if ($global:Today.Day -eq $Today.Day -and $global:Today.Month -eq $Today.Month -and $global:Today.Year -eq $Today.Year) {
		return $global:SpecialDayStr
	}


	$icon = "`e[93m󰃰`e[0m" # ♥
	$str = ""
	$specialDayTypes = @()
	foreach ($catagery in $__specialDays.Values) {
		$type = $catagery.Type
		$daysToRemindInAdvance = $catagery.DaysToRemindInAdvance
		foreach ($date in $catagery.Dates) {
			if ($date.DaysToRemindInAdvance) { $daysToRemindInAdvance = $date.DaysToRemindInAdvance }

			$lable = $date.Lable
			if ($date.Lunar) {
				$theDay = Get-DateFromLunar $Today.Year $date.Month $date.Day ($date.IsLeap ? $true :$false)
			}
			else {
				try {
					$theDay = [DateTime]::new($Today.Year, $date.Month, $date.Day)
				}
				catch {
					write-host "error: Month:$($date.Month) Day:$($date.Day)"
				}
			}

			if ($theDay -eq $Today -or ($date.Days -and ($theDay -lt $theDay) -and ($Today -lt $theDay.AddDays($date.Days)))) {
				$str = "${str}`e[5m${type}`e[0m$lable"
				$specialDayTypes += $type # only play on the day
			}
			elseif ($theDay -gt $Today) {
				if ($Today.AddDays($daysToRemindInAdvance) -gt $theDay) {
					$days = ($theDay - $Today ).Days
					$str = "${str}${type}$lable($days)"
					# $specialDayTypes += $type
				}
			}
		}
	}

	if ($str) {
		$str = "${icon}$str"
	}
	$global:Today = $Today
	$global:SpecialDayStr = $str
	$global:SpecialDayTypes = $specialDayTypes
	return $str
}

#  __GetSpecialDayStr ([DateTime]::new(2024, 10, 22)) #([DateTime]::new(2024, 3, 7)) #(Get-DateFromLunar 2024 5 1)
