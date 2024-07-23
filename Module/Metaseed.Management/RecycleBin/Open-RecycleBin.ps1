
function open-recycleBin {
    [CmdletBinding()]
    [alias('orb')]
    param (
    )
    start shell:RecycleBinFolder
}

Set-Alias crb Clear-RecycleBin
# CommandType     Name                                               Version    Source
# -----------     ----                                               -------    ------
# Cmdlet          Clear-RecycleBin                                   7.0.0.0    Microsoft.PowerShell.Management