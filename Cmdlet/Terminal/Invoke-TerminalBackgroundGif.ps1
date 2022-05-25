. $PSScriptRoot/private/GetInstalls.ps1

function Get-MSTerminalProfile {
    [CmdletBinding(DefaultParameterSetName = "ByName")]
    param(
        [Parameter(ParameterSetName = "ByName", Position = 0)]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = "ByGuid", Position = 0)]
        $Guid
    )
    $Path = GetInstalls | Select-Object -Property Value -First 1
    if (!$Path) {
        Write-Error "Cannot locate MS Terminal package" -ErrorAction Stop
        return
    }


    $Settings = (Get-Content $Path ) | ConvertFrom-Json
    if ($Name -eq 'defaults') {
        return $Settings.defaults
    }

    $WTProfile = $Settings.profiles.list
    | Where-Object {
        switch ($PSCmdlet.ParameterSetName) {
            "ByName" {
                if ($Name) {
                    $_.Name -like $Name
                }
                else {
                    $false
                }
            }
            "ByGuid" {
                if (!$Guid.StartsWith("{")) {
                    $Guid = "{$Guid"
                }
                if (!$Guid.EndsWith("}")) {
                    $Guid = "$Guid}"
                }
                $_.Guid -eq $Guid
            }
        }
    }
    return $WTProfile, $Settings
}

function Invoke-TerminalGif {
    <#
.SYNOPSIS
  Plays a gif from a URI to the terminal. Useful when used as part of programs or build scripts to show "reaction gifs" to the terminal to events.
.DESCRIPTION
  This command plays animated GIFs on the Windows Terminal. It performs the operation in a background runspace and only allows one playback at a time. It also remembers your previous windows terminal settings and puts them back after it is done
.EXAMPLE
  PS C:\> Invoke-TerminalGif https://media.giphy.com/media/g9582DNuQppxC/giphy.gif
  Triggers a gif in the current Windows Terminal
#>
    [CmdletBinding()]
    param (
        #The URI of the GIF you want to display
        [Parameter(Mandatory)][uri]$Uri,
        #The name or GUID of the Windows Terminal Profile in which to play the Gif.
        # could be "defaults" or a profile name or GUID, or not set for the current profile
        [String][Alias('GUID')]$Name,
        #How to resize the background image in the window. Options are None, Fill, Uniform, and UniformToFill
        [ValidateSet('none', 'fill', 'uniform', 'uniformToFill')][String]$StretchMode = 'uniformToFill',
        #How transparent to make the background image. Default is 60% (.6)
        [float]$BackgroundImageOpacity = 0.6,
        #Specify this to use the Acrylic visual effect (semi-transparency)
        [switch]$Acrylic,
        #Maximum duration of the gif invocation in seconds
        [int]$MaxDuration = 5
    )

    #Sanity Checks
    if (-not $env:WT_SESSION) { throw "This only works in Windows Terminal currently. Please try running this command again inside a Windows Terminal powershell session." }
    if ($PSEdition -eq 'Desktop' -and -not (Get-Command start-threadjob -erroraction silentlycontinue)) {
        throw "This command requires the ThreadJob module on Windows Powershell 5.1. You can install it with the command Install-Module Threadjob -Scope CurrentUser"
        return
    }

    #Pseudo Singleton to ensure only one prompt job is running at a time.
    $InvokeTerminalGifJobName = 'InvokeTerminalGif'
    $InvokeTerminalGifJob = Get-Job $InvokeTerminalGifJobName -Erroraction SilentlyContinue
    if ($invokeTerminalGifJob) {
        if ($invokeTerminalGifJob.state -notmatch 'Completed|Failed') {
            Write-Warning "Terminal Gif Already Running, stop it..."
        }
        Remove-Job $InvokeTerminalGifJob
    }
    # current profile
    if (-not $Name) { $TerminalProfileWithSettings = Get-MSTerminalProfile -Guid  $env:WT_PROFILE_ID -ErrorAction stop }

    $TerminalProfileWithSettings = if ($Name -as [Guid]) {
        Get-MSTerminalProfile -Guid $Name -ErrorAction stop
    }
    else {
        Get-MSTerminalProfile -Name $Name -ErrorAction stop
    }

    if ($TerminalProfileWithSettings[0].count -gt 1) { throw "Multiple terminal profiles were detected with the Name $Name. Please rename one of the profiles or specify by GUID." }

    #Prepare arguments for the threadjob
    $TerminalGifJobParams = @{ }
  ('TerminalProfileWithSettings', 'uri', 'maxduration', 'stretchmode', 'acrylic', 'backgroundimageopacity').foreach{
        $TerminalGifJobParams.$PSItem = (Get-Variable $PSItem).value
    }

    $TerminalGifJobParams.SettingsPath = GetInstalls | Select-Object -Property Value -First 1

    #   $TerminalGifJobParams.modulePath = (Get-Module msterminalsettings).path -replace 'psm1$','psd1'

    if (-not $TerminalGifJobParams.terminalprofile) { throw "Could not find the terminal profile $Name." }
    if (-not $InvokeTerminalGifJob -or ($InvokeTerminalGifJob.state -eq 'Completed')) {
        $null = Start-ThreadJob -Name $InvokeTerminalGifJobName -argumentlist $TerminalGifJobParams {
            #   Import-Module $args.modulepath
            $uri = $args.uri
            $terminalProfile = $args.TerminalProfileWithSettings[0]
            $Settings = $args.TerminalProfileWithSettings[1]

            if (-not $terminalProfile) { throw "Could not find the terminal profile $($terminalProfile.Name)." }

            Write-Output "Playing $uri in $($terminalProfile.Name) for $($args.maxduration) seconds"
            $erroractionpreference = 'stop'
            $terminalProfileBackup = $terminalProfile | ConvertTo-Json | ConvertFrom-Json
            try {
                $terminalProfile.backgroundImage = $uri
                $terminalProfile.backgroundImageOpacity = $args.backgroundimageopacity
                $terminalProfile.backgroundImageStretchMode = $args.stretchmode
                $terminalProfile.useAcrylic = $args.acrylic

                ConvertTo-Json $Settings -Depth 10 | Set-Content -Path $args.SettingsPath

                Start-Sleep $args.maxduration
            }
            catch { Write-Error $PSItem } 
            finally {
                $terminalProfile.backgroundImage = $terminalProfileBackup.backgroundImage
                $terminalProfile.backgroundImageOpacity = $terminalProfileBackup.backgroundImageOpacity
                $terminalProfile.backgroundImageStretchMode = $terminalProfileBackup.backgroundImageStretchMode
                $terminalProfile.useAcrylic = $terminalProfileBackup.useAcrylic
                ConvertTo-Json $Settings -Depth 10 | Set-Content -Path $args.SettingsPath
            }
        }
    }
    else {
        Write-Warning "Invoke Terminal Already Running"
    }
}