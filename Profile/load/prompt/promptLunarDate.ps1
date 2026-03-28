# for Get-LunarDate
# Import-Module Metaseed.Utility -DisableNameChecking # remove waring:  include unapproved verbs
# Import-Module Metaseed.Terminal -DisableNameChecking
function global:__GetLunarDateStr {
	$lunarDate = Get-LunarDate
	$color = "`e[35m" #Magenta
	# $moon = "" #moon https://www.nerdfonts.com/cheat-sheet
	$calendarWithPlus = ""
	$moons = ""
	$moonOfToday = $moons[$lunarDate.Day - 1]
	$icon = $lunarDate.IsLeapMonth ? "$calendarWithPlus$moonOfToday" : $moonOfToday
	return "$color$($lunarDate.Month.ToString("#,00"))$icon$($lunarDate.Day.ToString("#,00"))`e[0m"
}
