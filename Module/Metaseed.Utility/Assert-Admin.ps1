using namespace System.Security.Principal

function Test-Admin {
    ([WindowsPrincipal] [WindowsIdentity]::GetCurrent()).IsInRole([WindowsBuiltInRole] "Administrator")
}

function Assert-Admin {
    If (Test-Admin) {
        Write-Verbose "Powershell runs in admin mode"
    } 
    else {
        $msg = "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Write-Warning $msg
        exit
    }
}


# if (runasadmin $PSCommandPath $PSBoundParameters) { return }
# 
Function RunAsAdmin {
    [CmdletBinding()]
    param(
        $File = $script:PSCommandPath,
        $AllParameters = $script:PSBoundParameters,
        [switch]
        $Wait
    )

    if (Test-Admin) {
        Write-Warning "You do not have Administrator rights to run this script!`nRe-run this script as an Administrator!"
        return $false
    }


    $AllParameters_String = @();
    ForEach ($Parameter in $AllParameters.GetEnumerator()) {
        $Parameter_Key = $Parameter.Key;
        $Parameter_Value = $Parameter.Value;
        $Parameter_Value_Type = $Parameter_Value.GetType().Name;

        If ($Parameter_Value_Type -Eq "SwitchParameter") {
            $AllParameters_String += "-$Parameter_Key";
        }
        Else {
            $AllParameters_String += "-$Parameter_Key $Parameter_Value";
        }
    }
    $Arguments = "-NoExit", "-File `"$File`"" + $AllParameters_String

    $PSHost = If ($PSVersionTable.PSVersion.Major -le 5) { 'PowerShell' } Else { 'PwSh' }
    
    Start-Process "$PSHost $($Wait ? '-Wait':'')" -Verb Runas -ArgumentList $Arguments;
    return $true
}

Export-ModuleMember -Function Test-Admin, RunAsAdmin