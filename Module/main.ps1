# list the module that need to exposed by default
# using module Metaseed.Env
# remove warning in console of none standard verb in command
# remove waring:  include unapproved verbs that might make them less discoverable. 
# Import-Module PSProfiler
# Measure-Script {
Import-Module Metaseed.Lib -DisableNameChecking
Import-Module Metaseed.Env -DisableNameChecking
Import-Module Metaseed.Console -DisableNameChecking
Import-Module Metaseed.Utility -DisableNameChecking 
Import-Module Metaseed.Git -DisableNameChecking 
Import-Module Metaseed.Sound -DisableNameChecking
Import-Module Metaseed.Terminal -DisableNameChecking

# }