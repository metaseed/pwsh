function global:__zoxide_query {
    zoxide query @args
}
Set-Alias -Name zz -Value __zoxide_query -Option AllScope -Scope Global -Force
