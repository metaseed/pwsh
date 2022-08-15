function Export-Cmdlets {
  param (
      $path
  )
  write-verbose "Get all ps1 files except that start with '_' or in the subfolder that start with '_'."
  $All = Get-AllCmdFiles $path

  Write-Verbose "export cmdlets for Modules: $path"
  $Public = $All | ? { $_.fullname -notmatch '\\Private\\' }
  Export-ModuleMember -Cmdlet $($Public | Select-Object -ExpandProperty BaseName)
}