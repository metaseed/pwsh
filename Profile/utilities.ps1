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

# pwsh: to reload directly without change admin rights
function admin {
    # $wt = (Get-Command wt.exe -ErrorAction SilentlyContinue).Source -and ($null -ne $wt)
    $isAdmin = Test-Admin

    if ($isAdmin) {
        write-host 'already admin' -foregroundcolor Green
        pwsh
        return
    }

    if (($null -ne $env:WT_SESSION) ) {
        # https://docs.microsoft.com/en-us/windows/terminal/command-line-arguments?tabs=windows
        # wt -w 0 nt
        Start-Process wt.exe -verb runas -ArgumentList @( "-w", '0', "-d", "$((gl).path)", "-p", "PowerShell")
    }
    else {
        Start-Process pwsh -verb runas -ArgumentList @("-WorkingDirectory", "$((gl).path)")
    } 
    exit 0
}
