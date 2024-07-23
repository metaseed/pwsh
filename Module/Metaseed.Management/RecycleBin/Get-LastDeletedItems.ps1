function Get-LastDeletedItems {
    $validItems = Get-RecycledItem
    $lastDeletedTime = ($validItems | Sort-Object DeleteDate -Descending | Select-Object -First 1).DeleteDate
    $validItems | Where-Object { $_.DeleteDate -eq $lastDeletedTime }
}

# Get-LastDeletedItems