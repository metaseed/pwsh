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
			$icon = $env:WT_SESSION ? "󰔛" : " "
			return " ${color}$icon" + $s.ToString("#,0.00") + "s`e[0m"
		}
	}
}
# for get-lunarDate
Import-Module Metaseed.Utility -DisableNameChecking # remove waring:  include unapproved verbs
function global:__GetLunarDateStr {
	$lunarDate = Get-LunarDate
	$color = "`e[35m" #Magenta
	# $moon = "" #moon https://www.nerdfonts.com/cheat-sheet
	$calendarWithPlus = ""
	$moons = ""
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
. $PSScriptRoot/_specialDays.ps1
