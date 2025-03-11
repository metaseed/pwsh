# make and change directory
# sl: change to the location
# sln: change to the location, if not exist, create new dir
function Set-LocationNew {
    [CmdletBinding()]
    [alias("sln")]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Path,
        [switch]
        [alias('f')]
        $Force
    )
    # mkdir path
    $dirExist = Test-Path $Path -PathType Container
    $newDir = { New-Item -ItemType Directory -Path $Path -ErrorAction Stop }

    if ($dirExist) {
        if ($Force) {
            Remove-Item -Path $Path -Force -recurse
            New-Item -ItemType Directory -Force -Path $Path -ErrorAction Stop
        }
    }
    else {
        &$newDir
    }

    # cd path
    Set-Location -Path $Path
}
