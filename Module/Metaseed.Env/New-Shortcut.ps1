Function Set-ShortcutElevation
{
    <#
    .SYNOPSIS
        Sets or removes elevation on shortcuts.
    
    .DESCRIPTION
        Sets or removes elevation on either a single shortcut .lnk file or multiple shortcut .lnk files in a specific folder or directory.
    
    .PARAMETER Path
        The full path to the shortcut, or the directory containing multiple shortcuts.
    
    .PARAMETER Disable
        Disables elevation.
    
    .EXAMPLE
        PS C:\> Set-ShortcutElevation -Path "C:\My Shortcut.lnk"
        PS C:\> "C:\My Shortcut.lnk" | Set-ShortcutElevation -Disable
        PS C:\> Get-ChildItem -Path "C:\My Custom Files" -Filter *.lnk | ForEach { Set-ShortcutElevation -Path $_.FullName }
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = 'The full path to the shortcut, or the directory containing multiple shortcuts.')]
        [ValidateScript( { Test-Path $(Resolve-Path -Path $_) })]
        [string]$Path,
        [Parameter(HelpMessage = 'Disables elevation.')]
        [switch]$Disable
    )
    Begin
    {
        $Offset = 0x15
    }
    Process
    {
        If ((Get-Item -Path $Path).Extension.Equals('.lnk'))
        {
            Try
            {
                $Bytes = [System.IO.File]::ReadAllBytes($Path)
                $Bytes[$Offset] = @(0x00, 0x20)[!$Disable]
                [System.IO.File]::WriteAllBytes($Path, $Bytes)
            }
            Catch
            {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }
}
<#
 .Example
New-ShortCut -sourceExe 'c:\windows\System32\mmc.exe' -arguments 'compmgmt.msc' -DestinationLinkName $env:userprofile\desktop\ComputerManagement.lnk
 .Example
New-Shortcut -sourceExe 'c:\windows\system32\windowspowershell\v1.0\powershell.exe' -DestinationLinkName $env:userprofile\desktop\powershell.lnk
#>
function New-ShortCut {
  [cmdletbinding()]
  Param
  (
    [parameter(Mandatory)]
    [ValidateScript({ Test-Path -path $_ })]
    [string] $sourceExe,

    [parameter(ValueFromPipelineByPropertyName)]
    [string]$Arguments,

    [parameter(ValueFromPipelineByPropertyName)]
    [ValidateScript({
         (Test-Path -path $_) -and ( (Get-Item -path $_).PSIsContainer )
      })]
    [string]$WorkingDirectory,

    [parameter(ValueFromPipelineByPropertyName)]
    [string] $DestinationLinkName = '{0}\temp.lnk' -f [environment]::GetFolderPath("desktop"),
    [parameter(ValueFromPipelineByPropertyName)]
    [ValidateSet('Default', 'Maximized', 'Minimized')]
    [string]$WindowStyle = 'Default',

    [parameter(ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -path $_ })]
    [string]$IconPath,

    [parameter(ValueFromPipelineByPropertyName)]
    [ValidateScript({ $null -ne $IconPath })]
    [int]$IconIndexNumber,

    [parameter(ValueFromPipelineByPropertyName)]
    [string]$HotKeyString,
    
    [switch]$Admin
  )
  $wshShell = New-Object -ComObject WScript.Shell
  $WindowStyles = @{
    Default   = 1
    Maximized = 3
    Minimized = 7
  }
  $shortcut = $wshShell.CreateShortcut( $DestinationLinkName )
  $shortcut.TargetPath = $sourceExe
    
  if ($arguments) { $shortcut.Arguments = $Arguments }
  if ($WorkingDirectory) { $shortcut.WorkingDirectory = $WorkingDirectory }
  if ($WindowStyle) { $shortcut.WindowStyle = $WindowStyles.$WindowStyle }
  if ($HotKeyString) { $shortcut.Hotkey = $HotKeyString }
  if ($IconPath) {
    if ($IconIndexNumber) {
      $shortcut.IconLocation = '{0},{1}' -f $IconPath, $IconIndexNumber
    }
    else {
      $shortcut.IconLocation = $IconPath
    }
  }
  try {
    $shortcut.Save()
    Set-ShortcutElevation -Path $DestinationLinkName -Disable !$Admin
  }
  catch {
    $_.Exception.Message
  }
  $null = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wshShell)
}

Export-ModuleMember Set-ShortcutElevation

