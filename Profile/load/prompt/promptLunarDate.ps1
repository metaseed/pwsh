# for Get-LunarDate
# Import-Module Metaseed.Utility -DisableNameChecking # remove waring:  include unapproved verbs
# Import-Module Metaseed.Terminal -DisableNameChecking
function global:__GetLunarDateStr {
	function ConvertTo-ChineseNumber {
		param(
			[Parameter(Mandatory)]
			[int]$Number
		)

		$digits = @('零', '一', '二', '三', '四', '五', '六', '七', '八', '九')

		switch ($Number) {
			{ $_ -lt 0 } { return $Number.ToString() }
			0 { return '零' }
			{ $_ -ge 1 -and $_ -le 9 } { return $digits[$Number] }
			10 { return '十' }
			{ $_ -ge 11 -and $_ -le 19 } { return "十$($digits[$Number - 10])" }
			20 { return '廿' }
			{ $_ -ge 21 -and $_ -le 29 } { return "廿$($digits[$Number - 20])" }
			30 { return '卅' }
			default {
				# fallback for any larger number (e.g. 42 -> 四十二)
				$tens = [int]($Number / 10)
				$ones = $Number % 10
				$tensStr = if ($tens -ge 0 -and $tens -le 9) { $digits[$tens] } else { $tens.ToString() }
				if ($ones -eq 0) { return "${tensStr}十" }
				if ($ones -ge 0 -and $ones -le 9) { return "${tensStr}十$($digits[$ones])" }
				return "${tensStr}十$ones"
			}
		}
	}

	$lunarDate = Get-LunarDate
	$color = "`e[35m" #Magenta
	# $moon = "" #moon https://www.nerdfonts.com/cheat-sheet
	$calendarWithPlus = ""
	$moons = ""
	$moonOfToday = $moons[$lunarDate.Day - 1]
	$icon = $lunarDate.IsLeapMonth ? "$calendarWithPlus$moonOfToday" : $moonOfToday
	# $monthStr = $lunarDate.Month.ToString("#,00")
	# $dayStr = $lunarDate.Day.ToString("#,00")
	$monthStr = ConvertTo-ChineseNumber -Number $lunarDate.Month
	$dayStr = ConvertTo-ChineseNumber -Number $lunarDate.Day
	return "$color$monthStr$icon$dayStr`e[0m"
}
