<#
.SYNOPSIS
    Disables the per-IME "Ime/NonIme Toggle" hotkey (e.g. Ctrl+Space for the
    Chinese Simplified/Traditional IME) shown in Advanced Key Settings.

.DESCRIPTION
    Each entry in Settings > Time & language > Typing > Advanced keyboard
    settings > Input language hot keys > Advanced Key Settings maps to a
    numbered subkey under HKCU:\Control Panel\Input Method\Hot Keys, e.g.:
        00000010 - Chinese (Simplified) IME - Ime/NonIme Toggle
        00000070 - Chinese (Traditional) IME - Ime/NonIme Toggle

    Each subkey has REG_BINARY values:
        "Key Modifiers" - byte 0: 00=none, 01=LAlt, 02=Shift, 04=Ctrl, 06=Ctrl+Shift
        "Virtual Key"   - byte 0: virtual-key code, or FF = none

    Setting Key Modifiers=00 and Virtual Key=FF is the same state Windows
    writes when you uncheck "Enable Key Sequence" in that dialog and click OK.

.NOTES
    KNOWN UNRELIABLE: per multiple reports, Windows can silently reset these
    values back to Ctrl+Space, especially if the legacy "Advanced Key
    Settings" dialog is reopened afterwards. A sign-out/restart is required
    for the change to take effect either way.
#>

$imeHotkeyIds = @(
    '00000010'  # Chinese (Simplified) IME
    '00000070'  # Chinese (Traditional) IME
)

function Disable-ImeToggleHotkey {
    param([string]$Id)

    $path = "HKCU:\Control Panel\Input Method\Hot Keys\$Id"
    if (-not (Test-Path $path)) {
        Write-Warning "No IME hotkey entry '$Id' found (not installed on this machine) - skipping."
        return
    }

    New-ItemProperty -Path $path -Name 'Key Modifiers' -Value ([byte[]](0x00,0xc0,0x00,0x00)) -PropertyType Binary -Force | Out-Null
    New-ItemProperty -Path $path -Name 'Virtual Key'   -Value ([byte[]](0xff,0x00,0x00,0x00)) -PropertyType Binary -Force | Out-Null

    Write-Host "Disabled IME toggle hotkey: $Id"
}

foreach ($id in $imeHotkeyIds) {
    try {
        Disable-ImeToggleHotkey -Id $id
    } catch {
        Write-Warning "Failed to update IME hotkey '$id': $_"
    }
}

Write-Host "`nDone. Sign out and back in (or restart) for the change to take effect."