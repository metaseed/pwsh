# https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-configure-using-wsb-file
[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $config
)

$OptionalFeature = "Containers-DisposableClientVM"
if(!(Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature)) {
  Enable-WindowsOptionalFeature -FeatureName $OptionalFeature -All -Online
}

#note: on my win11 vm, the c:\app can not be mapped, because of it's a link, and it's source is a network folder

if($config) {
  WindowsSandbox.exe "$PSScriptRoot\sandbox.wsb"
} else {
  WindowsSandbox.exe
}

