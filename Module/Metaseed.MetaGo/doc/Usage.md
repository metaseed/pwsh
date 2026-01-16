# Metaseed.MetaGo Usage Guide

## Installation
Import the module in your PowerShell profile:
```powershell
Import-Module "m:\Script\Pwsh\Module\Metaseed.MetaGo\Metaseed.MetaGo.psm1"
# Or if properly placed in PSModulePath:
# Import-Module Metaseed.MetaGo
```

## Setup Shortcut
Add a key binding to your PowerShell profile (e.g., `Alt+.`) to trigger the jump:

```powershell
Set-PSReadLineKeyHandler -Chord 'Alt+.' -ScriptBlock {
    Invoke-MetaJump
}
```

## How to Use

1.  **Trigger:** Press `Alt+.` (or your configured shortcut).
    *   You will see a green cursor indicator and a "Jump: type target char..." tooltip.
2.  **Target:** Type the character you want to jump to (e.g., 'a').
    *   All occurrences of 'a' in the current command line will be highlighted.
    *   Jump codes (e.g., single letters like 'f', 'j' or double letters 'fa') will appear over the matches.
3.  **Jump:** Type the code shown over your desired location.
    *   **Multi-character codes:** If a code is 'fa', type 'f' then 'a'. The jump will happen automatically when the full code is typed.
4.  **Refine (Filter):** If you see too many matches, you can filter them.
    *   The "next character" of each match is **underlined**.
    *   Type that underlined character to narrow down the matches to those specific locations.
    *   *Note:* If your input matches the start of a jump code, it is treated as a code input. If it doesn't match any code, it is treated as a filter input.
5.  **Exit:** Press `Esc` to cancel at any time.

## Configuration
*Currently, configuration (colors, keys) is defined internally in `Get-MetaJumpConfig`. You must edit the `.psm1` file directly to change these.*

## Visuals
*   **Target Matches:** Cyan Background.
*   **Next Char (Guide):** Underlined.
*   **Jump Codes:** Yellow (1 char) or Blue (2+ chars) Background.