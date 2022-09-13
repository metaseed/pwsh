function Uninstall-Appx {
    [CmdletBinding()]
    param (
        [Array] $AppxPackages
    )

    foreach ($AppxPackage in $AppxPackages) {
        If ((Get-AppxPackage -AllUsers -Name $AppxPackage) -or (Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $AppxPackage)) {
            Write-Verbose "Trying to remove $AppxPackage from ALL users ..."
            Get-AppxPackage -AllUsers -Name $AppxPackage | Remove-AppxPackage
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $AppxPackage | Remove-AppxProvisionedPackage -Online -AllUsers
        }
        Else {
            Write-Warning "$AppxPackage was already removed or not found ..."
        }
    }
}

<#
Example:
  Uninstall-Appx @('*FeedbackHub*', '*YourPhone*')
  Remove-UWPAppx -AppxPackages "AppX1"
  Remove-UWPAppx -AppxPackages @("AppX1", "AppX2", "AppX3")
#>