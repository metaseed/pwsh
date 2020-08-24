function sudo {
    Start-Process -Verb RunAs -FilePath "pwsh" -ArgumentList (@("-NoExit", "-Command") + $args)
}

function mcd {
    [CmdletBinding()]
    param(
       [Parameter(Mandatory = $true)]
       $Path
    )
 
    # mkdir path
    New-Item -Path $Path -ItemType Directory
    # cd path
    Set-Location -Path $Path
 }