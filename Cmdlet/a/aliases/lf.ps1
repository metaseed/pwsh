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
                if($pathValue.Contains(' ')){
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
    # After all pipeline items are processed
    # Call the original command with both pipeline items and remaining arguments
    if ($path -and (Test-Path $Path)) {
        $Path = Resolve-Path $Path
        # Write-Host $pipelineItems
        # Write-Host $Remaining
        a lf -- $Path @Remaining
    }
    else { # when from chord
        a lf -- @Remaining
    }
}
# work too:
# & "$PSScriptRoot\..\a\_handlers\lf.ps1" "$env:ms_app\lf.exe" @Remaining`