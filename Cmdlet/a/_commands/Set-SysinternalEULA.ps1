<#
set global EULA acceptance for all SysInternals tools, so no EULA agreement dialog at first startup.
#>
[CmdletBinding(SupportsShouldProcess)]
Param([switch]$Passthru)

$regPath = "HKCU:\Software\Sysinternals"
Set-ItemProperty -Path $regPath -Name "EulaAccepted" -Value 1 -Force
if ($Passthru) {
    Get-ItemProperty -Path $regPath -Name EulaAccepted
}