. $PSScriptRoot/Get-AllCmdFiles.ps1

<#
.DESCRIPTION
auto include all .ps1 into .psm1 except the foler/file that start with "_";
auto export a function of the file name, except the file in the private sub-folder;

to export addtional function just add `Export-ModuleMember ***` in the file
we could explictly include the _file/_folder files

.NOTES
to reload the module after changing:
ipmo metaseed.git -fo
import-module metaseed.git -force.
.NOTES
when make this function in as module, even dot source the funciton
it still not work. so do this:
. $env:MS_PWSH/Lib/Export-Functions.ps1
. Export-Functions $PSScriptRoot

.EXAMPLE
. Export-Functions $PSScriptRoot
  note:   have to dot include the function, because
          # https://stackoverflow.com/questions/15187510/dot-sourcing-functions-from-file-to-global-scope-inside-of-function
          need to dot source the function otherwise the file dotsourced in the Export-Functions would not be included in moudle scope
          after dotsource the function, it's the same as the function content is defined here in the same file.
          https://powershell.one/powershell-internals/modules/overview
#>
function Export-Functions {
    param (
        $path
    )
    $All = Get-AllCmdFiles $path
    write-verbose "Dot source the files"
    foreach ($import in $All) {
        Try {
            . $import.fullname
            Write-Verbose "import file: $($import.fullname)"
        }
        Catch {
            Write-Error "Failed to import function $($import.fullname): $_"
        }
    }
    Write-Verbose "export function for Modules: $path"
    $Public = $All | ? { $_.fullname -notmatch '\\Private\\' }
    Export-ModuleMember -Function $($Public | Select-Object -ExpandProperty BaseName) -Alias *
}