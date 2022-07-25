# https://github.com/chubin/wttr.in
<#
.EXAMPLE
weather
weather laizhou
weather -o -m
weather -v1
#>
[CmdletBinding()]
param (
    # city, a mountain name, or some special location.
    # or 3-letter airport codes
    # if not set: current location
    # we always add '~' berfore location to search
    # append '?m' to use metric unit
    [string]
    $Location,
    [switch]$v1,
    [switch]$metric,
    [switch]$OneLine,
    # only for v2
    [switch]$emoji,
    [switch]$help
)
if($help) {
  Invoke-RestMethod "https://wttr.in/:help"
  return
}

$query = "?$($metric ? 'm': '')$($OneLine ? '&format=4': '')"
if($query -eq '?') {$query = ''}
$location = ($Location -like '*~*') ? $location : "~$location"
$url =  "https://$($v1 ? '' : $emoji ? 'v2.' : 'v2d.')wttr.in/$Location$query"

$invoke =  "Invoke-RestMethod `"$url`""
Write-Verbose $invoke
try {
Invoke-RestMethod $url
} catch {
  $_
  write-error $invoke
}

# (iwr https://wttr.in/).content > $env:TEMP\weather.txt