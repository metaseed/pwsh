# Metaseed.MetaGo Validation Report

**Date:** 2026-01-16
**Version:** 0.1 (Draft)

## Summary
The `Metaseed.MetaGo` module implements the core "jump to character" functionality described in the README. It successfully captures the console buffer, calculates matches, renders overlays, and handles cursor movement. However, there are significant gaps between the documented design (especially regarding multi-character codes) and the current logic.

## Detailed Validation

### 1. Goal & Usage Flow
*   **Goal:** Cursor jumping is implemented via `Invoke-MetaJump-Refined`.
*   **Trigger:** The function is exported and aliased. Shortcut binding is left to the user (standard practice).
*   **Visuals:** Tooltips and Start Indicators are implemented.

### 2. Logic Implementation vs Design
| Feature | Status | Notes |
| :--- | :--- | :--- |
| **Capture State** | ✅ Implemented | Uses `PSConsoleReadLine::GetBufferState`. |
| **Get Target** | ✅ Implemented | Waits for initial char input. |
| **Calculate Matches** | ✅ Implemented | Finds all indices of target char. |
| **Jump Codes** | ⚠️ Partial | Generates 1 or 2-char codes, BUT logic to *use* 2-char codes is broken. The loop expects a single key to match a full code. |
| **Render Overlay** | ✅ Implemented | Draws ANSI colors over text. |
| **Jump Action** | ⚠️ Partial | Works for single-char codes. Multi-char codes cannot be triggered. |
| **Filter Action** | ✅ Implemented | Typing non-code chars refines the search filter. |

### 3. Key Issues Identified

#### A. Multi-Character Code Logic (Critical)
The README states: *"encoding code can be 2 or more chars"*.
The implementation in `Invoke-MetaJump-Refined` reads a single key:
```powershell
$key = [Console]::ReadKey($true)
# ...
if ($codes[$i] -eq "$inputChar") { ... }
```
If `Get-JumpCodes` returns a code like "ab", the user types 'a'.
*   Current behavior: 'a' is compared to "ab" -> No match.
*   'a' is then added to `$filterText`, treating it as a filter refinement rather than the first half of a jump code.
*   **Fix Required:** Implement a state machine to track "partial code match" vs "filter input".

#### B. Configuration
The configuration is hardcoded in `Get-MetaJumpConfig` inside the `.psm1` file.
*   *Issue:* Users cannot change colors or charset without editing source code.
*   *Recommendation:* Allow passing config as parameters or reading from a global/module variable.

#### C. ANSI Color Mapping
The `Get-AnsiColor` function and `Draw-Overlay` have hardcoded ANSI values (e.g., "46" for DarkCyan, "100" for Gray) that might not match the textual configuration names perfectly or support all terminals.

## Recommendations
1.  **Refactor Input Loop:** Distinguish between typing a jump code (potentially multi-step) and typing to filter. One common approach is: if the input matches the *prefix* of any active jump codes, enter "Jump Code Mode" or wait for next key. If it matches no code prefixes, treat as filter.
2.  **Externalize Config:** Support a `$Global:MetaGoConfig` or similar.
3.  **Fix 2-Char Codes:** Ensure `Get-JumpCodes` logic aligns with the input handling.

