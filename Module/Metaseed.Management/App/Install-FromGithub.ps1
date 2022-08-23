function Install-FromGithub {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    # ornization name on github
    $org,
    # repo name on github
    [Parameter(Mandatory = $true)]
    $repo,
    # regex to filter out the file from resource names
    [Parameter(Mandatory = $true)]
    $filter, # = '-windows\.zip$', # '(?<!\.Light).Portable.x64.zip$'
    # version type: stable or preview
    [Parameter()]
    [string]
    [ValidateSet('preview', 'stable')]
    $versionType = 'stable',

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
      try{
        $ver_online = [Version]::new($ver_online)
      }catch {
        $versionRegex = "(\d+\.\d+\.?\d*\.?\d*)"
        Write-Verbose $name
        $name -match $versionRegex >$null
        $ver_online = [Version]::new($matches[1])
      }
      $ver_online
    },
    # scriptblock to get local installed app version
    [Parameter()]
    [scriptblock]$getLocalVer = {
      [CmdletBinding()]
      param()
      $appName = $application -eq '' ? $repo : $application
      $p = "$toLocation\$appName*\$appName*.exe"
      if (!(test-path $p)) {
        $p = "$toLocation\$appName*.exe"
      }
      Write-Verbose  "query version: $p"
      $it = gi $p -ErrorAction SilentlyContinue
      if ($it) {
        if ($it.count -gt 1) {
          write-error "find more than one dir/file in $toLocation : $($it.name) "
          break
        }
        try {
          $cmd = gcm "$($it[0])"
          $versionLocal = [Version]::new($cmd.version)
        }
        catch {
          try {
            $it.VersionInfo.FileVersion -match "^[\d\.]+" > $null
            $versionLocal = [Version]::new($matches[0])
          }
          catch {
            $it.VersionInfo.ProductVersion -match "^[\d\.]+" > $null
            $versionLocal = [Version]::new($matches[0])
          }
        }
      }
      if (!$versionLocal) {
        $it = gci $toLocation -Filter "$appName*"
        if ($it) {
          if ($it.count -gt 1) {
            write-error "find more than one dir/file in $toLocation : $($it.name) "
            break
          }

          $dir = $it[0]
          $versionRegex = "(\d+\.\d+\.?\d*\.?\d*)"
          Write-host "dir/file name: $($dir.name)"
          if ($dir.Name -match $versionRegex) {
            $versionLocal = [Version]::new($matches[1])
          }
          else {
            write-error "no version info in directory name: $($dir.name)"
            break
          }
        }
      }
      # write-host $versionLocal.gettype()
      return $versionLocal
    },
    [Parameter()]
    [scriptblock]$install = {
      [CmdletBinding()]
      param($downloadedFilePath)
      
      $appName = $application -eq '' ? $repo : $application
      # ignore error, may not exist
      ri "$toLocation\temp" -Force -Recurse -ErrorAction Ignore
      # write-host $appName
      gci $toLocation -Filter "$appName*" |
      Remove-Item -Recurse -Force

      if ($downloadedFilePath -match '\.zip|\.zipx|\.7z|\.rar') {
        Write-Action "expand archive to $toLocation\temp..."
        Expand-Archive $downloadedFilePath -DestinationPath "$toLocation\temp"
        $children = gci "$toLocation\temp"
        if ($children.count -eq 1) {
          $children | Move-Item -Destination $toLocation
          ri "$toLocation\temp" -Force
          return "$children"
        }
        else {
          Move-Item "$toLocation\temp" -Destination "$toLocation\$repo"
          return "$toLocation\$repo"
        }
      }
      else {
        Move-Item "$_" -Destination $toLocation -Force
        return $toLocation
      }
    },
    # force reinstall
    [Parameter()]
    [switch]$Force
  )
  Assert-Admin

  Breakable-Pipeline {
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

      $versionLocal = Invoke-Command -ScriptBlock $getLocalVer
      # Write-Host "dd" + $versionLocal.gettype()
      if (!$versionLocal) {
        Write-Host "install the latest ${app}: $ver_online"
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
      $des = Invoke-Command -ScriptBlock $install -ArgumentList "$_"
      write-host "app installed to $des!"

    }
  }
}