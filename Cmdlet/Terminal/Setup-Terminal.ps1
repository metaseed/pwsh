# https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/CascadiaCode
$CaskaydiaCoveNF = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/CascadiaCode/Regular/complete/Caskaydia%20Cove%20Regular%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible.otf"
$path = "$env:temp/CaskaydiaCoveNF.otf"
Write-Step 'Downloading CaskaydiaCoveNF...'
iwr $CaskaydiaCoveNF -OutFile $path
Write-Step 'Installing CaskaydiaCoveNF...'

Install-Font -Path $path
