[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $user
)

if($user) {
  certmgr.msc
} else {
  certlm.msc
}