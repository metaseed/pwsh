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
        # - not work: Get-VariableOutModule 'filter' -valueonly #Get-Variable -Name 'filter' -ValueOnly #$PSBoundParameters['filter']
        # not work: $cacheName ??= Get-VariableOutModule '__CmdCache' -ValueOnly
        # can not use: Get-DynCmdParam $cacheName $CommandFolder $Command $filter
        # so we use $env here to get cachename and cmdfolder

        $cmd = Find-FromParent 'Command' $MyInvocation.PSScriptRoot
        $__CmdFolder ??= $env:__CmdFolder # Get-VariableOutModule '__CmdFolder' -ValueOnly
        $CommandFolder = $__CmdFolder ?? "$cmd"
        if (!$CommandFolder) { return }
        $Command = $PSBoundParameters['Command']
        $cacheName ??=  $env:__CmdCache# Get-VariableOutModule '__CmdCache' -ValueOnly
        $filter = $PSBoundParameters['filter'] ?? '*.ps1'
        # write-host "filter:$filter , command: $Command , cacheName: $cacheName , CmdFolder: $__CmdFolder"
        return Get-DynCmdParam $cacheName $CommandFolder $Command $filter
    }

    end {
        # https://stackoverflow.com/questions/72378920/access-a-variable-from-parent-scope
        # get or set a variable from the parent (module) scope.
        $__CmdFolder ??= Get-VariableOutModule '__CmdFolder' -ValueOnly
        # $__LibFolder ??= Get-VariableOutModule '__LibFolder' -ValueOnly
        # $__RootFolder ??= Get-VariableOutModule '__RootFolder' -ValueOnly
        $cacheName ??= Get-VariableOutModule '__CmdCache' -ValueOnly

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