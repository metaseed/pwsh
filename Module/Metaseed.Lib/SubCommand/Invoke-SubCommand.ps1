function Invoke-SubCommand {
    # Use the CmdletBinding attribute to create an advanced function. This is a prerequisite to use the automatic $PSCmdlet variable, which we need in the body.
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Command,
        [object]$cacheName,
        [string]$filter = '*.ps1'
    )

    dynamicparam {
        $cmd = Find-FromParent 'Command' $MyInvocation.PSScriptRoot
        $__CmdFolder ??= $PSCmdlet.SessionState.PSVariable.Get('__CmdFolder').Value
        $CommandFolder = $__CmdFolder ?? "$cmd"
        if (!$CommandFolder) { return }
        $Command = $PSBoundParameters['Command']
        $cacheName ??= $PSCmdlet.SessionState.PSVariable.Get('__CmdCache').Value
        return Get-DynCmdParam $cacheName $CommandFolder $Command $filter
    }

    end {
        # https://stackoverflow.com/questions/72378920/access-a-variable-from-parent-scope
        # get or set a variable from the parent (module) scope.
        $__CmdFolder ??= $PSCmdlet.SessionState.PSVariable.Get('__CmdFolder').Value
        $__LibFolder ??= $PSCmdlet.SessionState.PSVariable.Get('__LibFolder').Value
        $__RootFolder ??= $PSCmdlet.SessionState.PSVariable.Get('__RootFolder').Value
        $cacheName ??= $PSCmdlet.SessionState.PSVariable.Get('__CmdCache').Value

        $path = $MyInvocation.PSScriptRoot
        Write-Verbose "path: $path"
        $cmd = Find-FromParent 'Command'
        $CommandFolder = $__CmdFolder ?? "$cmd"
        if (!$CommandFolder) { write-error "can not get the 'Command' folder" }
        Write-Verbose $CommandFolder
        $file = Find-CmdItem $cacheName $CommandFolder $Command $filter

        Write-Verbose $file
        $null = $PSBoundParameters.Remove('Command')
        Write-Verbose $PSBoundParameters
        & $file @PSBoundParameters
    }
}