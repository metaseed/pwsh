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
        $__CmdFolder ??= Get-VariableOutModule '__CmdFolder'
        $CommandFolder = $__CmdFolder ?? "$cmd"
        if (!$CommandFolder) { return }
        $Command = $PSBoundParameters['Command']
        $cacheName ??= Get-VariableOutModule '__CmdCache'
        return Get-DynCmdParam $cacheName $CommandFolder $Command $filter
    }

    end {
        # https://stackoverflow.com/questions/72378920/access-a-variable-from-parent-scope
        # get or set a variable from the parent (module) scope.
        $__CmdFolder ??= Get-VariableOutModule '__CmdFolder'
        $__LibFolder ??= Get-VariableOutModule '__LibFolder'
        $__RootFolder ??= Get-VariableOutModule '__RootFolder'
        $cacheName ??= Get-VariableOutModule '__CmdCache'

        $path = $MyInvocation.PSScriptRoot
        Write-Verbose "path: $path"
        $cmd = Find-FromParent 'Command' $path
        $CommandFolder = $__CmdFolder ?? "$cmd"
        if (!$CommandFolder) { write-error "can not get the 'Command' folder" }
        Write-Verbose $CommandFolder
        $file = Find-CmdItem $cacheName $CommandFolder $Command $filter

        Write-Verbose $file
        $null = $PSBoundParameters.Remove('Command')
        $null = $PSBoundParameters.Remove('cacheName')
        $null = $PSBoundParameters.Remove('filter')

        Write-Verbose $PSBoundParameters
        & $file @PSBoundParameters
    }
}