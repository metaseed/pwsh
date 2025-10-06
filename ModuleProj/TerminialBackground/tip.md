## Build the release:
to build to release:
comment out: . $PSScriptRoot\profile\main.ps1 in Pwsh\profile.ps1
spps -n TerminalBackground, pwsh
so the 'M:\Script\Pwsh\Module\Metaseed.Terminal\_bin\TerminalBackground.dll' is not loaded by any pwsh process
then we can build the release with by open a pwsh window:
dotnet build -c release
then remove the comment out and run:
spps -n TerminalBackground, pwsh
then we can  run:
Show-WTBackgroundImage success

## view the logs:

gi $env:temp\TerminalBackground*.txt
if there is only one,
we can run:
code ($env:temp\TerminalBackground*.txt)