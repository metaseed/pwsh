function Get-LunarDate {
	[CmdletBinding(DefaultParameterSetName = 'DateTime')]
	param(
		[Parameter(ParameterSetName = 'DateTime', ValueFromPipeline = $true, Position = 0)]
		[DateTime]$Date = (Get-Date),

		[Parameter(Mandatory = $true, ParameterSetName = 'DateString', ValueFromPipeline = $true, Position = 0)]
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
	# If there is a leap month between the eighth and ninth months of the year, 
	# the GetMonth(DateTime) method returns 8 for the eighth month, 
	# 9 for the leap eighth month, and 10 for the ninth month.
	$currentMonth = $chineseCalendar.GetMonth($DateTime)
	$currentDay = $chineseCalendar.GetDayOfMonth($DateTime)
	# $hour = $chineseCalendar.GetHour($DateTime)
	# $minute = $chineseCalendar.GetMinute($DateTime)
	# $second = $chineseCalendar.GetSecond($DateTime)
	# $milliSecond = $chineseCalendar.GetMilliSeconds($DateTime)
	$leapMonth = $chineseCalendar.GetLeapMonth($currentYear)
	# $date=[datetime]::new($currentYear,$currentMonth,$currentDay,$hour,$minute,$second,$milliSecond)

	if ($leapMonth -gt 0 -and $currentMonth -gt $leapMonth) {
		$currentMonth--
		$isLeapMonth = $currentMonth -eq ($leapMonth + 1)
	}

	
	return  [PSCustomObject]@{
		Year        = $currentYear
		Month       = $currentMonth
		Day         = $currentDay
		IsLeapMonth = $isLeapMonth
	}
}

# Get-LunarDate "06/21/1981"
# Get-LunarDate "09/29/2025" # should return 8/8/2025 
#Get-LunarDate "08/1/2025" 
