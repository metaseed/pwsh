function Restart-Process {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [Object]$ProcessInput
    )

    process {
        $processes = @()
        if ($ProcessInput -is [System.Diagnostics.Process]) {
            $processes += $ProcessInput
        }
        elseif ($ProcessInput -is [string]) {
            $processes += Get-Process -Name $ProcessInput -ErrorAction SilentlyContinue
            if ($processes.Count -eq 0) {
                throw "can not find process $ProcessInput"
            }
        }

        foreach ($proc in $processes) {
            try {
                $cimProcess = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $($proc.Id)" -ErrorAction Stop
                $executablePath = $cimProcess.ExecutablePath
                $commandLine = $cimProcess.CommandLine
                # "C:\Windows\system32\notepad.exe" C:\Windows\System32\drivers\etc\hosts
                Write-Verbose "command line: $commandLine"
                $workingDirectory = $cimProcess.CurrentDirectory
            }
            catch {
                Write-Warning "CIM query failed for process $($proc.Name) (ID: $($proc.Id)): $_"
                $executablePath = $proc.Path
                $commandLine = $null
                $workingDirectory = $null
            }

            if (-not $commandLine) {
                Write-Warning "Could not retrieve command line for $($proc.Name) (ID: $($proc.Id)). Restarting without arguments."
                $arguments = ""
            }
            else {
                $arguments = ($commandLine -replace [regex]::Escape("`"$executablePath`""), '').Trim()
            }

            if (-not $workingDirectory) {
                $workingDirectory = Split-Path -Parent $executablePath
            }

            try {
                $proc | Stop-Process -Force -ErrorAction Stop

                $startProcessParams = @{
                    FilePath     = $executablePath
                    ArgumentList = $arguments
                }
                if ($workingDirectory) {
                    $startProcessParams['WorkingDirectory'] = $workingDirectory
                }

                Start-Process @startProcessParams
                Write-Host "Restarted process: $($proc.Name) (ID: $($proc.Id))"
            }
            catch {
                Write-Error "Failed to restart process $($proc.Name) (ID: $($proc.Id)): $_"
            }
        }
    }
}

# Import Pester module for testing
# Import-Module Pester

# # Unit tests for Add-Numbers function
# Describe "Restart-Process tests" {
#     Context "with string as parameter" {
#         It "should restart with original parameter" {
#             start notepad $env:HostsFilePath
#             Restart-Process notepad
#             $notepad = gps notepad
#             $notepad | Should -Not -BeNullOrEmpty -ErrorAction Stop
#             spps $notepad
#         }
#     }

#     Context "with process object as parameter from pipe" {
#         It "should restart with parameter" {
#             start notepad $env:HostsFilePath
#             gps notepad | Restart-Process
#             $notepad = gps notepad
#             $notepad | Should -Not -BeNullOrEmpty -ErrorAction Stop
#             spps $notepad
#         }
#     }
# }
# Restart-Process TerminalBackground

# Invoke-Pester