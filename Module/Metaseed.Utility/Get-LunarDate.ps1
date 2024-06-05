function Get-LunarDate {
	[CmdletBinding(DefaultParameterSetName = 'DateTime')]
	param(
		[Parameter(ParameterSetName = 'DateTime', ValueFromPipeline = $true, Position=0)]
		[DateTime]$Date = (Get-Date),

		[Parameter(Mandatory = $true, ParameterSetName = 'DateString', ValueFromPipeline = $true, Position=0)]
		[string]$DateString
	)

	if ($PSCmdlet.ParameterSetName -eq 'DateTime') {
		$DateTime = $Date
	}
	else {
		$DateTime = [DateTime]::Parse($DateString)
	}

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
		Year        = $currentYear
		Month       = $currentMonth
		Day         = $currentDay
		IsLeapMonth = $isLeapMonth
	}
}

# Get-LunarDate "06/21/1981"
# Get-LunarDate