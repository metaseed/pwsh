<# 
.DESCRIPTION
export all function of the file name, to export addtional function just add 
              Export-ModuleMember *** in the file

.NOTES
to reload the module after changing:
ipmo metaseed.git -fo
import-module metaseed.git -force.

folder start with '_' is not checked
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
    # Get public and private function definition files.
    $Public = @(Get-ChildItem $path\*.ps1 -ErrorAction SilentlyContinue -Recurse) # use @() to make sure return is an array, even 1 or no item
    $Private = @(Get-ChildItem $path\Private\*.ps1 -ErrorAction SilentlyContinue -Recurse )
    #Dot source the files
    Foreach ($import in @($Public + $Private)) {
        Try {
            if ($import.fullname -notmatch '\\_.*\\') {
                . $import.fullname
            }
            # Write-Host $import.fullname
        }
        Catch {
            Write-Error "Failed to import function $($import.fullname): $_"
        }
    }
    # Modules
    Export-ModuleMember -Function $($Public | Select-Object -ExpandProperty BaseName) -Alias *
    
}