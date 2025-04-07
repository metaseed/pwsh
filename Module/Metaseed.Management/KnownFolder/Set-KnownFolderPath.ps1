<#
.SYNOPSIS
    Sets a known folder's path using SHSetKnownFolderPath.
.PARAMETER Folder
    The known folder whose path to set.
.PARAMETER Path
    The path.
.Example
    Set-KnownFolderPath -KnownFolder 'Desktop' -Path 'C:\'
#>
. $PSScriptRoot\_lib\get-shellFolders.ps1

function Set-KnownFolderPath {
    [CmdletBinding()]
    Param (
            [Parameter(Mandatory = $true)]
            [string]$KnownFolder,

            [Parameter(Mandatory = $true)]
            [string]$Path
    )

    $folder = get-shellFolders |?{$_.Name -eq $KnownFolder}|select -first 1
    # Define SHSetKnownFolderPath if it hasn't been defined already
    $Type = ([Management.Automation.PSTypeName]'KnownFolders').Type
    if (-not $Type) {
        $SHSetKnownFolderPath = @'
[DllImport("shell32.dll")]
public extern static int SHSetKnownFolderPath(ref Guid folderId, uint flags, IntPtr token, [MarshalAs(UnmanagedType.LPWStr)] string path);
'@
        $Type = Add-Type -MemberDefinition $SHSetKnownFolderPath -Name 'KnownFolders' -Namespace 'Win32Functions' -PassThru
    }

    # Validate the path
    if (Test-Path $Path -PathType Container) {
        # Call SHSetKnownFolderPath
        return $Type::SHSetKnownFolderPath([ref]$folder.Guid, 0, 0, $Path)
    } else {
        throw New-Object IO.DirectoryNotFoundException "Could not find part of the path $Path."
    }
}

Register-ArgumentCompleter -CommandName 'Set-KnownFolderPath' -ParameterName 'KnownFolder' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $folders = get-shellFolder $wordToComplete
    return $folders
  }

# https://docs.microsoft.com/en-us/previous-versions/windows/desktop/legacy/bb776911(v=vs.85)