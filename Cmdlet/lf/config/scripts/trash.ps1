write-host "trash to recycle bin:`n$env:fx"
$items = $env:fx -split "`n"
#  $f is current selected file, $fs is selected files, $fx is $fs if select many else it is $f
$items | % {
  $item = get-item $_.trim('"')
  $directoryPath = Split-Path $item -Parent
  $shellCom = New-Object -ComObject "Shell.Application"
  $shellFolder = $shellCom.Namespace($directoryPath)
  $shellItem = $shellFolder.ParseName($item.Name)
  $shellItem.InvokeVerb("delete")
}