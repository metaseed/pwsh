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
        if( $ver_online -match '^\d+$' ) {
          $ver_online = [Version]::new($matches[0] + '.0')
          Write-Verbose "online ver: $ver_online"
        } else {
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
      [CmdletBinding()]
      param()

      $appName = $application -eq '' ? $repo : $application
      $versionLocal = $null
      $it = @(gci $toLocation -Filter "$appName*")
      if ($it) {
        # Write-Host $it
        if ($it.count -gt 1) {
          write-error "find more than one dir/file in $toLocation : $($it.name) "
          break
        }

        $dir = $it[0]
        $versionRegex = "(\d+\.\d+\.?\d*\.?\d*)"
        Write-host "dir/file name: $($dir.name)"
        if ($dir.Name -match $versionRegex) {
          Write-Verbose "query local version via dir/file name: $($dir.name)"
          $versionLocal = [Version]::new($matches[1])
        }
        else {
          write-Host "no version info in directory name: $($dir.name)"
        }
      }

      if (!$versionLocal) {
        $p = "$toLocation\$appName*\$appName*.exe"
        if (!(test-path $p)) {
          $p = "$toLocation\$appName*.exe"
        }
        Write-Verbose  "query version: $p"
        $it = @(gi $p -ErrorAction SilentlyContinue)
        if ($it) {
          if ($it.count -gt 1) {
            write-error "find more than one dir/file in $toLocation : $($it.name) "
            break
          }
          try {
            Write-Verbose "query local version via 'gcm' $($it[0])"
            $cmd = gcm "$($it[0])"
            $versionLocal = [Version]::new($cmd.version)
          }
          catch {
            try {
              $it.VersionInfo.FileVersion -match "^[\d\.]+" > $null
              Write-Verbose "query local version via FileVersion property"
              $versionLocal = [Version]::new($matches[0])
            }
            catch {
              Write-Verbose "query local version via ProductVersion property"
              $it.VersionInfo.ProductVersion -match "^[\d\.]+" > $null
              $versionLocal = [Version]::new($matches[0])
            }
          }
        }
      }
      if ($it) {
      if(!$versionLocal) {
        $dir = $it[0]
        if ($dir.Name -match '__\d+\.\d+') {
          Write-Verbose "query local version via dir/file name: $($dir.name)"
          $versionLocal = [Version]::new($matches[0])
        }
      }
    }
      # write-host $versionLocal.gettype()
      return $versionLocal
    },
    [Parameter()]
    [scriptblock]$installScript = {
      [CmdletBinding()]
      param($downloadedFilePath, $ver_online)
      Write-Host "Install..."
      Write-Host $downloadedFilePath
      $appName = $application -eq '' ? $repo : $application
      # ignore error, may not exist
      ri "$env:temp\temp" -Force -Recurse -ErrorAction Ignore
      # write-host $appName
      gci $toLocation -Filter "$appName*" |
      Remove-Item -Recurse -Force

      if ($downloadedFilePath -match '\.exe$') {
        Move-Item "$_" -Destination $toLocation -Force
        return $toLocation
      }
      else {
        Write-Action "expand archive to $env:temp\temp..."
        if ($downloadedFilePath -match '\.zip|\.zipx|\.7z|\.rar') {
          Expand-Archive $downloadedFilePath -DestinationPath "$env:temp\temp"
        }
        elseif ($downloadedFilePath -match '\.tar\.gz') {
          if (!(test-path $env:temp\temp)) {
            ni $env:temp\temp -ItemType Directory
          }
          tar -xf $downloadedFilePath -C "$env:temp\temp"
        }
        else {
          write-error "$downloadedFilePath is not a know copressed archive!"
          break
        }

        $children = @(gci "$env:temp\temp")
        if ($children.count -ne 1 -or $toFolder) {
          Move-Item "$env:temp\temp" -Destination "$toLocation\${repo}__${ver_online}"
          return "$toLocation\${repo}_${ver_online}"
        }
        else {
          $children | Move-Item -Destination $toLocation -Force
          ri "$env:temp\temp" -Force
          return "$toLocation"
        }
      }
    },
    # force reinstall
    [Parameter()]
    [switch]$Force
  )
  Assert-Admin

  if($org.Contains('/')) {
    $v = $org.Split('/')
    $org =$v[0]
    $repo = $v[1]
  }
  Write-Host "$org $repo"
  $appPath = $null

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

      $versionLocal = Invoke-Command -ScriptBlock $getLocalVerScript
      # Write-Host "dd" + $versionLocal.gettype()
      if (!$versionLocal) {
        Write-Host "$repo is not installed, try to install the latest ${repo}: $ver_online"
      }
      else {

        if ($ver_online -le $versionLocal) {
          Write-Host "You are using the latest version of $repo.`n $versionLocal is the latest version available."
          if (!$force) {
            break
          }
          Write-Warning "Forcely install the latest version..."
        }
        write-host "You are using $repo $versionLocal.`n The latest version is $ver_online."
      }
      return $_
    } |
    Download-GithubRelease |
    % {
      $path = $_
      $des = Invoke-Command -ScriptBlock $installScript -ArgumentList "$path", "$ver_online"
      write-host "app installed to $path"
      $appPath = $des
    }
  }
  return $appPath
}