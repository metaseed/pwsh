function Export-Functions {
    param (
        $path
    )
    # Get public and private function definition files.
    $Public = @(Get-ChildItem $path\*.ps1 -ErrorAction SilentlyContinue) # use @() to make sure return is an array, even 1 or no item
    $Private = @(Get-ChildItem $path\Private\*.ps1 -ErrorAction SilentlyContinue )
    #Dot source the files
    Foreach ($import in @($Public + $Private)) {
        Try {
            . $import.fullname
            Write-Host $import.fullname
        }
        Catch {
            Write-Error "Failed to import function $($import.fullname): $_"
        }
    }
    # Modules
    return @($Public | Select-Object -ExpandProperty BaseName)
    
}