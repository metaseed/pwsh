$zip = "temp:pwsh.zip"
iwr 'http://github.com/metasong/pwsh/archive/refs/heads/master.zip' -OutFile $zip

# ~ is better than $env:HomePath, it include the home drive
Expand-Archive $zip ~/metaseed -Force

# directly ri the pwsh folder may cause error if it is used.
# mi works even file is used
# but mi would show error is des exists: because a file or directory with the same name already exists.
# the .old shouldn't be used/locked by any app
ri ~/metaseed/.old -Force -Recurse -ErrorAction SilentlyContinue
mi ~/metaseed/pwsh ~/metaseed/.old -Force -ErrorAction SilentlyContinue
ri ~/metaseed/.old -Force -Recurse -ErrorAction SilentlyContinue

mi ~/metaseed/pwsh-master ~/metaseed/pwsh -Force
. ~/metaseed/pwsh/set-profile.ps1