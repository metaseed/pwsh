$url = "https://download.videolan.org/pub/videolan/vlc/last/win64/"
$page = Invoke-RestMethod $url

$page -match 'href="(vlc-.+.win64.7z)"' > $null
$url += $Matches[1]

iwr $url -OutFile "$env:TEMP\$($Matches[1])"

