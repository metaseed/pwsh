function sudo {
    Start-Process -Verb RunAs -FilePath "pwsh" -ArgumentList (@("-NoExit", "-Command") + $args)
}

# make and change directory
function mcd {
    [CmdletBinding()]
    param(
       [Parameter(Mandatory = $true)]
       [string]
       $Path
    )

    # mkdir path
    New-Item -Path $Path -ItemType Directory
    # cd path
    Set-Location -Path $Path
 }