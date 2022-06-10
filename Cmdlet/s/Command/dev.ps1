# todo: setup git source and modify MS_PWSH profile .local file
$root =  "$__CmdFolder/../../../"
. "$root/config.ps1"
if(! (test-path "$root/.local")){
  write-host "creating .local file"
  New-Item -itemtype file -Force -Path "$root/.local" | Out-Null
}