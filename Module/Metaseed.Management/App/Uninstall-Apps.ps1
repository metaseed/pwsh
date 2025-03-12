<#
.SYNOPSIS
uninstall software from windows system

.EXAMPLE
Uninstall-Apps 'InterSystems IRIS instance [IRIS]'

#>
function Uninstall-Apps {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    $name
  )

  begin {

  }

  process {
    $app = Get-ciminstance -Class Win32_Product -Filter "Name = '$name'"
    if($null -ne $app) {
      Write-Information "uninstall $name from system..."
      # $app | Remove-ciminstance -Force #not tested
      Start-Process msiexec.exe -Wait -ArgumentList "/x $($app.IdentifyingNumber) /quiet" # work

      # other way not tested
      # Get-Package -ProviderName Programs -IncludeWindowsInstaller
      # Get-Package -Name "7-zip*" | Uninstall-Package
      Update-ProcessEnvVar
    } else {
      Write-Information "no $name found in system"
    }
  }

  end {

  }
}