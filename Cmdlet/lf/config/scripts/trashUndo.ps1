# note: $recycleBin = $shell.Namespace(0x0F), 0xf namespace is not available.
function parseDate {
    param ([string]$dateString)

    # Remove any non-ASCII characters
    $cleanDateString = $dateString -replace '[^\x00-\x7F]', ''

    # Remove any leading/trailing whitespace
    $cleanDateString = $cleanDateString.Trim()

    # Try to parse the cleaned date string
    try {
        return [DateTime]::ParseExact($cleanDateString, "M/d/yyyy h:mm tt", [Globalization.CultureInfo]::InvariantCulture)
    }
    catch {
        Show-MessageBox "Unable to parse date: $dateString"
        return $null
    }
}
<#
recover the last time deleted items from recycle bin and make sure the item is deleted from current folder
#>
function trashUndo {
    $shell = $null
    $recycleBin = $null
    try {
        # when the folder is empth there is no active selection, so we use $env:PWD
        #split-path ($env:f).trim('"') -Parent #"c:\users\jsong12\downloads" #
        $folderPath = ($env:PWD).trim('"')
        # Show-MessageBox $folderPath
        # Create Shell.Application object
        $shell = New-Object -ComObject Shell.Application
        $recycleBin = $shell.Namespace(10)  # 10 is the value for the Recycle Bin

        # Get items in the Recycle Bin
        $items = @() + $recycleBin.Items()

        if ($items.Count -eq 0) {
            Show-MessageBox "The Recycle Bin is empty."
            return
        }

        foreach ($item in $items) {
            $deleteDate = $recycleBin.GetDetailsOf($item, 2)  # 2 is the index for Date Deleted
            Add-Member -InputObject $item -NotePropertyName DeleteDate -NotePropertyValue (parseDate $deleteDate)
            $originalLocation = $recycleBin.GetDetailsOf($item, 1)
            Add-Member -InputObject $item -NotePropertyName OriginalLocation -NotePropertyValue  $originalLocation
            Add-Member -InputObject $item -NotePropertyName OriginalPath -NotePropertyValue (Join-Path $originalLocation $item.Name)
        }

        $items = $items |? {
            $origianlFolderPath = (Resolve-Path $_.OriginalLocation).Path
            $currentFolderPath = (resolve-path $folderPath).Path
            return $origianlFolderPath -eq $currentFolderPath
        }
        if($items.count -eq 0) {
            return
        }

        # Find the most recently deleted item
        $lastDeletedTime = ($items | Sort-Object DeleteDate -Descending | Select-Object -First 1).DeleteDate
        $validItems | Where-Object { $_.DeleteDate -eq $lastDeletedTime }
        $lastDeletedItems = $items | Where-Object { $_.DeleteDate -eq $lastDeletedTime }

        # Display info about the item to be restored
        $lastDeletedItems | Format-Table  Name, DeleteDate

        $lastDeletedItems | % {
            Move-Item $_.Path $_.OriginalPath
        }
        Show-MessageBox "Item restored successfully."
    }
    catch {
        Show-MessageBox "An error occurred: $_"

        throw
    }
    finally {
        # Release COM objects
        if ($recycleBin) {
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($recycleBin) | Out-Null
        }
        if ($shell) {
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
        }
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
    }
}

trashUndo