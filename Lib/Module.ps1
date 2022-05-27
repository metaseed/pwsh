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

.EXAMPLE
. Export-Functions $PSScriptRoot
  note:   have to dot include the function, because
          # https://stackoverflow.com/questions/15187510/dot-sourcing-functions-from-file-to-global-scope-inside-of-function
          need to dot source the function otherwise the file dotsourced in the Export-Functions would not be included in moudle scope
          after dotsource the function, it's the same as the function content is defined here in the same file.
#>
function Export-Functions {
    param (
        $path
    )
    # Get all ps1 files except that start with '_' or in the subfolder that start with '_'.
    $All = @(Get-ChildItem $path\*.ps1 -ErrorAction SilentlyContinue -Recurse -Exclude _* | ? { $_.fullname -notmatch '\\_.*\\' }) # use @() to make sure return is an array, even 1 or no item
    #Dot source the files
    Foreach ($import in $All) {
        Try {
            . $import.fullname
            # Write-Host $import.fullname
        }
        Catch {
            Write-Error "Failed to import function $($import.fullname): $_"
        }
    }
    # Modules
    $Public = $All | ? { $_.fullname -notmatch '\\Private\\' }
    Export-ModuleMember -Function $($Public | Select-Object -ExpandProperty BaseName) -Alias *
}