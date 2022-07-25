[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $module = 'metaseed.vm'
)

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass # can not load zlocatin.psm1

$mo = ipmo $module -PassThru -DisableNameChecking
$path = (split-path $mo.Path) + "\$module.psd1"

# $psd = (gc $path -raw | Invoke-Expression)
# $psd.ExportedFunctions = $mo.ExportedFunctions
# [System.Management.Automation.PSSerializer]::Serialize($psd) | Out-File $path
$content = gc $path -raw
$func = $mo.ExportedFunctions.Keys -join "','"
Write-Verbose $func
if ($content -notlike '*FunctionsToExport*') {
  $content = $content -replace "ModuleVersion.+`n", "`$0  FunctionsToExport = @('$func')`n" 
}
else {
  $content = $content -replace "(FunctionsToExport\s*=\s*@\().+\)", "`$1'$func')" 
}
#   $content = $content -replace "FunctionsToExport\s*=\s*@\(.*\)", ''
$cmd = $mo.ExportedCmdlets.Keys -join "','"
Write-Verbose $cmd

if ($content -notlike '*CmdletsToExport*') {
  $content = $content -replace "ModuleVersion.+`n", "`$0  CmdletsToExport = @('$cmd')`n" 
}
else {
  $content = $content -replace "(CmdletsToExport\s*=\s*@\().+\)", "`$1'$cmd')" 
}
$content = $content.TrimEnd("`r","`n")

# $content += "`r`n"
# $content = $content -replace "CmdletsToExport\s*=\s*@\(.*\)", ''
$content | out-file $path

# gci M:\Script\Pwsh\Module\ -Directory|% {update-exports $_.BaseName}