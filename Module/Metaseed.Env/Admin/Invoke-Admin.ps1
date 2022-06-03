<#
.SYNOPSIS
run script file as admin
.DESCRIPTION
if already admin: return $false - no need to elevate, and continue
if not: run the $file as admin in new pwsh process, and return $true - elevated, and the original script need to return directly
.EXAMPLE
 Invoke-Admin $PSCommandPath $PSBoundParameters
.NOTES
put this at the start of the script
.RETURN
$true - elevated in new pwsh process, and the original script need to return directly
$false - alrady admin, no need to elevate, and orignal script continue
#>
Function Invoke-Admin {
  [CmdletBinding()]
  param(
      $File = $script:PSCommandPath,
      $AllParameters = $script:PSBoundParameters,
      [switch]
      $Wait
  )
  if (Test-Admin) {
      Write-Information 'already admin, continue...'
      return $false;
  }

  Write-Warning "You do not have Administrator rights to run this script!`nRe-run this script as an Administrator!"

  try {
      $AllParameters_String = @();
      ForEach ($Parameter in $AllParameters.GetEnumerator()) {
          $Parameter_Key = $Parameter.Key;
          $Parameter_Value = $Parameter.Value;
          $Parameter_Value_Type = $Parameter_Value.GetType().Name;

          If ($Parameter_Value_Type -Eq "SwitchParameter") {
              $AllParameters_String += "-$Parameter_Key";
          }
          Else {
              $AllParameters_String += "-$Parameter_Key $Parameter_Value";
          }
      }
      $Arguments = "-NoExit", "-File `"$File`"" + $AllParameters_String

      $PSHost = If ($PSVersionTable.PSVersion.Major -le 5) { 'PowerShell' } Else { 'PwSh' }

      Start-Process "$PSHost $($Wait ? '-Wait':'')" -Verb Runas -ArgumentList $Arguments;
      return $true
  }
  catch {
      Add-Type -AssemblyName PresentationFramework
      [System.Windows.MessageBox]::Show("$_")
      return $false
  }
}