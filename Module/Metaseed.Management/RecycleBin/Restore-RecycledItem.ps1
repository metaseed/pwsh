
function Restore-RecycledItem {
    [CmdletBinding(DefaultParameterSetName = 'ManualSelection', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Position = 0, ParameterSetName = 'ComObject', Mandatory, ValueFromPipeline)]
        [System.__ComObject]
        $ComObject,

        [Parameter(Position = 0, ParameterSetName = 'ManualSelection', Mandatory)]
        [Parameter(Position = 0, ParameterSetName = 'Selector', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $OriginalPath,

        [Parameter(Position = 1, ParameterSetName = 'ManualSelection')]
        [ValidateSet('Application', 'GetFolder', 'GetLink', 'IsBrowsable', 'IsFileSystem', 'IsFolder', 'IsLink', 'ModifyDate', 'Name', 'Parent', 'Path', 'Size', 'Type')]
        [Alias('Criteria', 'Property')]
        [String]
        $SortingCriteria = 'ModifyDate',

        [Parameter(Position = 2, ParameterSetName = 'ManuelSelection')]
        [Alias('Desc')]
        [Switch]
        $Descending,

        [Parameter(Position = 1, ParameterSetName = 'Selector')]
        [Alias('Selector', 'Script', 'Lambda', 'Filter')]
        [ValidateNotNull()]
        [ScriptBlock]
        $SelectorScript,

        [Parameter(ParameterSetName = 'ManualSelection')]
        [Parameter(ParameterSetName = 'Selector')]
        [Parameter(ParameterSetName = 'ComObject')]
        [Switch]
        $Overwrite
    )

    process {
        if ($ComObject) {
            $FoundItem = $ComObject
            $shell = New-Object -ComObject Shell.Application
            $recycleBin = $shell.Namespace(10)
            $originalLocation = $recycleBin.GetDetailsOf($ComObject, 1)
            # $OriginalPath = $ComObject.GetFolder.Title
            $OriginalPath = Join-Path $originalLocation $ComObject.Name
        }

        if ((Test-Path $OriginalPath) -and -not $Overwrite) {
            if ((Get-Item $OriginalPath) -is [System.IO.DirectoryInfo]) {
                Write-Error "Directory already exists and -Overwrite is not specified"
            }
            else {
                Write-Error "File already exists and -Overwrite is not specified"
            }
        }
        else {
            if ($PSCmdlet.ParameterSetName -eq "ManualSelection" -or $PSCmdlet.ParameterSetName -eq "Selector") {
                $BoundParametersLessOverwrite = $PSBoundParameters
                if ($BoundParametersLessOverwrite.ContainsKey("Overwrite")) {
                    $BoundParametersLessOverwrite.Remove("Overwrite") | Out-Null
                }
                $FoundItem = Get-RecycledItem @PSBoundParameters -Top 1
            }

            if ($FoundItem) {
                # This does not seem to work, so I am doing it manually
                # Maybe someone can get this to work (although I don't see an advantage over the current method)
                #(New-Object -ComObject "Shell.Application").Namespace($BinItems[0].Path).Self().InvokeVerb("Restore")
                if ($Overwrite -or $PSBoundParameters['Force']) {
                    Remove-ItemSafely $OriginalPath
                }
                Move-Item $FoundItem.Path $OriginalPath
            }
            else {
                Write-Error "No item in recycle bin with the specified path found"
            }
        }

        return Get-Item $OriginalPath -ErrorAction SilentlyContinue
    }



    <#
.SYNOPSIS
    Restores a file from the Recycle Bin.
.DESCRIPTION
    Finds the item(s) in the Recycle Bin with the given path, selects one based on the given selector (default is newest), and restores it to the original location.
.PARAMETER OriginalPath
    The original path to the file to restore.
.PARAMETER Overwrite
    Whether to overwrite the file at the path if it exists.
.PARAMETER SortingCriteria
    How to sort the items to find which to restore.
.PARAMETER Descending
    Whether the SortingCriteria sort should be descending or ascending.
.PARAMETER SelectorScript
    A script block which determines which item to restore.
.INPUTS
    System.__ComObject The result of calling Get-RecycledItem
.OUTPUTS
    System.Object Return the item that was restored.
.EXAMPLE
    Restore-Item "C:\TestFolder\TestFile.txt"
.EXAMPLE
    Restore-Item "C:\TestFolder\TestFile.txt" -SortingCriteria "Size" -Descending
.EXAMPLE
    Restore-Item "C:\TestFolder\TestFile.txt" -SelectorScript { $_.ModifyDate -eq '01.01.1970' }
.NOTES
    Credit for this approach: https://jdhitsolutions.com/blog/powershell/7024/managing-the-recycle-bin-with-powershell/
.NOTES
    Author: Kevin Holtkamp, kevinholtkamp26@gmail.com
    LastEdit: 09.07.2022
#>
}



# Get-LastDeletedItems|Restore-RecycledItem