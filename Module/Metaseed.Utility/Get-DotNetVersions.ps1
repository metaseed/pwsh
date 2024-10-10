function Get-DotNetFrameworkVersions() {
    function Get-Framework40Version($type) {
        # .net 4.0 is installed
        $version = Get-ItemPropertyValue "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\$type" "Release"

        if ($version -ge 461808 -Or $version -ge 461814) {
            # .net 4.7.2
            return "4.7.2"
        }
        elseif ($version -ge 461308 -Or $version -ge 461310) {
            reutn  "4.7.1"
        }
        elseif ($version -ge 460798 -Or $version -ge 460805) {
            return "4.7"
        }
        elseif ($version -ge 394802 -Or $version -ge 394806) {
            return "4.6.2"
        }
        elseif ($version -ge 394254 -Or $version -ge 394271) {
            return "4.6.1"
        }
        elseif ($version -ge 393295 -Or $version -ge 393297) {
            retrun "4.6"
        }
        elseif ($version -ge 379893) {
            return  "4.5.2"
        }
        elseif ($version -ge 378675) {
            return "4.5.1"
        }
        elseif ($version -ge 378389) {
            return "4.5"
        }
    }

    function Test-ItemProperty([string]$path, [string]$key) {
        if (!(Test-Path $path)) { return $false }
        try {
            if ($null -eq (Get-ItemProperty $path ).$key) { return $false }
        }
        catch {
            return $false
        }
        return $true
    }

    $installedFrameworks = @()
    if (Test-ItemProperty "HKLM:\Software\Microsoft\.NETFramework\Policy\v1.0" "3705") { $installedFrameworks += ".Net Framework 1.0" }
    if (Test-ItemProperty "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v1.1.4322" "Install") { $installedFrameworks += ".Net Framework 1.1" }
    if (Test-ItemProperty "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v2.0.50727" "Install") { $installedFrameworks += ".Net Framework 2.0" }
    if (Test-ItemProperty "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v3.0\Setup" "InstallSuccess") { $installedFrameworks += ".Net Framework 3.0" }
    if (Test-ItemProperty "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v3.5" "Install") { $installedFrameworks += ".Net Framework 3.5" }
    if (Test-ItemProperty "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client" "Install") { $installedFrameworks += ".Net Framework Client $(Get-Framework40Version 'Client')" }
    if (Test-ItemProperty "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full" "Install") { $installedFrameworks += ".Net Framework Full $(Get-Framework40Version 'Full')" }

    return $installedFrameworks
}

# All .Net Frameworks possible to download here: https://www.microsoft.com/net/download/dotnet-framework-runtime
function Install-DotNetFramwork4() {
    # net 4.0   -> http://download.microsoft.com/download/1/B/E/1BE39E79-7E39-46A3-96FF-047F95396215/dotNetFx40_Full_setup.exe
    # net 4.5   -> http://download.microsoft.com/download/B/A/4/BA4A7E71-2906-4B2D-A0E1-80CF16844F5F/dotNetFx45_Full_setup.exe
    # net 4.5.2 -> http://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe
    # net 4.6   -> http://download.microsoft.com/download/1/4/A/14A6C422-0D3C-4811-A31F-5EF91A83C368/NDP46-KB3045560-Web.exe => except win 10
    # net 4.7.2 -> https://download.microsoft.com/download/3/3/2/332D9665-37D5-467A-84E1-D07101375B8C/NDP472-KB4054531-Web.exe
    $url = "https://download.microsoft.com/download/3/3/2/332D9665-37D5-467A-84E1-D07101375B8C/NDP472-KB4054531-Web.exe"
    $output = "$env:TEMP\netFrameworkInstaller.exe"
    $start_time = Get-Date

    Invoke-WebRequest -Uri $url -OutFile $output
    Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

    Start-Process $output
    # -NoNewWindow -Wait
}

function Get-DotnetVersions {
    Write-Notice "Dotnet Frameworks 4:"
    Get-DotNetFrameworkVersions
    Write-Notice "Dotnet Frameworks runtimes:"
    dotnet --list-runtimes
    Write-Notice "Dotnet Frameworks sdks:"
    dotnet --list-sdks
}