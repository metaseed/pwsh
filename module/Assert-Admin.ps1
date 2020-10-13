using namespace System.Security.Principal

function Assert-Admin {
    If (-NOT ([WindowsPrincipal] [WindowsIdentity]::GetCurrent()).IsInRole([WindowsBuiltInRole] "Administrator")) {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        throw
    }
    else {
        Write-Host "Powershell runs in admin mode"
    }
}