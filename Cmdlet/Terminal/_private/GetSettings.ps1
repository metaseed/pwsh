function GetSettings {
  # https://docs.microsoft.com/en-us/windows/terminal/install#settings-json-file
  $Settings = @{
    Stable     = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    Preview    = "$env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    Unpackaged = "$env:LocalAppData\Microsoft\Windows Terminal\settings.json" # Scoop, Chocolately, etc)
  }
  # this will return a DictionaryEntry array or just one entry
  # return  $Settings.GetEnumerator() | ? { test-path $_.value };
  # to fix:
  $keys = @($Settings.Keys) # copy to array to avoid enumerating directly

  $keys | % {
    if(-not (test-path $Settings[$_])) {
      $Settings.Remove($_)
    }
  }

  return $Settings
}
