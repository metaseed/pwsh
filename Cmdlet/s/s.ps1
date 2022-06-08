[CmdletBinding()]
param (
    [Parameter()]
    [Alias('c')]
    [switch]$code
)

if($code){
  code $PSScriptRoot\..\..
}

# todo: setup git source and modify MS_PWSH profile