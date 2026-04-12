## Search related shortcuts
ctrl+shift+f find all
ctrl+shift+h replace all
ctrl+shift+j toggle files including/excluding
ctrl+up/ctrl+down switch between input boxes

### how to focus search results in Search
F4 show next search results
shift+F4: show previous search results
> note: the focus is in the active file.
> the focus is not moved when using f4/shift+f4.
>
> to move focus: ctrl+shift+f then ctrl+down.
> with focus: `enter` to show en editor, and `ctrl+enter` to to show by side, `alt+enter` to open in `search editor`

{
  "key": "ctrl+up",
  "command": "search.action.focusSearchFromResults",
  "when": "accessibilityModeEnabled && searchViewletVisible || firstMatchFocus && searchViewletVisible"
}
{
  "key": "ctrl+down",
  "command": "search.focus.nextInputBox",
  "when": "inSearchEditor && inputBoxFocus || inputBoxFocus && searchViewletVisible"
}
## Terminal Panel
> Terminal part in: C:\Users\jsong12\AppData\Roaming\Code\User\keybindings.json
* Focus Terminal Tabs View: `ctrl+shift+\`
* Switch terminal tabs: `ctrl+PageUp/PageDown`
* Open external terminal with current proj path: `ctrl+shift+c`
* Toggle the maximized bottom panel: `ctrl+; m`
* new terminal: 'ctrl+shift+`'
* new terminal window: 'ctrl+shift+alt+`'

## open console output from command in vscode
`ipconfig -all|code -`
`code -h|code -` // - means from stdin
`code -h|oc codeHelp.md` // out-code can give a name to support syntax hight and formatting
* open a file path with pipe: `$env:HostsFilePath |% {code $_}`

## git panel
* `ctrl+shift+g`: View: Show Changes, on input box
* `shift+tab`: blur the input box
* `up`|`down`: navigate the changes file list
* `space`: view the current file's changes
* `ctrl+0`: to go back to the left panel
* `ctrl+shift+p`, type 'git changes` or 'git staged' to view changes or staged changes(ctrl+m,g and ctrl+m,ctrl+g)

## side panel
* `ctrl+b`: toggle primary side panel
* `ctrl+alt+b`: toggle second side panel
* `ctrl+0`: focus primary side panel
* `ctrl+alt+0`: focus second side panel

## claude code extension
* `ctrl+i,ctrl+i` to focus/blur to chat input. (forward the selection if there is selection in editor)
* `ctrl+n` to start a new chat session, when in the claude code panel
* /clear command: to reset current session without start a new session.