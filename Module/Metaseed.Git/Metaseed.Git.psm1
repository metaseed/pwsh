#Get public and private function definition files.
$Public = @(Get-ChildItem $PSScriptRoot\*.ps1 -ErrorAction SilentlyContinue) 
$Private = @(Get-ChildItem $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue) 

#Dot source the files
Foreach ($import in @($Private+$Public)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error "Failed to import function $($import.fullname): $_"
    }
}

# Modules
Export-ModuleMember -Function $($Public | Select-Object -ExpandProperty BaseName) -Alias *