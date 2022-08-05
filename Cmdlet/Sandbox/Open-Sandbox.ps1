# https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-configure-using-wsb-file

$OptionalFeature = "Containers-DisposableClientVM"
if(!(Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature)) {
  Enable-WindowsOptionalFeature -FeatureName $OptionalFeature -All -Online
}

WindowsSandbox.exe "$PSScriptRoot\sandbox.wsb"