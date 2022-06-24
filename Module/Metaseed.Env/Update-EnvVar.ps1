<#
.SYNOPSIS
   update process_env from machine_env and user_env
.DESCRIPTION
   if: it's path and contains ';' => all value from Machine and User, then uniqued then appended .
   else => value override from Manchine and then from User(if has same key name)
#>
function Update-EnvVar {
   @("Machine", "User")  | 
   % { [Environment]::GetEnvironmentVariables($_).GetEnumerator() } |
   % {
      # For Path variables, append the new values, if they're not already in there
      $envValue = Get-Content "Env:$($_.Name)" -ErrorAction SilentlyContinue
      if ($_.Name -match 'Path$|^PATHExt$' -and ($_.Value.Contains(';') -or $envValue.Contains(';'))) { 
         $_.Value = ("$envValue;$($_.Value)" -split ';' | Select-Object -unique) -join ';'
      }
      $_
   } |
   ? {
      # special handle, otherwise username would be replaced to 'System'
      if ($_.Name -eq 'UserName' -or $_.Name -eq 'TEMP' -or $_.Name -eq 'TMP') {
         return $false
      }
      $envValue = Get-Content "Env:$($_.Name)" -ErrorAction SilentlyContinue
      $update = $_.Value -ne $envValue
      if ($update) {
         Write-Verbose "Update-EnvVar: updated $($_.Name), from: $envValue"
         Write-Verbose "    to: $($_.Value)"
         Write-Verbose ''
      } else {
         return $false
      }
      return $true
   } |
   Set-Content -Path { "Env:$($_.Name)" }
   
   Write-Verbose 'environment variables updated!'
}
