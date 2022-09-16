#set global EULA acceptance for SysInternals tools

[CmdletBinding(SupportsShouldProcess)]
Param([switch]$Passthru)

$regPath = "HKCU:\Software\Sysinternals"
Set-ItemProperty -Path $regPath -Name "EulaAccepted" -Value 1 -Force
if ($Passthru) {
    Get-ItemProperty -Path $regPath -Name EulaAccepted
}