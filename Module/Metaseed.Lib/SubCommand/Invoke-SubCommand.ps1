function Invoke-SubCommand {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Command
    )

    dynamicparam {
        $cmd = Find-FromParent 'Command' $MyInvocation.PSScriptRoot
        $__CmdFolder ??= $PSCmdlet.SessionState.PSVariable.Get('__CmdFolder').Value
        $CommandFolder = $__CmdFolder ?? "$cmd"
        if (!$CommandFolder) { return }
        $Command = $PSBoundParameters['Command']
        return Get-DynCmdParam $CommandFolder $Command
    }

    end {
        # https://stackoverflow.com/questions/72378920/access-a-variable-from-parent-scope
        $__CmdFolder ??= $PSCmdlet.SessionState.PSVariable.Get('__CmdFolder').Value
        $__LibFolder ??= $PSCmdlet.SessionState.PSVariable.Get('__LibFolder').Value
        $__RootFolder ??= $PSCmdlet.SessionState.PSVariable.Get('__RootFolder').Value

        $path = $MyInvocation.PSScriptRoot
        Write-Verbose "path: $path"
        $cmd = Find-FromParent 'Command'
        $CommandFolder = $__CmdFolder ?? "$cmd"
        if (!$CommandFolder) { write-error "can not get the 'Command' folder" }
        Write-Verbose $CommandFolder
        $file = Get-AllPwshFiles $CommandFolder | ? { $_.BaseName -eq $Command }

        Write-Verbose $file
        $null = $PSBoundParameters.Remove('Command')
        Write-Verbose $PSBoundParameters
        & $file @PSBoundParameters
    }
}