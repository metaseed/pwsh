# Begin of ProxyCommand for command: write-error
Function write-error {
  <#
.SYNOPSIS
  Write-Error [-Message] <string> [-Category <ErrorCategory>] [-ErrorId <string>] [-TargetObject <Object>] [-RecommendedAction <string>] [-CategoryActivity <string>] [-CategoryReason <string>] [-CategoryTargetName <string>] [-CategoryTargetType <string>] [<CommonParameters>]
  
  Write-Error [-Exception] <Exception> [-Message <string>] [-Category <ErrorCategory>] [-ErrorId <string>] [-TargetObject <Object>] [-RecommendedAction <string>] [-CategoryActivity <string>] [-CategoryReason <string>] [-CategoryTargetName <string>] [-CategoryTargetType <string>] [<CommonParameters>]
  
  Write-Error [-ErrorRecord] <ErrorRecord> [-RecommendedAction <string>] [-CategoryActivity <string>] [-CategoryReason <string>] [-CategoryTargetName <string>] [-CategoryTargetType <string>] [<CommonParameters>]
  
#>


  [CmdletBinding(DefaultParameterSetName = 'NoException', HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=2097039', RemotingCapability = 'None')]
  param(
    [Parameter(ParameterSetName = 'WithException', Mandatory = $true, Position = 0)]
    [System.Exception]
    ${Exception},
   
    [Parameter(ParameterSetName = 'NoException', Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [Parameter(ParameterSetName = 'WithException')]
    [Alias('Msg')]
    [AllowNull()]
    [AllowEmptyString()]
    [string]
    ${Message},
   
    [Parameter(ParameterSetName = 'ErrorRecord', Mandatory = $true, Position = 0)]
    [System.Management.Automation.ErrorRecord]
    ${ErrorRecord},
   
    [Parameter(ParameterSetName = 'NoException')]
    [Parameter(ParameterSetName = 'WithException')]
    [System.Management.Automation.ErrorCategory]
    ${Category},
   
    [Parameter(ParameterSetName = 'NoException')]
    [Parameter(ParameterSetName = 'WithException')]
    [string]
    ${ErrorId},
   
    [Parameter(ParameterSetName = 'NoException')]
    [Parameter(ParameterSetName = 'WithException')]
    [System.Object]
    ${TargetObject},
   
    [string]
    ${RecommendedAction},
   
    [Alias('Activity')]
    [string]
    ${CategoryActivity},
   
    [Alias('Reason')]
    [string]
    ${CategoryReason},
   
    [Alias('TargetName')]
    [string]
    ${CategoryTargetName},
   
    [Alias('TargetType')]
    [string]
    ${CategoryTargetType})
   
  begin {
    try {
      $outBuffer = $null
      if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
        $PSBoundParameters['OutBuffer'] = 1
      }
   
      $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Error', [System.Management.Automation.CommandTypes]::Cmdlet)
      $scriptCmd = { & $wrappedCmd @PSBoundParameters }
      $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
      $steppablePipeline.Begin($PSCmdlet)
    }
    catch {
      throw
    }
  }
   
  process {
    try {
      $steppablePipeline.Process($_)
      WriteError $PSBoundParameters
    }
    catch {
      throw
    }
  }
   
  end {
    try {
      $steppablePipeline.End()
    }
    catch {
      throw
    }
  }
   
   

} # End ProxyFunction for command: write-error

