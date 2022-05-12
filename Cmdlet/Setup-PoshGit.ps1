# with the empty CmdletBinding attribute, -Verbose parameter could be used to show more information.
[CmdletBinding()]
param (  
)

Import-Module posh-git -ErrorAction SilentlyContinue

if($?) {
  "update posh-git..."
  PowerShellGet\Update-Module posh-git
  "update posh-git done"
} else {
  "install posh-git..."
  PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
  "install posh-git done"
}