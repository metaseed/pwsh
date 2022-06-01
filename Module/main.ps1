# list the module that need to exposed by default
# using module Metaseed.Env
Import-Module Metaseed.Lib -DisableNameChecking
Import-Module Metaseed.Env -DisableNameChecking
Import-Module Metaseed.Utility -DisableNameChecking # remove waring:  include unapproved verbs that might make them less discoverable. 
Import-Module Metaseed.Git -DisableNameChecking # remove warning in console of none standard verb in command
Import-Module Metaseed.Sound -DisableNameChecking

