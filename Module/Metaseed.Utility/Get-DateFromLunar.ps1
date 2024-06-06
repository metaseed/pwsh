function Get-DateFromLunar {
    param (
        [Parameter(Mandatory=$true)]
        [int]$Year,
        [Parameter(Mandatory=$true)]
        [int]$Month,
        [Parameter(Mandatory=$true)]
        [int]$Day,
        [Parameter()]
        [bool]$IsLeapMonth = $false
    )

    $chineseCalendar = [System.Globalization.ChineseLunisolarCalendar]::new()
    $lunarYear = $Year

    # Calculate the leap month index
    $leapMonth = $chineseCalendar.GetLeapMonth($lunarYear)
    if ($IsLeapMonth -and $leapMonth -eq 0) {
        Write-Error "The lunar year $lunarYear does not have a leap month."
        return
    }

    $monthIndex = if ($IsLeapMonth) { $leapMonth } else { $Month }

    # Convert the lunar date to a Gregorian DateTime
    $gregorianDate = $chineseCalendar.ToDateTime($lunarYear, $monthIndex, $Day, 0, 0, 0, 0, 0)

    return $gregorianDate
}

# Get-DateFromLunar 1981 5 20