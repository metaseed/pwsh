<#
.SYNOPSIS
   update process_env from machine_env and user_env
.DESCRIPTION
   if: it's path and contains ';' => all value from Machine and User, then unique then appended .
   else => value override from Machine and then from User(if has same key name)
.NOTES
User-Level (User): HKCU:\Environment
Machine-Level (Machine): HKLM:\SYSTEM\CurrentControlSet\Control\Session
Process-Level (Process): current process
#>
function Update-ProcessEnvVar {
   @("Machine", "User")  |
   % { [Environment]::GetEnvironmentVariables($_).GetEnumerator() } |
   % {
      # For Path variables, append the new values, if they're not already in there
      $envValue = Get-Content "Env:$($_.Name)" -ErrorAction SilentlyContinue # current value the same as $env:var, but it's a dynamic way, since the name is not determined at code-passing time
      if ($_.Name -match 'Path$|^PATHExt$' -and ($_.Value.Contains(';') -or $envValue.Contains(';'))) {
         $_.Value = ("$envValue;$($_.Value)" -split ';' |?{$_}<#filter out empties i.e.: ;;#>| Select-Object -unique) -join ';'
      }
      $_
   } |
   ? {
      # special handle, otherwise username would be replaced to 'System' instead of your alias
      #  $env:username # jsong12
      #  ([Environment]::GetEnvironmentVariable('UserName','User')) # empty
      # ([Environment]::GetEnvironmentVariable('UserName','Machine')) # SYSTEM

      # > $env:TMP
      # C:\Users\jsong12\AppData\Local\Temp
      # ([Environment]::GetEnvironmentVariable('TMP','User'))
      # C:\Users\jsong12\AppData\Local\Temp
      # ([Environment]::GetEnvironmentVariable('TMP','Machine'))
      # C:\Windows\TEMP

      if ($_.Name -eq 'UserName' -or $_.Name -eq 'TEMP' -or $_.Name -eq 'TMP') {
         return $false
      }

      $envValue = Get-Content "Env:$($_.Name)" -ErrorAction SilentlyContinue
      $update = $_.Value -ne $envValue
      if ($update) {
         Write-Verbose "Update-EnvVar: updated $($_.Name), from: $envValue"
         Write-Verbose "    to: $($_.Value)"
         Write-Verbose ''
         return $true
      } else {
         return $false
      }
   } |
   Set-Content -Path { "Env:$($_.Name)" }

   Write-Verbose 'environment variables updated!'
}
