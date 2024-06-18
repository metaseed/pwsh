# for get-lunarDate
Import-Module Metaseed.Utility -DisableNameChecking # remove waring:  include unapproved verbs

function global:__GetSepcialDayStr {
	[CmdletBinding()]
	param (
		[Parameter()]
		[datetime]
		$Today = (Get-Date)
	)
	$Today = [DateTime]::new($Today.Year, $Today.Month, $Today.Day)
	if ($global:Today -eq $Today) {
		return $global:SpecialDayStr
	}

	$specialDays = @(
		@{
			Type                  = '' # birthday
			DaysToRemindInAdvance = 3
			Dates                 = @(
				# @{
				# 	Lable = 'Test'
				# 	Lunar = $true
				# 	Month = 5
				# 	Day   = 1
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
					Day   = 18
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
		},
		@{
			Type                  = '🎉' # festeval
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
					Lable = '端午'
					Lunar = $true
					Month = 5
					Day   = 5
				},
				@{
					Lable = '清明' # in 4.4、4.5、4.6, use 4.5
					Month = 4
					Day   = 5
				},
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

	)
	$icon = "`e[91m♥`e[0m"
	$str = ""
	foreach ($catagery in $specialDays) {
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
				$str = "`e[5m${str}${type}$lable`e[0m"
			}
			elseif ($theDay -gt $Today) {
				if ($Today.AddDays($daysToRemindInAdvance) -gt $theDay) {
					$days = ($theDay - $Today ).Days
					$str = "${str}${type}$lable($days)"
				}
			}
		}
	}

	if ($str) {
		$str = "${icon}$str"
	}
	$global:Today = $Today
	$global:SpecialDayStr = $str

	return $str
}
# __GetSepcialDayStr ([DateTime]::new(2024, 3, 7)) #(Get-DateFromLunar 2024 5 1)
function global:__GetAdminIcon {
	$IsAdmin = ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")
	if ($IsAdmin) {
		if ($env:WT_SESSION) {
	  "`e[93m`e[0m" # person with key https://www.nerdfonts.com/cheat-sheet
		}
		else {
			"`e[33;5;1m!`e[23;25;21m" # green, blink, bold
		}
	}
	else {
		''
	}
}

function global:__GetPSReadLineSessionExeTime {
	if ($global:__PSReadLineSessionScope.SessionStartTime) {
		# 19.3s
		$s = ([datetime]::now - $global:__PSReadLineSessionScope.SessionStartTime).totalseconds
		if ($s -lt 1) {
			$color = "`e[32m" #green
		}
		elseif ($s -lt 3) {
			$color = "`e[33m" # yellow
		}
		else {
			$color = "`e[31m" # red
		}

		if ($s -ge 0.01) {
			# timer
			$icon = $env:WT_SESSION ? "" : ""
			return " ${color}$icon" + $s.ToString("#,0.00") + "s`e[0m"
		}
	}
}

function global:__GetLunarDateStr {
	$lunarDate = Get-LunarDate
	$color = "`e[35m" #Magenta
	# $moon = "" #moon https://www.nerdfonts.com/cheat-sheet
	$calendarWithPlus = ""
	$moons = ""
	$moonOfToday = $moons[$lunarDate.Day]
	$icon = $lunarDate.IsLeapMonth ? "$calendarWithPlus$moonOfToday" : $moonOfToday
	$specialDay = __GetSepcialDayStr
	return "$color$($lunarDate.Month.ToString("#,00"))$icon$($lunarDate.Day.ToString("#,00"))$specialDay`e[0m"
}

function global:__GetDateStr {
	$weekDays = "日一二三四五六"
	$date = Get-Date
	$d = $date.ToString("MM-dd HH:mm:ss")
	$dayOfWeek = $weekDays[$date.DayOfWeek]
	return "`e[95m${d}`e[96m${dayOfWeek}`e[0m"
}
