enum StartAt {
    Startup;
    LogOn
}
function Set-StartTask {
    [CmdletBinding()]
    param (
        [string]$taskName,
        [string]$exe,
        [string]$arg,
        [StartAt]$When = [StartAt]::Startup,
        [TimeSpan]$randomDelay = '00:00:10'
    )

    $ErrorActionPreference = "Continue"
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($null -ne $task) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }

    $action = New-ScheduledTaskAction -Execute $exe -Argument $arg
    if($When -eq [StartAt]::Startup) {
        $trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay $randomDelay
    } else {
        $trigger = New-ScheduledTaskTrigger -AtLogOn -RandomDelay $randomDelay
    }
    $settings = New-ScheduledTaskSettingsSet -Compatibility Win10
    $principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
    $definition = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings -Description "Run $($taskName) at $When"

    Register-ScheduledTask -TaskName $taskName -InputObject $definition

    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

    if ($null -ne $task) {
        "Created scheduled task: '$($task.ToString())'."
    }
    else {
        "Created scheduled task: FAILED."
    }
}
