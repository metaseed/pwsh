try {
  $godMode = "$home\Desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
  if (!(gi $godMode)) {

    $GodModeSplat = @{
      Path     = "$HOME\Desktop"
      Name     = "GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
      ItemType = 'Directory'
    }
    new-item @GodModeSplat

    "✔️ enabled god mode - see the new desktop icon"
  }
  start $godMode
}
catch {
  "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
}