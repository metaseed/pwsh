# update process env: from machine env and user env
# if: it's path and contains ';' => all value from Machine and User would appended and uniqued.
# else => value override from Manchine and then from User(if has same key name)
function Update-Env { 
   @("Machine", "User") | 
   % { [Environment]::GetEnvironmentVariables($_).GetEnumerator() } |
   % {
      # For Path variables, append the new values, if they're not already in there
      $envValue = Get-Content "Env:$($_.Name)"
      if ($_.Name -match 'Path$' -and ($_.Value.Contains(';') -or $envValue.Contains(';'))) { 
         $_.Value = ("$envValue;$($_.Value)" -split ';' | Select-Object -unique) -join ';'
      }
      $_
   } |
   Set-Content -Path { "Env:$($_.Name)" }
   
   Write-Verbose 'environment variables updated!'
}