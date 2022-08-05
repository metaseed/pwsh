$url = "https://download.videolan.org/pub/videolan/vlc/last/win64/"
$page = Invoke-RestMethod $url

$page -match 'href="(vlc-.+.win64.7z)"' > $null
$url += $Matches[1]
$output = "$env:TEMP\$($Matches[1])"
Write-step "downloading from: $url, to $output"
iwr $url -OutFile $output
gi $env:MS_App\vlc-* | rm -Recurse -Force

7z.exe x $output -o"$env:ms_app"