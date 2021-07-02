$zip = "temp:pwsh.zip"
iwr 'http://github.com/metasong/pwsh/archive/refs/heads/master.zip' -OutFile $zip
Expand-Archive $zip ~/metaseed
mi ~/metaseed/pwsh-master ~/metaseed/pwsh

. ~/metaseed/pwsh/set-profile.ps1