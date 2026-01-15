# Goal
cursor jumping to the char location in console's input buffer by minimum key typing.

# Design
## Usage
* user uses  shortcut i.e. `alt+.` to trigger the jumping.
* user then type the char intended navigating the cursor to, the possible location's background of the char changed color.
  * user can type the background-color-code(b: blue, r: red, y: yellow, g: green, w: white, m: magenta, c: cyan) to goto the location.
  * user can continue type the chars following the location char instead of the background-color-code to further filter out the possible locations to encoding with the background-color-code, and can type the code at any time to do navigation.

## Notes
* the background-color-codes are configurable, and the order means priority, normally easy typing key first, i.e.
"background-color-code": ["g: green", "w: white",  "r: red", "b: blue",  "c: cyan, "y: yellow", "m: magenta"]
user can config and remove or modify the key-value, i.e. remove the color used by the console background.
* trigger shortcut i.e. `alt+.` is also configurable.
# Solution
## How to get location key from user typing after the trigger of the command
> use [Console]::ReadKey($true)

reference:https://github.dev/PowerShell/PSReadLine/SamplePSReadLineProfile.ps1 line 537: Ctrl+j then the same key will change back to that directory

## How to modify the background color of chars in buffer?
1. Capture State: Get the current buffer text and cursor position.
1. Get Target: Wait for the user to type the target character.
1. Calculate Matches: Find occurrences of that character.
1. Render Overlay:
  1. Calculate the visual position of the input start.
  1. Overwrite the displayed text with ANSI-colored characters (Green, Red, Blue, etc.) corresponding to your jump keys.
  1. Wait for Selection: Read the user's next key (the color code).
1. Jump: Move the PSReadLine cursor to the matching index.
1. Restore: Refresh the PSReadLine interface.

# Implementation
* a pwsh module like other modules in the grand parent folder(PWSH/Module), following same pattern to create the .psm1 file and .psd1 file, which should be in the parent folder `MetaGo`.
* the main implementation is in the `MetaJump` folder.
* it mainly using the PSReadline function, so the repo here(https://github.com/PowerShell/PSReadLine) is the first reference for implementation, especially the file in the `PSReadLine/SamplePSReadLineProfile.ps1`
* to use the Module, the user just need to install the module and call one init function in the profile config.

# Document
* generate usage document in doc folder
