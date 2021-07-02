[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$zip = "temp:pwsh.zip"
iwr 'http://github.com/metasong/pwsh/archive/refs/heads/master.zip' -OutFile $zip

# ~ is better than $env:HomePath, it include the home drive
Expand-Archive $zip ~/metaseed -Force

# directly ri the pwsh folder may cause error if it is used.
# mi works even file is used
# but mi would show error is des exists: because a file or directory with the same name already exists.
# the .ms_pwsh-del shouldn't be used/locked by any app
ri ~/metaseed/.ms_pwsh-del -Force -Recurse -ErrorAction SilentlyContinue
mi ~/metaseed/ms_pwsh ~/metaseed/.ms_pwsh-del -Force -ErrorAction SilentlyContinue
ri ~/metaseed/.ms_pwsh-del -Force -Recurse -ErrorAction SilentlyContinue

mi ~/metaseed/pwsh-master ~/metaseed/ms_pwsh -Force
. ~/metaseed/ms_pwsh/set-profile.ps1
