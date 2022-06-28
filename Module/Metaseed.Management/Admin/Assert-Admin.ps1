using namespace System.Security.Principal

function Test-Admin {
    # $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    # $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    ([WindowsPrincipal] [WindowsIdentity]::GetCurrent()).IsInRole([WindowsBuiltInRole] "Administrator")
}

function Assert-Admin {
    If (Test-Admin) {
        Write-Verbose "Powershell runs in admin mode"
    } 
    else {
        $msg = "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Write-Warning $msg
        # https://stackoverflow.com/questions/2022326/terminating-a-script-in-powershell#answer-45030002
        Break Script
    }
}


Export-ModuleMember -Function Test-Admin