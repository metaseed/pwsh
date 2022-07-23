# list the module that need to exposed by default
# using module Metaseed.Management
# remove warning in console of none standard verb in command
# remove waring:  include unapproved verbs that might make them less discoverable. 
# Import-Module "$PSScriptRoot\Metaseed.Lib\Metaseed.Lib.psd1" -DisableNameChecking
# Import-Module "$PSScriptRoot\Metaseed.Utility\Metaseed.Utility.psd1" -DisableNameChecking 
# Import-Module "$PSScriptRoot\Metaseed.Management\Metaseed.Management.psd1" -DisableNameChecking
# Import-Module "$PSScriptRoot\Metaseed.Console\Metaseed.Console.psd1" -DisableNameChecking
# # Import-Module Metaseed.Terminal -DisableNameChecking
# Import-Module "$PSScriptRoot\Metaseed.Git\Metaseed.Git.psd1" -DisableNameChecking 
# Import-Module "$PSScriptRoot\Metaseed.Sound\Metaseed.Sound.psd1" -DisableNameChecking
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass # can not load zlocatin.psm1
# Import-Module "$PSScriptRoot\Metaseed.ZLocation\Metaseed.ZLocation.psd1"

# note: this file maybe delted because the modules coulc be dynamically loaded
# https://powershell.one/powershell-internals/modules/overview
# https://docs.microsoft.com/en-us/powershell/scripting/developer/module/importing-a-powershell-module?view=powershell-7.2
# dynamic module loading:
# This feature is driven by an internal command cache that lists all available commands, 
# and the location of the modules providing these commands.
# This cache can get corrupted or become stale, especially when you add new modules. 
# If PowerShell fails to suggest commands correctly, you can force a cache rebuild and diagnose auto-discovery issues. Run this command:
# Get-Module -ListAvailable -Refresh