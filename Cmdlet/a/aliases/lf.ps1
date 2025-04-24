# delegation script to invoke the lf
# so just invoke the lf.ps1 with 'lf' not 'a lf'
[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline = $true)]
    [ArgumentCompleter({
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )

            $CompletionResults = (Get-ZLocation).GetEnumerator() | Sort-Object { $_.Value } -Descending |
            % {
                $pathValue = $_.Key
                if ($pathValue.Contains(' ')) {
                    $pathValue = "`"$pathValue`""
                }
                return $pathValue
            } | Invoke-Fzf -NoSort -Filter $WordToComplete

            return $CompletionResults
        })]
    [object]$Path,

    [Parameter(DontShow, ValueFromRemainingArguments)]
    $Remaining
)


end {
    # work with path contains space
    while(($Remaining.Count -gt 0) -and !$Remaining[0].StartsWith('-')) {
        $Path += " $($Remaining[0])" # if the path is separated by more than one space, not work
        $Remaining.removeAt(0)
    }
    # After all pipeline items are processed
    # Call the original command with both pipeline items and remaining arguments
    if ($path) {
        if (Test-Path $Path) {
            $Path = Resolve-Path $Path
            # Write-Host $pipelineItems
            # Write-Host $Remaining
            a lf -- $Path @Remaining
        }
        else {
            $parentPath = $Path
            do {
                $parentPath = Split-Path $parentPath
                # write-host $parentPath
            } while ($parentPath -and -not (Test-Path $parentPath))

            if ($parentPath) {
                Write-Notice "only this part of path available: $parentPath"
                $decision = $Host.UI.PromptForChoice('Continue with partial path?', "$parentPath", @('&Yes', '&No'), 0)
                if($decision -eq 0) {
                    a lf -- $parentPath @Remaining
                }
            }
            # throw "path does not exist: $Path"
        }
    }
    else {
        # when from chord
        a lf -- @Remaining
    }
}
# work too:
# & "$PSScriptRoot\..\a\_handlers\lf.ps1" "$env:ms_app\lf.exe" @Remaining`