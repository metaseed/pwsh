
@{

# Script module or binary module file associated with this manifest.
RootModule = 'Metaseed.ZLocation.psm1'

# Version number of this module.
ModuleVersion = '1.4.3'

# ID used to uniquely identify this module
# GUID = '18e8ca17-7f67-4f1c-85ff-159373bf69f5'


# # Description of the functionality provided by this module
# Description = 'ZLocation is the new Jump-Location. A `cd` that learns.'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @("LiteDB\LiteDB.dll")

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# This creates additional scopes and Pester cannot mock cmdlets in those scopes. We use Import-Module directly in Zlocation.psm1 instead.
# NestedModules = @("ZLocation.Storage.psm1", "ZLocation.Search.psm1")

# Functions to export from this module
FunctionsToExport = @(
    'Get-ZLocation',
    'Invoke-ZLocation',
    'Pop-ZLocation',
    'Remove-ZLocation',
    'Set-ZLocation',
    'Update-ZLocation',
    'Clear-NonExistentZLocation'
)

# Cmdlets to export from this module
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module
AliasesToExport = @(
    'z'
)

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/vors/ZLocation/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/vors/ZLocation'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = 'https://github.com/vors/ZLocation/blob/master/CHANGELOG.md'

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}