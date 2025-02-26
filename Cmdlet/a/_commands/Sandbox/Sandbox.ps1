# https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-configure-using-wsb-file
# https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-architecture
[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $config
)
# or run 'OptionalFeatures.exe' to enable the 'Sandbox' feature
$OptionalFeature = "Containers-DisposableClientVM"
if((Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature).State -ne 'Enabled') {
  Enable-WindowsOptionalFeature -FeatureName $OptionalFeature -All -Online
}

#note: on my win11 vm, the c:\app can not be mapped, because of it's a link, and it's source is a network folder
$hasMappedFolder = (test-path c:\app) -and (test-path c:\temp)

if($config ) {
  if(!$hasMappedFolder) {
    write-error "the folders: c:\app and c:\temp in config is not find on host machine"
    return
  }
  # note: double click the .wsb file or invoke from command line will launch the sandbox
  WindowsSandbox.exe "$PSScriptRoot\sandbox.wsb"
} else {
  WindowsSandbox.exe
}

