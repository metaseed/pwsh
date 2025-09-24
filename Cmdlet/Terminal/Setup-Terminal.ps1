# https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/CascadiaCode
Assert-Admin
# old way
# $CaskaydiaCoveNF = @(
#   # "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/CascadiaCode/Regular/complete/Caskaydia%20Cove%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible%20Italic.otf",
#   "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/CascadiaCode/CaskaydiaCoveNerdFontMono-Regular.ttf"
# )
# # Caskaydia Cove Nerd Font Complete Mono Windows
# Write-Step 'Downloading CaskaydiaCove NFM...'
# $CaskaydiaCoveNF |
# %{
#   $fi = Split-Path -Leaf $_
#   $fi = $fi -replace '%20', ' '
#   $path =  "$env:temp/$fi"
#   Write-Host "download to: $env:temp\$fi"
#   iwr $_ -OutFile $path
#   Write-Step 'Installing CaskaydiaCove NFM...'
#   Install-Font -Path $path -Scope User
# }

# & ([scriptblock]::Create((iwr 'https://to.loredo.me/Install-NerdFont.ps1'))) -Name hack, heavy-data
# it insatalled:
  # ✓ CaskaydiaCoveNerdFont-Bold.ttf
  # ✓ CaskaydiaCoveNerdFont-BoldItalic.ttf
  # ✓ CaskaydiaCoveNerdFont-ExtraLight.ttf
  # ✓ CaskaydiaCoveNerdFont-ExtraLightItalic.ttf
  # ✓ CaskaydiaCoveNerdFont-Italic.ttf
  # ✓ CaskaydiaCoveNerdFont-Light.ttf
  # ✓ CaskaydiaCoveNerdFont-LightItalic.ttf
  # ✓ CaskaydiaCoveNerdFont-Regular.ttf
  # ✓ CaskaydiaCoveNerdFont-SemiBold.ttf
  # ✓ CaskaydiaCoveNerdFont-SemiBoldItalic.ttf
  # ✓ CaskaydiaCoveNerdFont-SemiLight.ttf
  # ✓ CaskaydiaCoveNerdFont-SemiLightItalic.ttf
  # ✓ CaskaydiaCoveNerdFontMono-Bold.ttf
  # ✓ CaskaydiaCoveNerdFontMono-BoldItalic.ttf
  # ✓ CaskaydiaCoveNerdFontMono-ExtraLight.ttf
  # ✓ CaskaydiaCoveNerdFontMono-ExtraLightItalic.ttf
  # ✓ CaskaydiaCoveNerdFontMono-Italic.ttf
  # ✓ CaskaydiaCoveNerdFontMono-Light.ttf
  # ✓ CaskaydiaCoveNerdFontMono-LightItalic.ttf
  # *** ✓ CaskaydiaCoveNerdFontMono-Regular.ttf ***
  # ✓ CaskaydiaCoveNerdFontMono-SemiBold.ttf
  # ✓ CaskaydiaCoveNerdFontMono-SemiBoldItalic.ttf
  # ✓ CaskaydiaCoveNerdFontMono-SemiLight.ttf
  # ✓ CaskaydiaCoveNerdFontMono-SemiLightItalic.ttf
  # ✓ CaskaydiaCoveNerdFontPropo-Bold.ttf
  # ✓ CaskaydiaCoveNerdFontPropo-BoldItalic.ttf
  # ✓ CaskaydiaCoveNerdFontPropo-ExtraLight.ttf
  # ✓ CaskaydiaCoveNerdFontPropo-ExtraLightItalic.ttf
  # ✓ CaskaydiaCoveNerdFontPropo-Italic.ttf
  # ✓ CaskaydiaCoveNerdFontPropo-Light.ttf
  # ✓ CaskaydiaCoveNerdFontPropo-LightItalic.ttf
  # ✓ CaskaydiaCoveNerdFontPropo-Regular.ttf
  # ✓ CaskaydiaCoveNerdFontPropo-SemiBold.ttf
  # ✓ CaskaydiaCoveNerdFontPropo-SemiBoldItalic.ttf
  # ✓ CaskaydiaCoveNerdFontPropo-SemiLight.ttf
  # ✓ CaskaydiaCoveNerdFontPropo-SemiLightItalic.ttf
& ([scriptblock]::Create((iwr 'https://to.loredo.me/Install-NerdFont.ps1'))) -Name CaskaydiaCove Nerd Font


Restore-TerminalSetting -force

Pin-TaskBar "$env:MS_PWSH\Cmdlet\Terminal\WindowsTerminal.lnk" | Out-Null

# try later: https://stackoverflow.com/questions/75361094/starting-and-minimizing-quake-terminal-at-startup
# Note: not work when the shortcut in admin, if not in admin, the qake mode not work.
# $startup = [System.Environment]::GetFolderPath('startup')
#"$env:SystemDrive\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
# Copy-Item "$env:MS_PWSH\Cmdlet\Terminal\WindowsTerminal.lnk" $startup | Out-Null
# the same quake not work, the windows showed is default mode
# New-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run -Name WT -Value "wt.exe -w _quake"

# Note: to show font character in vscode
# `ctrl+,` to show the settings, search 'font', and in the 'Editor: Font Family' add the 'CaskaydiaCove NFM'

# todo: there is an official way of use pwsh to install it:
#     https://github.com/ryanoasis/nerd-fonts/tree/master?tab=readme-ov-file#option-5-powershell-web-installer