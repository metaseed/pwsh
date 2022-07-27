function Invoke-SubCommand {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $SubCommand
    )
    $cmd = Find-FromParent 'Command' $MyInvocation.PSScriptRoot
    $CommandFolder = $__CmdFolder ?? "$cmd"

    $file = Get-AllPwshFiles $CommandFolder | ? { $_.BaseName -eq $Command }

    $null = $PSBoundParameters.Remove('Command')
    & $file @PSBoundParameters
}