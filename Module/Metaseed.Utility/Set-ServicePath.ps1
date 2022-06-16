<#
.SYNOPSIS
modify service path
#>
function Set-SetvicePath {
    [CmdletBinding()]
    param (
        # service name
        [Parameter()]
        [String]
        [Alias("n")]
        $Name = "Slb.Planck.Presto.ControlGateway.Service",
        # exe path to use
        [Parameter()]
        [String]
        [Alias("p")]
        $Path,
        # toggle the service path between the last-path and the current-path
        [Alias("t")]
        [switch]
        $Toggle
    )

    Assert-Admin

    $RegPath = "HKLM:\System\CurrentControlSet\Services\$Name"
    try {
        $ImagePath = Get-ItemPropertyValue -Path $RegPath -Name ImagePath -ErrorAction Stop
    }
    catch {
        Write-Error "Service: $Name is not installed!"
        return;
    }

    Stop-Service -Name $Name -Force
    Stop-Process -Name $Name -Force -ErrorAction SilentlyContinue

    if ($Toggle) {
        try {
            $Backup = Get-ItemPropertyValue -Path $RegPath -Name ImagePathBackup -ErrorAction Stop
        }
        catch {
            Write-Host "-- Please set the service path with(without -t): -Name service-name -Path service-exe-path"
            return;
        }
        Set-ItemProperty -Path $RegPath -Name ImagePath -Value $Backup -Type ExpandString
        Set-ItemProperty -Path $RegPath -Name ImagePathBackup -Value $ImagePath -Type ExpandString
        Write-Host "-- Service path: $Backup"
        return;
    }

    if (-not (Test-Path $Path -PathType Leaf)) {
        Write-Error "-- Path not right: $Path"
        return;
    }

    Set-ItemProperty -Path $RegPath -Name ImagePathBackup -Value $ImagePath -Type ExpandString
    Set-ItemProperty -Path $RegPath -Name ImagePath -Value $Path -Type ExpandString
    Write-Host "-- Service path: $Path"
}