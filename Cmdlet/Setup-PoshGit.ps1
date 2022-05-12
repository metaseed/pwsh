Import-Module posh-git -ErrorAction SilentlyContinue

if($?) {
  "update posh-git..."
  PowerShellGet\Update-Module posh-git
} else {
  "install posh-git..."
  PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
}