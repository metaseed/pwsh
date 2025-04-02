function Config-WindowsLibrary {
    <#
    .SYNOPSIS
        Creates or updates a Windows Library (.library-ms) file.

    .DESCRIPTION
        This function creates a new Windows Library or updates an existing one by adding new folder paths.
        It ensures that duplicate paths are not added and notifies the user accordingly.

    .PARAMETER LibraryName
        Specifies the name of the Windows Library to create or update.

    .PARAMETER Folders
        An array of folder paths (local or network) to be included in the library.

    .EXAMPLE
        Config-WindowsLibrary -LibraryName "MyLibrary" -Folders "C:\Path1", "\\Server\Share"
        Creates or updates "MyLibrary" with the specified folders.

    .NOTES
        it will only add it into the `Libraries` folder but not shown in `This PC` of `File Explorer`
        you can pin it to the left panel, i.e. `Quick Access`
    #>
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Enter the name of the Windows Library.")]
        [string]$LibraryName,  # Name of the library

        [Parameter(Mandatory = $true, HelpMessage = "Enter one or more folder paths to include in the library.")]
        [string[]]$Folders  # Array of folders to merge into the library
    )

    # Define the library file path
    $LibraryFile = "$env:APPDATA\Microsoft\Windows\Libraries\$LibraryName.library-ms"
    $ExistingFolders = @()

    # Check if the library already exists and read its content
    if (Test-Path $LibraryFile) {
        Write-Host "Updating existing library: $LibraryName"
        $ExistingContent = Get-Content -Path $LibraryFile -Raw
        $ExistingFolders = [regex]::Matches($ExistingContent, '<url>file:///(.*?)</url>') | ForEach-Object { $_.Groups[1].Value }
    } else {
        Write-Host "Creating new library: $LibraryName"
    }

    # Define the library XML structure
    $LibraryXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<libraryDescription xmlns="http://schemas.microsoft.com/windows/2009/library">
    <name>$LibraryName</name>
    <version>6</version>
    <isLibraryPinned>true</isLibraryPinned>
    <iconReference>imageres.dll,-1002</iconReference>
    <templateInfo>
        <folderType>Generic</folderType>
    </templateInfo>
    <searchConnectorDescriptionList>
"@

    # Add each folder to the library, notifying if it's already included
    foreach ($Folder in $Folders) {
        if ($ExistingFolders -contains $Folder) {
            Write-Host "Folder already exists in library: $Folder"
        } else {
            Write-Host "Adding new folder to library: $Folder"
            $LibraryXml += @"
        <searchConnectorDescription>
            <simpleLocation>
                <url>file:///$Folder</url>
            </simpleLocation>
        </searchConnectorDescription>
"@
        }
    }

    # Close the XML structure
    $LibraryXml += @"
    </searchConnectorDescriptionList>
</libraryDescription>
"@

    # Save the XML to the library file
    $LibraryXml | Out-File -Encoding UTF8 -FilePath $LibraryFile

    Write-Host "Library set: $LibraryFile"
}

# Example usage:
# Config-WindowsLibrary -LibraryName "MyLibrary" -Folders "C:\Path1", "\\Server\Share"
