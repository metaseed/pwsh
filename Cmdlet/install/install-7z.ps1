
# Use the "/S" parameter to do a silent installation and the /D="C:\Program Files\7-Zip" parameter to specify the "output directory". These options are case-sensitive.
$content = iwr https://7-zip.org/download.html|select -ExpandProperty Content
$content -match 'href="(.+)">Download' > $null
$url = "https://7-zip.org/$($Matches[1])"
$output = "$env:temp\7-Zip.exe"
iwr $url -OutFile $output
& $output /S /D="$env:MS_App\7-Zip"

# https://sourceforge.net/p/sevenzip/discussion/45797/thread/8f5d0d78/#58e7/96fb
# https://kolbi.cz/blog/2017/10/25/setuserfta-userchoice-hash-defeated-set-file-type-associations-per-user/
# to get the list
# (cmd /C assoc |?{$_ -match '7-zip'}|%{($_ -split '=')[0].trim()}|get-unique|%{"'$_'"}) -join ','
$exts = @('.001','.7z','.apfs','.arj','.bz2','.bzip2','.cab','.cpio','.deb','.dmg','.esd','.fat','.gz','.gzip','.hfs','.iso','.lha','.lzh','.lzma','.ntfs','.rar','.rpm','.split','.squashfs','.swm','.tar','.taz','.tbz','.tbz2','.tgz','.tpz','.txz','.vhd','.vhdx','.wim','.xar','.xz','.z','.zi','.zip')
$exts |
% {
  cmd /C assoc "$_=7-Zip$_"
  cmd /C ftype "7-Zip$_=$env:ms_app\7-Zip\7zFM.exe"
}