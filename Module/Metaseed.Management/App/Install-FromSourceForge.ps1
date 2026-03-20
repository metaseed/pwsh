function Install-FromSourceForge {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]$project,

		# wildcard pattern to match the file from RSS feed titles (used with -like)
		[Parameter(Mandatory = $true)]
		[string]$filePattern,

		# force reinstall
		[Parameter()]
		[switch]$Force,

		# where to unzip/install the app
		[Parameter()]
		[string]$toLocation = $env:MS_App,

		[Parameter()]
		[string]$newName,

		# just pickup the files from downloaded files in zip, not folders
		[string[]]$filesToPickup,

		# folders or files in toLocation to backup and restore
		[string[]]$restoreList = @('_'),

		[switch]$CreateFolder
	)

	Assert-Admin
	if (!$toLocation) { $toLocation = $env:MS_App }

	$rssUrl = "https://sourceforge.net/projects/$project/rss?path=/"
	$rss = [xml](Invoke-WebRequest -Uri $rssUrl -UseBasicParsing)

	$item = $rss.rss.channel.item | Where-Object { $_.title.InnerText -like $filePattern } | Select-Object -First 1
	if (!$item) {
		Write-Error "No file matching pattern '$filePattern' found in SourceForge project '$project'"
		return
	}

	$downloadUrl = $item.link
	# SourceForge URLs end with /download, strip it to get the real filename
	$localPath = ([Uri]$downloadUrl).LocalPath -replace '/download$', ''
	$fileName = [IO.Path]::GetFileName($localPath)
	$fileNameWithoutExt = [IO.Path]::GetFileNameWithoutExtension($fileName)

	Write-Host "Downloading: $downloadUrl"

	# extract version
	$verOnline = Get-VersionFromString $fileNameWithoutExt
	if (!$verOnline) {
		$verOnline = [Version](Read-Host "Please input the version of the online app (e.g. 1.0.0)")
	}

	$name = $newName ? $newName : $project

	# check local version
	$localInfo = Get-LocalAppInfo $name $toLocation $newName
	$verLocal = $localInfo.ver
	if ($verLocal) {
		$isInstall = Test-AppInstallation $name $verLocal $verOnline -force:$Force
		if (!$isInstall) {
			Write-Notice "No install action!"
			return
		}
	}

	# download - SourceForge /download pages use JS redirects, so parse the actual mirror URL
	$html = (Invoke-WebRequest -Uri $downloadUrl -UserAgent "Mozilla/5.0").Content
	if ($html -match 'https://downloads\.sourceforge\.net/[^\s"<>]+') {
		$directUrl = [System.Web.HttpUtility]::HtmlDecode($Matches[0])
	} else {
		$directUrl = $downloadUrl
	}
	Write-Host "Direct URL: $directUrl"

	$tempPath = "$env:temp\$name"
	if (!(Test-Path $tempPath)) {
		New-Item -ItemType Directory $tempPath > $null
	}
	$downloadedFilePath = Join-Path $tempPath $fileName
	Invoke-WebRequest -Uri $directUrl -OutFile $downloadedFilePath

	# install
	$des = Install-App $downloadedFilePath $verOnline $name $toLocation -filesToPickup $filesToPickup -restoreList $restoreList -CreateFolder:$CreateFolder -verLocal $verLocal
	Write-Host "the $name app has been installed to $des"
	return @{dir = $des; ver = $verOnline }
}
