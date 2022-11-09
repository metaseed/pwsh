## PSFzf
https://github.com/kelleyma49/PSFzf
a-t: type a initial path, and press a-t, type something to search from the path
i.e. cd m:app(|cursor here) and then press a-t, type soft, <enter> <enter> cd to the software folder
a-h: find in history; type something and then c-r, press c-r again to toggle sort order (Invoke-FzfPsReadlineHandlerProvider)
a-a: find argument from history

fe directory: find file/folder from the dir and edit
fh: read historySavePath file
Note: a-h accepts an initial path

fkill: fast kill process
fd: fast set directory
cde: cd with everything db
cdz: fast set location with zlocation db

| Command | Notes |
|---------|-------|
| `git`   | Uses [`posh-git`](https://github.com/dahlbyk/posh-git) for providing tab completion options. Requires at least version 1.0.0 Beta 4.
| `Get-Service`, `Start-Service`, `Stop-Service` | Allows the user to select between the installed services.
| `Get-Process`, `Start-Process` | Allows the user to select between running processes.