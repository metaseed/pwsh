function SetTimeZoneTo {
    [cmdletbinding()]
    param (
        [parameter()][string]$city
    )
    Write-Verbose "Searching for timezone containing city: $City"
    $AllTimeZones = Get-TimeZone -ListAvailable
    $MatchingTimeZones = $AllTimeZones | Where-Object {
        $_.DisplayName -like "*$City*" -or 
        $_.Id -like "*$City*" -or
        $_.StandardName -like "*$City*"
    }

    if ($MatchingTimeZones.Count -eq 0) {
        Write-Warning "No timezone found containing '$City'"
        return;
    }
    elseif($MatchingTimeZones.Count -gt 1)  {
        # Multiple matches found - let user choose or pick the best match
        Write-Host "Please use a more specific name, mMultiple timezones found for '$City':" -ForegroundColor Yellow
        for ($i = 0; $i -lt $MatchingTimeZones.Count; $i++) {
            $tz = $MatchingTimeZones[$i]
            Write-Host "  [$($i + 1)] $($tz.Id): $($tz.DisplayName)" -ForegroundColor Gray
        }
        return
    }

    $SelectedTimeZone = $MatchingTimeZones[0]

    Write-Verbose "Setting timezone to: $($SelectedTimeZone.Id)"
    Write-Host "Setting timezone to: $($SelectedTimeZone.DisplayName)" -ForegroundColor Green
        
    # Set the timezone
    Set-TimeZone -Id $SelectedTimeZone.Id -ErrorAction Stop
        
    Write-Host "Successfully set timezone to $($SelectedTimeZone.Id)" -ForegroundColor Green
        
    # Display current time in the new timezone
    $CurrentTime = Get-Date
    Write-Host "Current time: $CurrentTime" -ForegroundColor Cyan
        
    # Show timezone details
    $CurrentTimeZone = Get-TimeZone
    Write-Verbose "Current timezone details:"
    Write-Verbose "  ID: $($CurrentTimeZone.Id)"
    Write-Verbose "  DisplayName: $($CurrentTimeZone.DisplayName)"
    Write-Verbose "  StandardName: $($CurrentTimeZone.StandardName)"
    Write-Verbose "  BaseUtcOffset: $($CurrentTimeZone.BaseUtcOffset)"
}

# SetTimeZoneTo paris