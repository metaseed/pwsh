# for Get-LunarDate
Import-Module Metaseed.Utility -DisableNameChecking # remove waring:  include unapproved verbs
Import-Module Metaseed.Terminal -DisableNameChecking
function global:__GetAdminIcon {
	$IsAdmin= ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
	$clear = "`e[0m" # slb checking no (space})) char before `e[0m in string, use interpolation to walk around
	if ($IsAdmin) {
		if ($env:TERM_NERD_FONT) {
	  		"`e[93m$clear" # person with key https://www.nerdfonts.com/cheat-sheet
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
		# from the 'Enter' key press
		# 19.3s
		$s = ([datetime]::now - $global:__PSReadLineSessionScope.SessionStartTime).totalSeconds
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
			$icon = $env:TERM_NERD_FONT ? "" : ""
			$clear = "`e[0m"
			return " ${color}$icon" + $s.ToString("#,0.00") + "s$clear"
		}
	}
}

function global:__GetLunarDateStr {
	$lunarDate = Get-LunarDate
	$color = "`e[35m" #Magenta
	# $moon = "" #moon https://www.nerdfonts.com/cheat-sheet
	$calendarWithPlus = ""
	$moons = ""
	$moonOfToday = $moons[$lunarDate.Day - 1]
	$icon = $lunarDate.IsLeapMonth ? "$calendarWithPlus$moonOfToday" : $moonOfToday
	return "$color$($lunarDate.Month.ToString("#,00"))$icon$($lunarDate.Day.ToString("#,00"))`e[0m"
}

function global:__GetDateStr {
	$weekDays = "日一二三四五六"
	$date = Get-Date
	$d = $date.ToString("MM-dd HH:mm:ss")
	$dayOfWeek = $weekDays[$date.DayOfWeek]
	return "`e[95m${d}`e[96m${dayOfWeek}`e[0m"
}
