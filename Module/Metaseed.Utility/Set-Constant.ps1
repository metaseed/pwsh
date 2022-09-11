# https://stackoverflow.com/questions/2608215/does-powershell-support-constants/54314996#54314996
function Set-Constant {
  <#
  .SYNOPSIS
      Creates constants.
  .DESCRIPTION
      This function can help you to create constants so easy as it possible.
      It works as keyword 'const' as such as in C#.
  .EXAMPLE
      PS C:\> Set-Constant a = 10
      PS C:\> $a += 13

      There is a integer constant declaration, so the second line return
      error.
  .EXAMPLE
      PS C:\> const str = "this is a constant string"

      You also can use word 'const' for constant declaration. There is a
      string constant named '$str' in this example.
  .LINK
      Set-Variable
      About_Functions_Advanced_Parameters
  #>
  [CmdletBinding()]
  [alias('const')]
  param(
    [Parameter(Mandatory = $true, Position = 0)] [string] $Name,
    [Parameter(Mandatory = $true, Position = 1)] [char] [ValidateSet("=")] $Link,
    [Parameter(Mandatory = $true, Position = 2)] [object] $Value
  )

  if ((Get-PSCallStack)[1].Command -eq 'Metaseed.Utility.psm1') {
    # called from the Utility module
    Set-Variable -n $Name -val $Value -option Constant
  }
  else {
    $var = New-Object System.Management.Automation.PSVariable -ArgumentList @(
      $Name, $Value, [System.Management.Automation.ScopedItemOptions]::Constant
    )
    # need CmdletBinding on param, to access $PSCmdlet
    $PSCmdlet.SessionState.PSVariable.Set( $var )
    # $PSCmdlet.SessionState.PSVariable.GetValue($Name)
  }

}

# Set-Alias const Set-Constant