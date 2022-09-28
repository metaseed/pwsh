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

    # used to pass in addtional parameter for subcommand, otherwise error: can not find paramter for the subcmd
    dynamicparam {
        # no way to access the $filter and other parameter, that is not set explictly in dynamicparam, we can accept $PSBoundParameters['Command']
        # - not work: #$PSBoundParameters['filter']
        # so also can use $env here to share cachename and cmdfolder in the process


        $__CmdFolder ??= $PSCmdlet.SessionState.PSVariable.GetValue('__CmdFolder') # $env:__CmdFolder
        if (!$__CmdFolder) {
            $__CmdFolder = Find-FromParent '_Commands' $MyInvocation.PSScriptRoot
        }

        $CommandFolder = $__CmdFolder


        if (!$CommandFolder) {
            write-error "can not find command folder in dynamicparam block of invoke-subcommand"
            return
        }
        $Command = $PSBoundParameters['Command']
        $cacheName ??= $PSCmdlet.SessionState.PSVariable.GetValue('__CmdCache')

        $filter = $PSBoundParameters['filter'] ?? '*.ps1'
        write-host "filter:$filter , command: $Command , cacheName: $cacheName , CmdFolder: $__CmdFolder"
        return Get-DynCmdParam $cacheName $CommandFolder $Command $filter
    }

    end {
        # https://stackoverflow.com/questions/72378920/access-a-variable-from-parent-scope
        # get or set a variable from the parent (module) scope.
        $__CmdFolder ??= $PSCmdlet.SessionState.PSVariable.GetValue('__CmdFolder')
        # __LibFolder is not used here but maybe used in the subcommand
        $__LibFolder ??= $PSCmdlet.SessionState.PSVariable.GetValue( '__LibFolder')
        $__RootFolder ??= $PSCmdlet.SessionState.PSVariable.GetValue( '__RootFolder')
        $cacheName ??= $PSCmdlet.SessionState.PSVariable.GetValue( '__CmdCache')
        write-host "runtime: filter:$filter , command: $Command , cacheName: $cacheName , CmdFolder: $__CmdFolder, libfolder: $__LibFolder"

        $path = $MyInvocation.PSScriptRoot
        Write-Verbose "path: $path"
        if (!$__CmdFolder) {
            $__CmdFolder = Find-FromParent '_Commands' $path
        }
        $CommandFolder = $__CmdFolder

        if (!$CommandFolder) { write-error "can not get the '_Commands' folder" }
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