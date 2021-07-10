function Set-StartTask {
    [CmdletBinding()]
    param (
        [string]$taskName,
        [string] $exe,
        [string] $arg
    )

    $ErrorActionPreference = "Continue"
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($null -ne $task) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false 
    }

    $action = New-ScheduledTaskAction -Execute $exe -Argument $arg
    $trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:10
    $settings = New-ScheduledTaskSettingsSet -Compatibility Win8
    $principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
    $definition = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings -Description "Run $($taskName) at startup"

    Register-ScheduledTask -TaskName $taskName -InputObject $definition

    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

    if ($null -ne $task) {
        "Created scheduled task: '$($task.ToString())'."
    }
    else {
        "Created scheduled task: FAILED."
    }
}