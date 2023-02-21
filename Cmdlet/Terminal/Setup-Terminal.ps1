# https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/CascadiaCode
Assert-Admin

$CaskaydiaCoveNF = @(
  # "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/CascadiaCode/Regular/complete/Caskaydia%20Cove%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible%20Italic.otf",
  "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/CascadiaCode/Regular/complete/Caskaydia%20Cove%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible%20Regular.otf"
)
# Caskaydia Cove Nerd Font Complete Mono Windows
Write-Step 'Downloading CaskaydiaCoveNFM...'
$CaskaydiaCoveNF |
%{
  $fi = Split-Path -Leaf $_
  $fi = $fi -replace '%20', ''
  $path =  "$env:temp/$fi"
  Write-Host "download to: $env:temp\$fi"
  iwr $_ -OutFile $path
  Write-Step 'Installing CaskaydiaCoveNF...'
  Install-Font -Path $path
}
Restore-TerminalSetting -force

Pin-TaskBar "$env:MS_PWSH\Cmdlet\Terminal\WindowsTerminal.lnk" | Out-Null
# not work when the shortcut in admin, if not in admin, the qake mode not work.
# $startup = [System.Environment]::GetFolderPath('startup') #"$env:SystemDrive\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
# Copy-Item "$env:MS_PWSH\Cmdlet\Terminal\WindowsTerminal.lnk" $startup | Out-Null
# the same quake not work, the windows showed is default mode
# New-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run -Name WT -Value "wt.exe -w _quake"