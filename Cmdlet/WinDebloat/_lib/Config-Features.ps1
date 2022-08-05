[CmdletBinding()]
param (
  [Parameter()]
  [bool]
  $vm
)

if ($vm) {
  $DisableFeatures = @(
    "FaxServicesClientPackage"             # Windows Fax and Scan
    "MediaPlayback"                        # Media Features (Windows Media Player)
    "Printing-PrintToPDFServices-Features" # Microsoft Print to PDF
    # a business / enterprise feature that allows you to access work related files while offline and on any device associated with you.
    "WorkFolders-Client"                   # Work Folders Client
  )

  $EnableFeatures = @(
    # "IIS-*"                                # Internet Information Services
  )

  Set-OptionalFeatureState -Disabled -OptionalFeatures $DisableFeatures
  Set-OptionalFeatureState -Enabled -OptionalFeatures $EnableFeatures
}
else {
  # Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online -NoRestart

  $DisableFeatures = @(
  )

  $EnableFeatures = @(
    "Containers-DisposableClientVM"
  )
  Set-OptionalFeatureState -Disabled -OptionalFeatures $DisableFeatures
  Set-OptionalFeatureState -Enabled -OptionalFeatures $EnableFeatures
}

$DisableFeatures = @(
  "FaxServicesClientPackage"             # Windows Fax and Scan
  "Internet-Explorer-Optional-*"         # Internet Explorer
  "LegacyComponents"                     # Legacy Components
  "MediaPlayback"                        # Media Features (Windows Media Player)
  "MicrosoftWindowsPowerShellV2"         # PowerShell 2.0
  "MicrosoftWindowsPowershellV2Root"     # PowerShell 2.0
  "Printing-XPSServices-Features"        # Microsoft XPS Document Writer
)

$EnableFeatures = @(
  "NetFx3"                            # NET Framework 3.5
  "NetFx4-AdvSrvs"                    # NET Framework 4
  "NetFx4Extended-ASPNET45"           # NET Framework 4.x + ASPNET 4.x
)

Set-OptionalFeatureState -Disabled -OptionalFeatures $DisableFeatures
Set-OptionalFeatureState -Enabled -OptionalFeatures $EnableFeatures
