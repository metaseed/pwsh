[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$zip = "temp:pwsh.zip"
iwr 'http://github.com/metasong/pwsh/archive/refs/heads/master.zip' -OutFile $zip

$path = [System.Environment]::GetEnvironmentVariable('PWSH_PATH', 'User')
if(!$path) {
    $path = "$(resolve-path ~)\metaseed\pwsh"
    [System.Environment]::SetEnvironmentVariable('PWSH_PATH', $path , 'User')
}
# ~ is better than $env:HomePath, it include the home drive
Expand-Archive $zip "$path/../" -Force

# directly ri the pwsh folder may cause error if it is used.
# mi works even file is used
# but mi would show error is des exists: because a file or directory with the same name already exists.
# the .pwsh-del shouldn't be used/locked by any app
ri "$path/../.pwsh-del" -Force -Recurse -ErrorAction SilentlyContinue
mi "$path/../pwsh" "$path/../.pwsh-del" -Force -ErrorAction SilentlyContinue
ri "$path/../.pwsh-del" -Force -Recurse -ErrorAction SilentlyContinue

mi "$path/../pwsh-master" "$path/../pwsh" -Force
. "$path/../pwsh/set-profile.ps1"