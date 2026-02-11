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

## Switch terminal tabs
`ctrl+pageDown`
