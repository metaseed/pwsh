function Install-FromGithub {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    # ornization name on github
    [string]$org,
    # repo name on github
    [Parameter()]
    [string]$repo,
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
    $toLocation = $env:MS_App,
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
        Write-Verbose $name
        $name -match $versionRegex >$null
        $ver_online = [Version]::new($matches[1])
      }
      $ver_online
    },
    # scriptblock to get local installed app version
    # output: [Version] or $null if not installed
    [Parameter()]
    [scriptblock]$getLocalVerScript = {
      $appName = $application -eq '' ? $repo : $application
      $rt = Get-LocalAppInfo $appName $toLocation
      # $folder = $rt.folder
      return $rt
    },
    [Parameter()]
    [scriptblock]$installScript = {
      param($downloadedFilePath, $ver_online, $toFolder)
      $appName = $application -eq '' ? $repo : $application
      Install-App $downloadedFilePath $ver_online $appName $toFolder
    },
    # force reinstall
    [Parameter()]
    [switch]$Force
  )
  Assert-Admin

  if ($org.Contains('/')) {
    $v = $org.Split('/')
    $org = $v[0]
    $repo = $v[1]
  }
  Write-Host "$org $repo"
  $appPath = $null

  $Folder = $null
  Breakable-Pipeline {
    $ver_online = [version]::new();
    Get-GithubRelease -OrgName $org -RepoName $repo -Version $versionType -fileNamePattern $filter |
    % {
      $assets = $_
      if ($assets.Count -ne 1 ) {
        foreach ($asset in $assets) {
          Write-Warning $asset.name
        }
        Write-Error "Expected one asset, but found $($assets.Count), please make the filer more specific!"
        break;
      }
      Write-Verbose "$_"

      $ver_online = Invoke-Command -ScriptBlock $getOnlineVer -ArgumentList $_.name, $_.tag_name

      $localInfo= Invoke-Command -ScriptBlock $getLocalVerScript
      $versionLocal = $localInfo.ver
      $Folder = $localInfo.folder
      $r = Test-AppInstallation $repo $versionLocal $ver_online -force:$force
      if(!$r) {
        break
      }
      return $_
    } |
    Download-GithubRelease |
    % {
      $path = $_
      $Folder ??= $env:MS_App
      $des = Invoke-Command -ScriptBlock $installScript -ArgumentList "$path", "$ver_online", $Folder, $toFolder
      write-host "app installed to $path"
      $appPath = $des
    }
  }
  return $appPath
}