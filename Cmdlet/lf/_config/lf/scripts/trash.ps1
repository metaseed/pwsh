$items = $env:fx -split ',' # "`n"

#  $f is current focused file, $fs is selected files, $fx is $fs if select many else it is $f
$items | % {
  $item = get-item $_.trim('"')
  $directoryPath = Split-Path $item -Parent

  $shellCom = New-Object -ComObject "Shell.Application"
  $shellFolder = $shellCom.Namespace($directoryPath) # goto the folder
  $shellItem = $shellFolder.ParseName($item.Name)

  $result = $shellItem.InvokeVerb("delete") # $result is empty
  # Show-MessageBox "sss $result"
  # $shellItem.InvokeVerb("delete", "shift") # to permanently delete
}
