function Install-FromGithub {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]$url,

		# regex to filter out the file from resource names
		[Parameter(Mandatory = $true)]
		[string]$filter, # = '-windows\.zip$', # '(?<!\.Light).Portable.x64.zip$'
		# version type: stable or preview
		[Parameter()]
		[string]
		[ValidateSet('preview', 'stable')]
		$versionType = 'stable',

		# put the app in the a folder(with version) even if it's a single exe file
		[switch]$toFolder,
		# app name, if repo name is not the same as app name
		[Parameter()]
		[string]$application = '',
		# where to unzip/install the app
		[Parameter()]
		[string]$toLocation = $env:MS_App,
		# scriptblock to get the online app version
		[Parameter()]
		[scriptblock]$getOnlineVer = {
			[CmdletBinding()]
			param($name, $tag_name)
			# $versionRegex = "_(\d+\.\d+\.?\d*\.*\d*)_x64"
			# $_.name -match $versionRegex >$null
			# $ver_online = [Version]::new($matches[1])
			$ver_online = $tag_name.trim('v', 'e', 'r')
			try {
				if ( $ver_online -match '^\d+$' ) {
					$ver_online = [Version]::new($matches[0] + '.0')
					Write-Verbose "online ver: $ver_online"
				}
				else {
					$ver_online = [Version]::new($ver_online)
				}
			}
			catch {
				$versionRegex = "(\d+\.\d+\.?\d*\.?\d*)"
				# 1.77.3.
				Write-Verbose $name
				$r = $name -match $versionRegex #>$null
				if($r) {
					$ver_online = [Version]::new($matches[1].TrimEnd('.'))
				} else {
					write-error "'$name' can not match '$versionRegex'"
				}
			}
			$ver_online
		},
		# scriptblock to get local installed app version
		# the folder is where app.exe or app folder located
		# return @{ver = $versionLocal; folder = $appFolder; }
		[Parameter()]
		[scriptblock]$getLocalInfoScript = {
			param()
			$appName = $application -eq '' ? $repo : $application
			if (!$toLocation) { $toLocation = $env:MS_App } # default value on $toLocation not work
			Write-Verbose "getLocalInfoScript tolocaltion: $toLocation"
			$rt = Get-LocalAppInfo $appName $toLocation $newName
			# $folder = $rt.folder
			return $rt
		},
		[Parameter()]
		[scriptblock]$installScript = {
			param($downloadedFilePath, $ver_online, $toFolder, $newName, $verLocal)

			$appName = $application -eq '' ? $repo : $application
			if ($newName) {
				Write-Host "new name: $newName"
			}
			$r = Install-App $downloadedFilePath $ver_online $appName $toFolder -newName $newName -verLocal $verLocal -pickExes: $pickExes -restoreList $restoreList
			return $r
		},
		# force reinstall
		[Parameter()]
		[switch]$Force,
		[Parameter()]
		[string]$newName,
		[switch] $pickExes,
		# folders or files in toLocation to backup and restore
		[string[]]$restoreList = @('_')
	)
	Assert-Admin
	$v = $url.Split('/')
	$org = $v[-2]
	$repo = $v[-1]

	Write-Host "$org $repo $newName"
	$appPath = $null

	$Folder = $null
	$ver_online = $null
	$versionLocal = $null
	Breakable-Pipeline {
		$ver_online = [version]::new();

		Get-GithubRelease -OrgName $org -RepoName $repo -Version $versionType -fileNamePattern $filter |
		% {
			$assets = $_
			if ($assets.Count -ne 1 ) {
				 Write-Error "Expected one asset, but found $($assets.Count)"
				break;
			}
			Write-Verbose "$_"

			$ver_online = Invoke-Command -ScriptBlock $getOnlineVer -ArgumentList $_.name, $_.tag_name

			$localInfo = Invoke-Command -ScriptBlock $getLocalInfoScript

			$versionLocal = $localInfo.ver
			$Folder = $localInfo['folder']
			$r = Test-AppInstallation $repo $versionLocal $ver_online -force:$force
			if (!$r) {
				Write-Verbose "Online and local version is the same, no need to install!"
				break Script
			}
			return $_
		} |
		Download-GithubRelease |
		% {
			$path = $_
			$Folder ??= $env:MS_App
			$des = Invoke-Command -ScriptBlock $installScript -ArgumentList "$path", "$ver_online", $Folder, $newName, $versionLocal
			write-host "app installed to $des"
			$appPath = $des
		}
	}
	return @{dir = $appPath; ver = $ver_online }
}