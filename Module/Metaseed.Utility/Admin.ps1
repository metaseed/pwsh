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
        $msg = "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Write-Warning $msg
        throw $msg
    }
}
