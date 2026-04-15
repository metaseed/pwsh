<#
why better than `code -h|code -`?
1. give a name with extension, alow formate the doc and syntax highlight, also easy to find in temp dir
#>
function Out-Code {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline = $true)]
        $InputObject,

        [Parameter(Position = 0)]
        [string]$FileName = "code_$(Get-Date -Format 'HHmmss').log"
    )
    begin {
        $TempFile = Join-Path $env:TEMP $FileName
        $lines = [System.Collections.Generic.List[object]]::new()
    }
    process {
        $lines.Add($InputObject)
    }
    end {
        $lines | Out-File -FilePath $TempFile
        code $TempFile
    }
}


# code -h|out-code a.txt

