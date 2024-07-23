# note: $recycleBin = $shell.Namespace(0x0F), 0xf namespace is not available.
function Restore-LastDeletedItem {
  $shell = $null
  $recycleBin = $null

  try {
      # Create Shell.Application object
      $shell = New-Object -ComObject Shell.Application
      $recycleBin = $shell.Namespace(10)  # 10 is the value for the Recycle Bin

      # Get items in the Recycle Bin
      $items = $recycleBin.Items()

      if ($items.Count -eq 0) {
          Write-Host "The Recycle Bin is empty."
          return
      }

      # Find the most recently deleted item
      $lastDeletedItem = $items | Sort-Object ModifyDate -Descending | Select-Object -First 1

      # Display info about the item to be restored
      Write-Host "Restoring the most recently deleted item:"
      Write-Host "Name: $($lastDeletedItem.Name)"
      Write-Host "Deleted on: $($lastDeletedItem.ModifyDate)"

      $originalPath = ($recycleBin.GetDetailsOf($lastDeletedItem, 1))
      # Restore the item
      $lastDeletedItem.InvokeVerb("Restore")

      Write-Host "Item restored successfully."
  }
  catch {
      Write-Error "An error occurred: $_"
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

Restore-LastDeletedItem