* how to focus search results in Search
F4 focus next search results
shift+F4: previous search results
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