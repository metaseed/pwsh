# Goal
cursor jumping to the char location in console's input buffer by minimum key typing.

# Design
## Usage
1. user uses  shortcut to trigger the jumping.
   > trigger shortcut i.e. `alt+.` is also configurable.
   > Show indicator and Tooltip to guiding user's jumping
2. Capture State: Get the current buffer text and cursor position.
3. Get Target: Wait for the user to type the target character intended navigating the cursor to.
4. Calculate Matched Locations: Find occurrences of that character, and return the possible locations(same as targe char) are encoded.
   > the encoding use char set configurable, i.e. {"code-chars":"a, b, c, d, e, f, A,B,C"}, the oder means priority, normally easy typing key first. the encoding code can be 2 or more chars, if locations is more than code-chars available.
5. Render Overlay: showing the code indicators on the locations.
  1. Overwrite the text with the displayed code indicators of ANSI-colored characters.
   > code's background color can be configurable, i.e. {"one-char-background-color":"yellow", "more-than-one-char-background-color":"blue"}
  2. Wait for Selection: Read the user's next key typing.
   > visual indicator of background for the next following typeable char in original text, to guid the continue typing:
   > {"next-typeable-char-background-color":"gray" }
   > for the range of text user typed if not covered by code indicator, make it background accordingly to the config: {"user-typed-text-background-color":"lightgray"}

6. Jump: Move the PSReadLine cursor to the matching index, two options
   1. user can type the the code on that location to jump the location.
   2. user can continue type the chars following the location char instead of the code on location to further filter out the possible locations, the location encoding indicators would be updated accordingly. user can type the code to jump at any time like previous step described.
7. Restore: Refresh the PSReadLine interface.

# Implementation
* it mainly using the PSReadline function, so the repo here(https://github.com/PowerShell/PSReadLine) is the first reference for implementation, especially the file in the `PSReadLine/SamplePSReadLineProfile.ps1`
* to use the Module, the user just need to install the module and call one init function in the profile config.

# Document
* generate usage document in doc folder
