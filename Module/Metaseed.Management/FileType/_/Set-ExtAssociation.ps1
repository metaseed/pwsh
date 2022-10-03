Function Set-ExtAssociation($ext, $exe) {
  $name = cmd /c "assoc $ext 2>NUL"
  if ($name) {
    Write-Host "Association of $ext already exists: override it"
    $name = $name.Split('=')[1]
  }
  else {
    Write-Host "create association for ext: $ext"
    $name = "$($ext.Replace('.',''))file" # ".log.1" becomes "log1file"
    cmd /c "assoc $ext=$name"
  }
  cmd /c "ftype $name=`"$exe`" `"%1`" `"%*`""
}

function Get-ExtAssociation($ext) {
  $name = cmd /c "assoc $ext 2>NUL"
  if(!$name) {
    write-host "no association with $ext"
    return
  }
  return cmd /c "ftype $name"
}

Export-ModuleMember Get-ExtAssociation
# note: notwork