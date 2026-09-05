
# List all the paths that are excluded from Windows Defender scans.
# Note: Get-MpPreference cmdlet is part of the Windows Defender module, which provides various functionalities to manage and configure Windows Defender settings.
# Mp: Malware Protection (points directly to Windows Defender).
# Devide the result into two parts:
# 1. Files ($false)
# 2. Directories ($true)
# Then sort within each group by length (longest first, shortest at last)
$paths =
    Get-MpPreference |
        Select-Object -ExpandProperty ExclusionPath |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

$items = for ($i = 0; $i -lt $paths.Count; $i++) {
    $p = $paths[$i].Trim()

    # Avoid filesystem probing: Defender exclusions often don't exist locally,
    # may contain wildcards, and may include environment variables.
    $leaf = Split-Path -Path $p -Leaf
    $isDirectory =
        ($p -match '[\\/]\s*$') -or
        ([string]::IsNullOrEmpty($leaf)) -or
        ([string]::IsNullOrEmpty([System.IO.Path]::GetExtension($leaf)))

    [pscustomobject]@{
        Index       = $i
        Path        = $p
        IsDirectory = $isDirectory
        Length      = $p.Length
    }
}

$items |
    Sort-Object -Property @(
        # Part 1: Separate Files ($false) from Directories ($true)
        @{ Expression = { $_.IsDirectory }; Descending = $false },

        # Part 2: Sort within each group by length (longest first, shortest at last)
        @{ Expression = { $_.Length }; Descending = $true },

        # Part 3: Stable output (preserve original order for ties)
        @{ Expression = { $_.Index }; Descending = $false }
    ) |
    Select-Object -ExpandProperty Path
    # Select-Object {"$($_.Path), $($_.IsDirectory ? 'dir' : 'file')"}

# $paths.count
# $items.length