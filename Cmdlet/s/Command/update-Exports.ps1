[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $module = 'metaseed.management'
)

$mo = ipmo $module -PassThru -DisableNameChecking
$path = (split-path $mo.Path) + "\$module.psd1"

# $psd = (gc $path -raw | Invoke-Expression)
# $psd.ExportedFunctions = $mo.ExportedFunctions
# [System.Management.Automation.PSSerializer]::Serialize($psd) | Out-File $path
$func = $mo.ExportedFunctions.Keys -join "','"
$content = gc $path -raw
if($content -notlike '*FunctionsToExport*') {
  $newContent = $content  -replace "ModuleVersion.+`n", "`$0  FunctionsToExport = @('$func')`n" 
} else{
  $newContent = $content  -replace "(FunctionsToExport\s*=\s*@\().+\)", "`$1'$func')" 
}
$newContent | out-file $path