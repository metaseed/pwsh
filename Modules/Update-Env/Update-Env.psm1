# update path env: from [Environment]
function Update-Env { 
   @("Machine", "User") | 
   % {[Environment]::GetEnvironmentVariables($_).GetEnumerator()}|
   % {
      # For Path variables, append the new values, if they're not already in there
      if ($_.Name -match 'Path$') { 
         $_.Value = ($((Get-Content "Env:$($_.Name)") + ";$($_.Value)") -split ';' | Select-Object -unique) -join ';'
      }
      $_
   } |
   Set-Content -Path { "Env:$($_.Name)" }
   
   Write-Verbose 'environment variables updated!'
}