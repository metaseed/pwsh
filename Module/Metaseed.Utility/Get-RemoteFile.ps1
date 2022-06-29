function Get-RemoteFile {
  [CmdletBinding()]
  param (
    $Address
    )
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    $File = Split-Path $address -Leaf
    if($Local) { $Address = "$LocalFolder/$File" }
    $Exe = "$env:TEMP\$File"
    Invoke-WebRequest $Address -OutFile $Exe
    return $Exe
}