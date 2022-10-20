# Import-Module PSProfiler
# Measure-Script {
. $PSScriptRoot\var.ps1
. $PSScriptRoot\env.ps1
# the module could be auto-loaded
. $PSScriptRoot\posh-git.ps1
. $PSScriptRoot\..\Module\main.ps1
. $PSScriptRoot\alias.ps1
. $PSScriptRoot\PSReadlineConfig.ps1
. $PSScriptRoot\last-output.ps1
. $PSScriptRoot\terminal\terminal.ps1
. $PSScriptRoot\PS-GuiCompletion.ps1
# }

# $null = New-Event -SourceIdentifier 'PWSH_PROFILE_LOADED_EVENT'  #-EventArguments {}