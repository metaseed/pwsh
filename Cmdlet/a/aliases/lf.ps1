# delegation script to invoke the lf
# so just invoke the lf.ps1 with 'lf' not 'a lf'
[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline=$true)]
    [ArgumentCompleter({
      param(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [System.Collections.IDictionary] $FakeBoundParameters
      )

      $CompletionResults = (Get-ZLocation).GetEnumerator() | Sort-Object { $_.Value } -Descending | ForEach-Object { $_.Key }| Invoke-Fzf -NoSort -Filter $WordToComplete

      return $CompletionResults
    })]
    [object]$InputObject,

    [Parameter(DontShow, ValueFromRemainingArguments)]
    $Remaining
)

begin {
    # Initialize an array to collect pipeline input if needed
    $pipelineItems = @()
}

process {
    # This block processes each item coming through the pipeline
    if ($InputObject) {
        $pipelineItems += $InputObject
    }
}

end {
    # After all pipeline items are processed
    # Call the original command with both pipeline items and remaining arguments
    if ($pipelineItems.Count -gt 0) {
        a lf -- $pipelineItems @Remaining
    } else {
        a lf -- @Remaining
    }
}
# work too:
# & "$PSScriptRoot\..\a\_handlers\lf.ps1" "$env:ms_app\lf.exe" @Remaining`