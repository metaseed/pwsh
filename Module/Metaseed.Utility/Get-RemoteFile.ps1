function Get-RemoteFile {
  [CmdletBinding()]
  param (
    $Address,
    $localFolder = $env:TEMP
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    $File = Split-Path $address -Leaf
    $Exe = "$localFolder\$File"
    Invoke-WebRequest $Address -OutFile $Exe
    return $Exe
}