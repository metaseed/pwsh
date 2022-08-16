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
if($config) {
  WindowsSandbox.exe "$PSScriptRoot\sandbox.wsb"
} else {
  WindowsSandbox.exe
}

