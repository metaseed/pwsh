<#
.SYNOPSIS
    Disables the Windows "Switch Input Language" (Alt+Shift) and
    "Switch Keyboard Layout" (Ctrl+Shift) hotkeys.

.DESCRIPTION
    Windows stores these two hotkey settings as string values under
    HKCU:\Keyboard Layout\Toggle:

        "Language Hotkey"  -> Switch Input Language
        "Layout Hotkey"    -> Switch Keyboard Layout

    Each accepts:
        1 = enabled, Left Alt+Shift
        2 = enabled, Ctrl+Shift
        3 = disabled ("Not assigned")

    The same values are optionally mirrored under
    HKEY_USERS\.DEFAULT\Keyboard Layout\Toggle so the hotkeys are also
    disabled on the Windows logon screen (default profile).

.NOTES
    Sign out/in or restart afterwards for the change to take effect.
    Modifying HKEY_USERS\.DEFAULT requires an elevated PowerShell session.
#>

$DISABLED = '3'  # "Not assigned" for both hotkeys

$targets = @(
    @{ Name = 'current user'; Path = 'HKCU:\Keyboard Layout\Toggle' }
    @{ Name = 'logon screen (default profile)'; Path = 'Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Toggle' }
)

function Disable-LanguageSwitchHotkeys {
    param(
        [string]$Name,
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    New-ItemProperty -Path $Path -Name 'Language Hotkey' -Value $DISABLED -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $Path -Name 'Layout Hotkey'   -Value $DISABLED -PropertyType String -Force | Out-Null

    Write-Host "Disabled Alt+Shift / Ctrl+Shift hotkeys for: $Name"
}

foreach ($target in $targets) {
    try {
        Disable-LanguageSwitchHotkeys -Name $target.Name -Path $target.Path
    } catch {
        Write-Warning "Failed to update '$($target.Name)' ($($target.Path)): $_"
    }
}

Write-Host "`nDone. Sign out and back in (or restart) for the change to take effect."