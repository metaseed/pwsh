ipmo metaseed.management -fo;
$info = Install-FromGithub https://github.com/junegunn/fzf 'windows_amd64\.zip$' -versionType 'preview' -force # -toFolder
Set-EnvVar FZF_DEFAULT_COMMAND 'fd --type f --type d --hidden'