using namespace System.Security.Principal

function Test-Admin {
    ([WindowsPrincipal] [WindowsIdentity]::GetCurrent()).IsInRole([WindowsBuiltInRole] "Administrator")
}

function Assert-Admin {
    If (Test-Admin) {
        Write-Information "Powershell runs in admin mode"
    } 
    else 
    {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        throw
    }
}
