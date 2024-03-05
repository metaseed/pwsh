function Get-LunarDate {
	param (
		[DateTime]$DateTime = (Get-Date)
	)

	$chineseCalendar = [System.Globalization.ChineseLunisolarCalendar]::new()
	# $gregorianCal = [System.Globalization.GregorianCalendar]::new()
	# get UTC time of
	$currentYear = $chineseCalendar.GetYear($DateTime)
	$currentMonth = $chineseCalendar.GetMonth($DateTime)
	$currentDay = $chineseCalendar.GetDayOfMonth($DateTime)
	# $hour = $chineseCalendar.GetHour($DateTime)
	# $minute = $chineseCalendar.GetMinute($DateTime)
	# $second = $chineseCalendar.GetSecond($DateTime)
	# $milliSecond = $chineseCalendar.GetMilliSeconds($DateTime)
	$leapMonth = $chineseCalendar.GetLeapMonth($DateTime.Year)
	# $date=[datetime]::new($currentYear,$currentMonth,$currentDay,$hour,$minute,$second,$milliSecond)
	$isLeapMonth = $currentMonth -eq $leapMonth
	return  [PSCustomObject]@{
		Year=$currentYear
		Month = $currentMonth
		Day = $currentDay
		IsLeapMonth = $isLeapMonth
	}
}
