function Install-FromWeb {
	[CmdletBinding()]
	param (
		# url of web page to find the file to download
		[Parameter(Mandatory = $true)]
		[ValidatePattern("^(https?|ftp)://[^\s/$.?#].[^\s]*$")]
		[string]$url,

		# filter pattern to find the url of the file to download from the page, note the first group is the url
		# i.e. '<a .*href="(.*)".*>\s*Download Portable Zip 64-bit'
		[Parameter()]
		[string]
		$filter,

		# force reinstall
		[Parameter()]
		[switch]$Force,
		# where to unzip/install the app
		[Parameter()]
		[string]$toLocation = $env:MS_App,

		# backup
		[Parameter()]
		[scriptblock]
		$preInstallScript = {
			param($name, $localInfo)
		},

		# restore
		[Parameter()]
		[scriptblock]
		$postInstallScript = {
			param($name, $localInfo, $toLocation)

		},

		# whether to create a subfolder with the name
		[Parameter()]
		[switch]
		$CreateFolder,

		[Parameter()]
		[string]$newName,

		# just pickup the files from downloaded files in zip, not folders
		[string[]]$filesToPickup,
		# folders or files in toLocation to backup and restore
		[string[]]$restoreList = @('_')
	)

	# spps -n -errorAction ignore
	$res = iwr $url

	if ($res.Content -match $filter) {
		## get url from the filter
		$fileUrl = $Matches[1]
		$fileNameWithVer = [IO.Path]::GetFileNameWithoutExtension($fileUrl)


		if ($fileUrl.startsWith('/')) {
			$uri = [System.Uri]$url
			$baseUrl = "$($uri.Scheme)://$($uri.Host)"
			$fileUrl = "$baseUrl$fileUrl"
		}

		## find ver from file name in url
		if ($fileNameWithVer -match '\d+\.\d+\.?\d*\.?\d*') {
			$verOnline = $Matches[0]
		}
		$nameFromOnline = $fileNameWithVer -replace '(\.|-|_|_v|-v|_version|ver)\d+(\.\d+)*.*', ''
		$name = ($newName) ?? $nameFromOnline
		if (!$verOnline) {
			$verOnline = ReadHost "please input the version of the online app (i.e. 1.0.0)"
		}
		$verOnline = [Version]$verOnline

		## local version
		$localInfo = Get-LocalAppInfo $name $toLocation
		$verLocal = $localInfo.ver
		# installed locally
		$isInstall = $true
		if ($verLocal) {
			$isInstall = Test-AppInstallation $name $verLocal $verOnline -force:$force
			$name = split-path $localInfo.folder -Leaf
			$newName = $newName ?? $name
		}

		if (!$isInstall) {
			Write-Notice "no install action!"
			return
		}
		## download
		$tempPath = "$env:temp\$name"
		if(!(Test-Path $tempPath)) {
			ni -ItemType Directory $tempPath > $null
		}
		$downloadedFilePath= Join-Path $tempPath ([IO.Path]::GetFileName($fileUrl))
		iwr $fileUrl -out $downloadedFilePath

		## install
		if ($preInstallScript) {
			Invoke-Command -ScriptBlock $preInstallScript -ArgumentList $name, $localInfo
		}

		$localFolder = $toLocation ?? $env:MS_App
		$toLocation = install-app $downloadedFilePath $verOnline $name $localFolder -filesToPickup $filesToPickup -restoreList $restoreList -verLocal $verLocal -CreateFolder:$CreateFolder $newName

		if ($postInstallScript) {
			Invoke-Command -ScriptBlock $postInstallScript -ArgumentList $name, $localInfo, $toLocation
		}
	}
	else {
		write-error 'can not parse the returned html to find the download file url with the filter:' + $filter
	}
}
