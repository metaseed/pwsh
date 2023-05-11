# String: Specifies a null-terminated string. Equivalent to REG_SZ.
# ExpandString: Specifies a null-terminated string that contains unexpanded references to environment variables that are expanded when the value is retrieved. Equivalent to REG_EXPAND_SZ.
# Binary: Specifies binary data in any form. Equivalent to REG_BINARY.
# DWord: Specifies a 32-bit binary number. Equivalent to REG_DWORD.
# MultiString: Specifies an array of null-terminated strings terminated by two null characters. Equivalent to REG_MULTI_SZ.
# Qword: Specifies a 64-bit binary number. Equivalent to REG_QWORD.
# Unknown: Indicates an unsupported registry data type, such as REG_RESOURCE_LIST.
function Set-HKItemProperty {

  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $Path,
    $Name,
    $Value,
    $PropertyType,
    $Descriptoin
  )
  if ($Descriptoin) {
    Write-Host $Descriptoin
  }

  if (!(Test-Path $Path)) {
    New-Item $Path -Force # force: will create container in middle if not exist. i.e. a\b\c\d if b\c is not exist
  }
  if ($Type) {
    Set-ItemProperty $Path -Name $Name -Value $Value -Type $Type
  }
  else {
    Set-ItemProperty $Path -Name $Name -Value $Value
  }

}
function Disable-SchTask {
  [CmdletBinding()]
  param (
    [Parameter(ValueFromPipeline)] # to support pipeline
    $taskName
  )
  process {
    # to process item one by one from pipeline
    $task = Get-ScheduledTask "$taskName" -ErrorAction SilentlyContinue
    if ($null -ne $task) {
      if ('Disabled' -eq $task.State) {
        "Already disabled: TaskName: $($task.TaskName), TaskPath: $($task.TaskPath)"
        return
      }
      Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath
      $taskN = Get-ScheduledTask "$taskName" -ErrorAction SilentlyContinue
      " $($task.State) -> $($taskN.State): TaskName: $($task.TaskName), TaskPath: $($task.TaskPath)"
    }
  }
}

function Find-OptionalFeature() {
  [CmdletBinding()]
  [OutputType([Bool])]
  param (
      [Parameter(Mandatory = $true)]
      [String] $OptionalFeature
  )

  If (Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature) {
      return $true
  } Else {
      Write-Warning "The $OptionalFeature optional feature was not found."
      return $false
  }
}

function Set-OptionalFeatureState() {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $false)]
      [Switch] $Disabled,
      [Parameter(Mandatory = $false)]
      [Switch] $Enabled,
      [Parameter(Mandatory = $true)]
      [Array] $OptionalFeatures,
      [Parameter(Mandatory = $false)]
      [Array] $Filter,
      [Parameter(Mandatory = $false)]
      [ScriptBlock] $CustomMessage
  )

  ForEach ($OptionalFeature in $OptionalFeatures) {
      If (Find-OptionalFeature $OptionalFeature) {

          If ($OptionalFeature -in $Filter) {
              Write-Warning "The $OptionalFeature will be skipped as set on Filter ..."
              Continue
          }

          If (!$CustomMessage) {
              If ($Disabled) {
                  Write-Notice "Uninstalling the $OptionalFeature optional feature ..."
              } ElseIf ($Enabled) {
                  Write-Notice "Installing the $OptionalFeature optional feature ..."
              } Else {
                  Write-Warning "No parameter received (valid params: -Disabled or -Enabled)"
              }
          } Else {
              Write-Notice $(Invoke-Expression "$CustomMessage")
          }

          If ($Disabled) {
              Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature | Where-Object State -Like "Enabled" | Disable-WindowsOptionalFeature -Online -NoRestart
          } ElseIf ($Enabled) {
              Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart
          }
      }
  }
}


function Disable-ActivityHistory() {
  $PathToLMActivityHistory = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"

  Write-Status -Types "-", "Privacy" -Status "Disabling Activity History..."
  Set-ItemProperty -Path $PathToLMActivityHistory -Name "EnableActivityFeed" -Type DWord -Value 0
  Set-ItemProperty -Path $PathToLMActivityHistory -Name "PublishUserActivities" -Type DWord -Value 0
  Set-ItemProperty -Path $PathToLMActivityHistory -Name "UploadUserActivities" -Type DWord -Value 0
}

function Enable-ActivityHistory() {
  $PathToLMActivityHistory = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"

  Write-Status -Types "*", "Privacy" -Status "Enabling Activity History..."
  Set-ItemProperty -Path $PathToLMActivityHistory -Name "EnableActivityFeed" -Type DWord -Value 1
  Set-ItemProperty -Path $PathToLMActivityHistory -Name "PublishUserActivities" -Type DWord -Value 1
  Set-ItemProperty -Path $PathToLMActivityHistory -Name "UploadUserActivities" -Type DWord -Value 1
}

function Disable-BackgroundAppsToogle() {
  Write-Status -Types "-", "Misc" -Status "Disabling Background Apps..."
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BackgroundAppGlobalToggle" -Type DWord -Value 0
}

function Enable-BackgroundAppsToogle() {
  Write-Status -Types "*", "Misc" -Status "Enabling Background Apps..."
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 0
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BackgroundAppGlobalToggle" -Type DWord -Value 1
}

function Disable-ClipboardHistory() {
  Write-Status -Types "-", "Privacy" -Status "Disabling Clipboard History..."
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "AllowClipboardHistory" -Type DWord -Value 0
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Type DWord -Value 0
}

function Enable-ClipboardHistory() {
  Write-Status -Types "*", "Privacy" -Status "Enabling Clipboard History..."
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "AllowClipboardHistory" -Type DWord -Value 1
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Type DWord -Value 1
}

function Disable-Cortana() {
  $PathToLMPoliciesCortana = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"

  Write-Status -Types "-", "Privacy" -Status "Disabling Cortana..."
  Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "AllowCortana" -Type DWord -Value 0
  Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "AllowCloudSearch" -Type DWord -Value 0
  Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0
  Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "DisableWebSearch" -Type DWord -Value 1
}

function Enable-Cortana() {
  $PathToLMPoliciesCortana = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"

  Write-Status -Types "*", "Privacy" -Status "Enabling Cortana..."
  Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "AllowCortana" -Type DWord -Value 1
  Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "AllowCloudSearch" -Type DWord -Value 1
  Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "ConnectedSearchUseWeb" -Type DWord -Value 1
  Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "DisableWebSearch" -Type DWord -Value 0
}

function Disable-DarkTheme() {
  Write-Status -Types "*", "Personal" -Status "Disabling Dark Theme..."
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 1
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 1
}

function Enable-DarkTheme() {
  Write-Status -Types "+", "Personal" -Status "Enabling Dark Theme..."
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 0
}

function Disable-EncryptedDNS() {
  # I'm still not sure how to disable DNS over HTTPS, so this'll need to wait
  # Adapted from: https://stackoverflow.com/questions/64465089/powershell-cmdlet-to-remove-a-statically-configured-dns-addresses-from-a-network
  Write-Status -Types "*" -Status "Resetting DNS server configs..."
  Set-DnsClientServerAddress -InterfaceAlias "Ethernet*" -ResetServerAddresses
  Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi*" -ResetServerAddresses
}

function Enable-EncryptedDNS() {
  # Adapted from: https://techcommunity.microsoft.com/t5/networking-blog/windows-insiders-gain-new-dns-over-https-controls/ba-p/2494644
  Write-Status -Types "+" -Status "Setting up the DNS over HTTPS for Google and Cloudflare (ipv4 and ipv6)..."
  Set-DnsClientDohServerAddress -ServerAddress ("8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844") -AutoUpgrade $true -AllowFallbackToUdp $true
  Set-DnsClientDohServerAddress -ServerAddress ("1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001") -AutoUpgrade $true -AllowFallbackToUdp $true

  Write-Status -Types "+" -Status "Setting up the DNS from Cloudflare and Google (ipv4 and ipv6)..."
  #Get-DnsClientServerAddress # To look up the current config.           # Cloudflare, Google,         Cloudflare,              Google
  Set-DNSClientServerAddress -InterfaceAlias "Ethernet*" -ServerAddresses ("1.1.1.1", "8.8.8.8", "2606:4700:4700::1111", "2001:4860:4860::8888")
  Set-DNSClientServerAddress -InterfaceAlias    "Wi-Fi*" -ServerAddresses ("1.1.1.1", "8.8.8.8", "2606:4700:4700::1111", "2001:4860:4860::8888")
}

function Disable-FastShutdownShortcut() {
  $DesktopPath = [Environment]::GetFolderPath("Desktop");

  Write-Status -Types "*" -Status "Removing the shortcut to shutdown the computer on the Desktop..." -Warning
  Remove-Item -Path "$DesktopPath\Fast Shutdown.lnk"
}

function Enable-FastShutdownShortcut() {
  $DesktopPath = [Environment]::GetFolderPath("Desktop");

  $SourcePath = "$env:SystemRoot\System32\shutdown.exe"
  $ShortcutPath = "$DesktopPath\Fast Shutdown.lnk"
  $Description = "Turns off the computer without any prompt"
  $IconLocation = "$env:SystemRoot\System32\shell32.dll, 27"
  $Arguments = "-s -f -t 0"
  $Hotkey = "CTRL+ALT+F12"

  Write-Status -Types "+" -Status "Creating a shortcut to shutdown the computer on the Desktop..."
  New-Shortcut -SourcePath $SourcePath -ShortcutPath $ShortcutPath -Description $Description -IconLocation $IconLocation -Arguments $Arguments -Hotkey $Hotkey
}

function Disable-GodMode() {
  Write-Status -Types "*" -Status "Disabling God Mode hidden folder..." -Warning
  Write-Host @"
###############################################################################
#       _______  _______  ______     __   __  _______  ______   _______       #
#      |       ||       ||      |   |  |_|  ||       ||      | |       |      #
#      |    ___||   _   ||  _    |  |       ||   _   ||  _    ||    ___|      #
#      |   | __ |  | |  || | |   |  |       ||  | |  || | |   ||   |___       #
#      |   ||  ||  |_|  || |_|   |  |       ||  |_|  || |_|   ||    ___|      #
#      |   |_| ||       ||       |  | ||_|| ||       ||       ||   |___       #
#      |_______||_______||______|   |_|   |_||_______||______| |_______|      #
#                                                                             #
#         God Mode has been disabled, link removed from your Desktop          #
#                                                                             #
###############################################################################
"@ -ForegroundColor Cyan

  $DesktopPath = [Environment]::GetFolderPath("Desktop");
  Remove-Item -Path "$DesktopPath\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
}

function Enable-GodMode() {
  Write-Status -Types "+" -Status "Enabling God Mode hidden folder on Desktop..."
  Write-Host @"
###############################################################################
#       _______  _______  ______     __   __  _______  ______   _______       #
#      |       ||       ||      |   |  |_|  ||       ||      | |       |      #
#      |    ___||   _   ||  _    |  |       ||   _   ||  _    ||    ___|      #
#      |   | __ |  | |  || | |   |  |       ||  | |  || | |   ||   |___       #
#      |   ||  ||  |_|  || |_|   |  |       ||  |_|  || |_|   ||    ___|      #
#      |   |_| ||       ||       |  | ||_|| ||       ||       ||   |___       #
#      |_______||_______||______|   |_|   |_||_______||______| |_______|      #
#                                                                             #
#      God Mode has been enabled, check out the new link on your Desktop      #
#                                                                             #
###############################################################################
"@ -ForegroundColor Blue

  $DesktopPath = [Environment]::GetFolderPath("Desktop");
  New-Item -Path "$DesktopPath\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}" -ItemType Directory -Force
}

function Disable-OldVolumeControl() {
  Write-Status -Types "*", "Misc" -Status "Disabling Old Volume Control..."
  Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\MTCUVC" -Name "EnableMtcUvc" -Type DWord -Value 1
}

function Enable-OldVolumeControl() {
  Write-Status -Types "+", "Misc" -Status "Enabling Old Volume Control..."
  Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\MTCUVC" -Name "EnableMtcUvc" -Type DWord -Value 0
}


function Disable-SearchAppForUnknownExt() {
  Write-Status -Types "-", "Misc" -Status "Disabling Search for App in Store for Unknown Extensions..."
  If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
      New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1
}

function Enable-SearchAppForUnknownExt() {
  Write-Status -Types "*", "Misc" -Status "Enabling Search for App in Store for Unknown Extensions..."
  If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
      New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 0
}

function Disable-Telemetry() {
  Write-Status -Types "-", "Privacy" -Status "Disabling Telemetry..."
  # [@] (0 = Security (Enterprise only), 1 = Basic Telemetry, 2 = Enhanced Telemetry, 3 = Full Telemetry)
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowDeviceNameInTelemetry" -Type DWord -Value 0
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
}

function Enable-Telemetry() {
  Write-Status -Types "*", "Privacy" -Status "Enabling Telemetry..."
  # [@] (0 = Security (Enterprise only), 1 = Basic Telemetry, 2 = Enhanced Telemetry, 3 = Full Telemetry)
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 3
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowDeviceNameInTelemetry" -Type DWord -Value 1
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 3
}

function Disable-WSearchService() {
  Write-Status -Types "-", "Service" -Status "Disabling Search Indexing (Recommended for HDDs)..."
  Get-Service -Name "WSearch" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
  Stop-Service "WSearch" -Force -NoWait
}

function Enable-WSearchService() {
  Write-Status -Types "*", "Service" -Status "Enabling Search Indexing (Recommended for SSDs)..."
  Get-Service -Name "WSearch" -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic
  Start-Service "WSearch"
}

function Disable-XboxGameBarDVR() {
  $PathToLMPoliciesGameDVR = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"

  Write-Status -Types "-", "Performance" -Status "Disabling Xbox Game Bar DVR..."
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Type DWord -Value 0
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0
  Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
  If (!(Test-Path "$PathToLMPoliciesGameDVR")) {
      New-Item -Path "$PathToLMPoliciesGameDVR" -Force | Out-Null
  }
  Set-ItemProperty -Path "$PathToLMPoliciesGameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
}

function Enable-XboxGameBarDVR() {
  $PathToLMPoliciesGameDVR = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"

  Write-Status -Types "*", "Performance" -Status "Enabling Xbox Game Bar DVR..."
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Type DWord -Value 1
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 1
  Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 1
  If (!(Test-Path "$PathToLMPoliciesGameDVR")) {
      New-Item -Path "$PathToLMPoliciesGameDVR" -Force | Out-Null
  }
  Set-ItemProperty -Path "$PathToLMPoliciesGameDVR" -Name "AllowGameDVR" -Type DWord -Value 1
}
