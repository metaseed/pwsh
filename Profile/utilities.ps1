function sudo {
    Start-Process -Verb RunAs -FilePath "pwsh" -ArgumentList (@("-NoExit", "-Command") + $args)
}

# make and change directory
function mcd {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )

    # mkdir path
    New-Item -Path $Path -ItemType Directory
    # cd path
    Set-Location -Path $Path
}

# pwsh: to reload directly
function admin {
    Start-Process pwsh -verb runas 
    exit 0
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
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if ($isAdmin) { return $false}

    Write-Warning "You do not have Administrator rights to run this script!`nRe-run this script as an Administrator!"

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
    # "& '" +$myinvocation.mycommand.definition + "'"
    Start-Process "$PSHost $($Wait ? '-Wait':'')" -Verb Runas -ArgumentList $Arguments;
    return $true
}