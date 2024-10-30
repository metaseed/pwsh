
# pwsh: to reload directly without change admin rights
function New-AdminShell {
    # $wt = (Get-Command wt.exe -ErrorAction SilentlyContinue).Source -and ($null -ne $wt)
    $isAdmin = Test-Admin

    if ($isAdmin) {
        # write-host 'already admin' -foregroundcolor Green
        # https://stackoverflow.com/questions/11546069/refreshing-restarting-powershell-session-w-out-exiting
        # note this will keep the parent pwsh alive
        Invoke-Command { & "pwsh.exe"       } -NoNewScope # PowerShell 7
        return
    }

    if ($env:TERM_NERD_FONT) {
        # in terminal
        # https://docs.microsoft.com/en-us/windows/terminal/command-line-arguments?tabs=windows
        # wt -w 0 nt
        if (gcm wt -ErrorAction Ignore) {
            # installed terminal
            Start-Process wt.exe -verb runas -ArgumentList @( '-w', '0', "-d", "$((gl).path)", "-p", "pwsh")
        }
        else {
            Write-Verbose "new wt of pwsh profile"
            Start-Process wt.exe -verb runas -ArgumentList @( "-d", "$((gl).path)", "-p", "pwsh")
        }
    }
    else {
        Start-Process pwsh -verb runas -ArgumentList @("-WorkingDirectory", "$((gl).path)")
    }
    # need to exit parent after start pwsh, not work
    exit 0
    # still not work, if run get-parentprocess -v -topmost, we will see the parent process still runs
    [System.Diagnostics.Process]::GetCurrentProcess().Kill()
}



New-Alias admin New-AdminShell
