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

    $monthIndex = $Month
    if ($IsLeapMonth) {
        $monthIndex = $Month + 1
    } elseif ($leapMonth -gt 0 -and $Month -ge $leapMonth) {
        # If there is a leap month and the requested month is after the leap month,
        # we need to increment the month index for the calendar methods.
        $monthIndex++
    }

    # Convert the lunar date to a Gregorian DateTime
    $gregorianDate = $chineseCalendar.ToDateTime($lunarYear, $monthIndex, $Day, 0, 0, 0, 0, 0)

    return $gregorianDate
}

# Get-DateFromLunar 1981 5 20
# `Get-DateFromLunar 2025 8 8 # returns 2025-09-29