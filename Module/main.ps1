# list the module that need to exposed by default
# using module Metaseed.Management
# remove warning in console of none standard verb in command
# remove waring:  include unapproved verbs that might make them less discoverable. 
Import-Module Metaseed.Lib -DisableNameChecking
Import-Module Metaseed.Utility -DisableNameChecking 
Import-Module Metaseed.Management -DisableNameChecking
Import-Module Metaseed.Console -DisableNameChecking
# Import-Module Metaseed.Terminal -DisableNameChecking
# Import-Module Metaseed.Git -DisableNameChecking 
Import-Module Metaseed.Sound -DisableNameChecking

# note: this file maybe delted because the modules coulc be dynamically loaded