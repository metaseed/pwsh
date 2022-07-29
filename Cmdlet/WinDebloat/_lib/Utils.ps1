# String: Specifies a null-terminated string. Equivalent to REG_SZ.
# ExpandString: Specifies a null-terminated string that contains unexpanded references to environment variables that are expanded when the value is retrieved. Equivalent to REG_EXPAND_SZ.
# Binary: Specifies binary data in any form. Equivalent to REG_BINARY.
# DWord: Specifies a 32-bit binary number. Equivalent to REG_DWORD.
# MultiString: Specifies an array of null-terminated strings terminated by two null characters. Equivalent to REG_MULTI_SZ.
# Qword: Specifies a 64-bit binary number. Equivalent to REG_QWORD.
# Unknown: Indicates an unsupported registry data type, such as REG_RESOURCE_LIST.
function Set-HKItemProperty {

  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $path,
    $name,
    $value,
    $PropertyType,
    $descriptoin
  )
  if ($descriptoin) {
    Write-Host $descriptoin
  }

  if (!(Test-Path $path)) {
    New-Item $path -Force # force: will create container in middle if not exist. i.e. a\b\c\d if b\c is not exist
  }
  if ($type) {
    Set-ItemProperty $path -Name $name -Value $value -Type $type
  }
  else {
    Set-ItemProperty $path -Name $name -Value $value
  }

}
function Disable-SchTask {
  [CmdletBinding()]
  param (
    [Parameter(ValueFromPipeline)] # to support pipeline
    $taskName
  )
  process {
    # to process item one by one from pipeline
    $task = Get-ScheduledTask "$taskName" -ErrorAction SilentlyContinue
    if ($null -ne $task) {
      if ('Disabled' -eq $task.State) {
        "Already disabled: TaskName: $($task.TaskName), TaskPath: $($task.TaskPath)"
        return
      }
      Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath
      $taskN = Get-ScheduledTask "$taskName" -ErrorAction SilentlyContinue
      " $($task.State) -> $($taskN.State): TaskName: $($task.TaskName), TaskPath: $($task.TaskPath)"
    }
  }
}