<#
Get all ps1 files except that start with '_' or in the subfolder that start with '_'
#>
function Export-Cmdlets {
  param (
      $path
  )
  $path = [IO.Path]::GetFullPath($path).TrimEnd('/') # note: \ changed to /, there is / is ended with \ or /

  $All = Get-AllCmdFiles $path

  $Public = $All | ? { $_.fullname.TrimStart($path) -notmatch '\\Private\\' }
  Export-ModuleMember -Cmdlet $($Public | Select-Object -ExpandProperty BaseName)
}