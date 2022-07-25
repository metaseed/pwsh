[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $module = 'metaseed.vm'
)
Get-Module -ListAvailable -Refresh > $null

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass # can not load zlocatin.psm1
$mo = ipmo $module -Force -PassThru -DisableNameChecking
$path = (split-path $mo.Path) + "\$module.psd1"

# $psd = (gc $path -raw | Invoke-Expression)
# $psd.ExportedFunctions = $mo.ExportedFunctions
# [System.Management.Automation.PSSerializer]::Serialize($psd) | Out-File $path

# remove functionsToExport and CmdletsToExport from psd1, and reimport to get all functions and cmdlets,
# otherwise only the listed in the psd1 are used, so not really updated
$content = gc $path -raw
$content = $content -replace "FunctionsToExport\s*=\s*@\(.*\)`n", ''
$content = $content -replace "CmdletsToExport\s*=\s*@\(.*\)`n", ''
$content | Out-File $path
$mo = ipmo $module -Force -PassThru -DisableNameChecking

$func = $mo.ExportedFunctions.Keys -join "','"
Write-Verbose "exported functions: $func"
if ($content -notlike '*FunctionsToExport*') {
  $content = $content -replace "ModuleVersion.+`n", "`$0  FunctionsToExport = @('$func')`n" 
}
else {
  $content = $content -replace "(FunctionsToExport\s*=\s*@\().+\)", "`$1'$func')" 
}
$cmd = $mo.ExportedCmdlets.Keys -join "','"
Write-Verbose "exported commands:$cmd"

if ($content -notlike '*CmdletsToExport*') {
  $content = $content -replace "ModuleVersion.+`n", "`$0  CmdletsToExport = @('$cmd')`n" 
}
else {
  $content = $content -replace "(CmdletsToExport\s*=\s*@\().+\)", "`$1'$cmd')" 
}
$content = $content.TrimEnd("`r","`n")

# $content += "`r`n"
$content | out-file $path

# gci M:\Script\Pwsh\Module\ -Directory|% {update-exports $_.BaseName}