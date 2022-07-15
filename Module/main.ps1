# list the module that need to exposed by default
# using module Metaseed.Management
# remove warning in console of none standard verb in command
# remove waring:  include unapproved verbs that might make them less discoverable. 
Import-Module "$PSScriptRoot\Metaseed.Lib\Metaseed.Lib.psd1" -DisableNameChecking
Import-Module "$PSScriptRoot\Metaseed.Utility\Metaseed.Utility.psd1" -DisableNameChecking 
Import-Module "$PSScriptRoot\Metaseed.Management\Metaseed.Management.psd1" -DisableNameChecking
Import-Module "$PSScriptRoot\Metaseed.Console\Metaseed.Console.psd1" -DisableNameChecking
# Import-Module Metaseed.Terminal -DisableNameChecking
Import-Module "$PSScriptRoot\Metaseed.Git\Metaseed.Git.psd1" -DisableNameChecking 
Import-Module "$PSScriptRoot\Metaseed.Sound\Metaseed.Sound.psd1" -DisableNameChecking
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass # can not load zlocatin.psm1
Import-Module "$PSScriptRoot\Metaseed.ZLocation\Metaseed.ZLocation.psd1"

# note: this file maybe delted because the modules coulc be dynamically loaded