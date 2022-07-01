function Get-Startups {
    [CmdletBinding()]
    Param
    (
    )


    # New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS | 
    # out-null
    $startups = Get-CimInstance Win32_StartupCommand | 
    Select-Object Name, Location, User, Command
    $startups | format-table
    # '------'
    # $disableList = @(
    #     'SecurityHealth',
    #     'OneDrive',
    #     'iTunesHelper',
    #     'Cisco AnyConnect Secure Mobility Agent for Windows',
    #     'Ccleaner Monitoring',
    #     #'SunJavaUpdateSched',
    #     'Steam',
    #     'Discord'
    # )
    # $32bit = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    # $32bitRunOnce = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    # $64bit = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
    # $64bitRunOnce = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce"
    # $currentLOU = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    # $currentLOURunOnce = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    # Get-Item -path $32bit, $32bitRunOnce, $64bit, $64bitRunOnce, $currentLOU, $currentLOURunOnce |
    # Where-Object { $_.ValueCount -ne 0 } | 
    # Select-Object  @{Name = 'Location'; Expression = { $_.name -replace 'HKEY_LOCAL_MACHINE', 'HKLM' -replace 'HKEY_CURRENT_USER', 'HKCU' } },
    # @{Name = 'Name'; Expression = { $_.Property } } | 
    # % {
    #     ForEach ($disableListName in $disableList) {
    #         If ($_.Name -contains $disableListName) {
    #             $_ | Select-Object -Property Location, Name | % {
    #                 # Remove-ItemProperty -Path $_.Location -Name "$($_.name)" -whatif
    #             }
    #         }
    #         Else
    #         { Write-Warning -Message "$disableListName not found in registry" }
    #     }
    # }

}
# Disable-Startups