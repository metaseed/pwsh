
function Parse-RecycleBinDate {
    param ([string]$dateString)

    # Remove any non-ASCII characters
    $cleanDateString = $dateString -replace '[^\x00-\x7F]', ''

    # Remove any leading/trailing whitespace
    $cleanDateString = $cleanDateString.Trim()

    # Try to parse the cleaned date string
    try {
        return [DateTime]::ParseExact($cleanDateString, "M/d/yyyy h:mm tt", [System.Globalization.CultureInfo]::InvariantCulture)
    }
    catch {
        Write-Warning "Unable to parse date: $dateString"
        return $null
    }
}

function Get-RecycledItem {
    [CmdletBinding(DefaultParameterSetName = 'OriginalPath')]
    param(
        [Parameter(Position = 0, ValueFromPipeline, ParameterSetName = 'OriginalPath')]
        [String]
        $OriginalPath,

        [Parameter(Position = 1, ParameterSetName = 'OriginalPathRegex')]
        [String]
        $OriginalPathRegex,

        [Parameter(Position = 2)]
        [ValidateSet('Application', 'GetFolder', 'GetLink', 'IsBrowsable', 'IsFileSystem', 'IsFolder', 'IsLink', 'ModifyDate', 'Name', 'Parent', 'Path', 'Size', 'Type')]
        [Alias('Criteria', 'Property')]
        [String]
        $SortingCriteria = 'ModifyDate',

        [Parameter(Position = 3)]
        [Alias('Desc')]
        [Switch]
        $Descending,

        [Parameter(Position = 4)]
        [ValidateScript({ $_ -gt 0 })]
        [Int16]
        $Top,

        [Parameter(Position = 1)]
        [Alias('Selector', 'Script', 'Lambda', 'Filter')]
        [ValidateNotNull()]
        [ScriptBlock]
        $SelectorScript
    )

    process {
        $shell = New-Object -ComObject Shell.Application
        $recycleBin = $shell.Namespace(10)
        $SelectedItems = @() + $recycleBin.Items()

        foreach ($item in $SelectedItems) {
            $deleteDate = $recycleBin.GetDetailsOf($item, 2)  # 2 is the index for Date Deleted
            # Add-Member -InputObject $item -NotePropertyName DeleteDate -NotePropertyValue $deleteDate
            Add-Member -InputObject $item -NotePropertyName DeleteDate -NotePropertyValue (Parse-RecycleBinDate $deleteDate)
            $originalLocation = $recycleBin.GetDetailsOf($item, 1)
            Add-Member -InputObject $item -NotePropertyName OriginalLocation -NotePropertyValue  $originalLocation
            Add-Member -InputObject $item -NotePropertyName OriginalPath -NotePropertyValue (Join-Path $originalLocation $item.Name)
        }

        if ($OriginalPath) {
            $SelectedItems = $SelectedItems | Where-Object { $_.OriginalPath -eq $OriginalPath }
        }

        if ($OriginalPathRegex) {
            $SelectedItems = $SelectedItems | Where-Object { $_.OriginalPath -match $OriginalPathRegex }
        }

        if ($SelectorScript) {
            $SelectedItems = $SelectedItems | Where-Object { Invoke-Command $SelectorScript -ArgumentList $_ }
        }

        if ($SortingCriteria) {
            $SelectedItems = $SelectedItems | Sort-Object $SortingCriteria -Descending:$Descending
        }

        if ($Top) {
            $SelectedItems = $SelectedItems | Select-Object -First $Top
        }

        return $SelectedItems
        # return 1
    }
    <#
.SYNOPSIS
    Get all items from the recycle bin, optionally filtered by the parameters
.DESCRIPTION
    Get all items from the recycle bin, optionally filtered by the parameters
.PARAMETER OriginalPath
    Filters recycle bin items by their original path
.PARAMETER OriginalPathRegex
    Filters recycle bin items by their original path with a regex
.PARAMETER SortingCriteria
    Sort output by the specified criteria
.PARAMETER Descending
    Sort output descending instead of ascending
.PARAMETER Top
    Only get top n results
.PARAMETER SelectorScript
    Custom script to filter the results
.INPUTS
    System.String The OriginalPath to search for
.OUTPUTS
    System.__ComObject The recycle bin items
.EXAMPLE
    Get-RecycledItem -OriginalPath "C:\Users\jsong12\Testfile"
.EXAMPLE
    Get-RecycledItem -SortingCriteria "Size" -Descending -Top 5
.EXAMPLE
    Get-RecycledItem -SelectorScript { $_.IsFolder -eq $true }
.EXAMPLE
    Get-RecycledItem -OriginalPathRegex "C:\\Users\\jsong12\\Downloads.*"
.EXAMPLE
    Get-RecycledItem -OriginalPath C:\Users\jsong12\Downloads\facture-song-xinzhi-20240613-1421.pdf|Restore-RecycledItem
#>
}

# Get-RecycledItem


function get-PathFromComObj {
    [CmdletBinding()]
    param (
        [Parameter()]
        [object]
        $ComObject
    )

    if ($ComObject.IsFolder -or (($ComObject.type -match 'Zip') -and ($ComObject.Path -notmatch '.7z$'))) {
        $OriginalPath = $ComObject.GetFolder.Title
        if (!$OriginalPath) {
            $global:t = $ComObject
        }
    }
    else {
        #sometimes the original location is stored in an extended property
        $data = $ComObject.ExtendedProperty("infotip").split("`n") | Where-Object { $_ -match "Original location" }
        if ($data) {
            $origPath = $data.split(":", 2)[1].trim()
            $OriginalPath = Join-Path -path $origPath -ChildPath $ComObject.name -ErrorAction stop
            Remove-Variable -Name data
        }
        else {
            #no extended property so use this code to attemp to rebuild the original location
            if ($ComObject.parent.title -match "^[C-Zc-z]:\\") {
                $origPath = $ComObject.parent.title
            }
            elseif ($fldpath) {
                $origPath = $fldPath
            }
            else {
                $test = $ComObject.parent
                Write-Verbose "searching for parent on $($test.self.path)"
                do { $test = $test.parentfolder; $save = $test.title } until ($test.title -match "^[C-Zc-z]:\\" -OR $test.title -eq $save)
                $origPath = $test.title
            }

            $OriginalPath = Join-Path -path $origPath -ChildPath $ComObject.name -ErrorAction stop
        }

    }
    return $OriginalPath
}
# Get-RecycledItem