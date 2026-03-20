Install-FromWeb -url 'https://7-zip.org/download.html' `
  -filter 'href="(.+)">Download' `
  -newName '7-Zip' `
  -getOnlineVer {
		param($fileNameWithVer)
		# 7z2600-x64 → version 26.00
		if ($fileNameWithVer -match '7z(\d{2})(\d{2})') {
    return [Version]::new("$([int]$Matches[1]).$([int]$Matches[2])")
		}
  } `
  -installScript {
		param($downloadedFilePath, $verOnline, $name, $localFolder, $verLocal)
		$installDir = "$localFolder\$name"
		Write-Host "Installing $name v$verOnline to $installDir"
    # Use the "/S" parameter to do a silent installation and the /D parameter to specify the "output directory". These options are case-sensitive.
		Start-Process -FilePath $downloadedFilePath -ArgumentList '/S', "/D=$installDir" -Wait
		Remove-Item $downloadedFilePath -Force -ErrorAction Ignore
		@{version = "$verOnline" } | ConvertTo-Json | Set-Content -Path "$installDir\info.json" -Force
		return $installDir
  } `
  -postInstallScript {
		param($name, $localInfo, $toLocation)
		# https://sourceforge.net/p/sevenzip/discussion/45797/thread/8f5d0d78/#58e7/96fb
		# https://kolbi.cz/blog/2017/10/25/setuserfta-userchoice-hash-defeated-set-file-type-associations-per-user/
		# to get the list
		# (cmd /C assoc |?{$_ -match '7-zip'}|%{($_ -split '=')[0].trim()}|get-unique|%{"'$_'"}) -join ','
		$exts = @('.001', '.7z', '.apfs', '.arj', '.bz2', '.bzip2', '.cab', '.cpio', '.deb', '.dmg', '.esd', '.fat', '.gz', '.gzip', '.hfs', '.iso', '.lha', '.lzh', '.lzma', '.ntfs', '.rar', '.rpm', '.split', '.squashfs', '.swm', '.tar', '.taz', '.tbz', '.tbz2', '.tgz', '.tpz', '.txz', '.vhd', '.vhdx', '.wim', '.xar', '.xz', '.z', '.zi', '.zip')
		$exts | % {
    cmd /C assoc "$_=7-Zip$_"
    cmd /C ftype "7-Zip$_=$env:ms_app\7-Zip\7zFM.exe"
		}
		Add-PathEnv 'C:\App\7-Zip'
} @args
