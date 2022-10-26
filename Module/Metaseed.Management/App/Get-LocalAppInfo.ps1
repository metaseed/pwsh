function Get-LocalAppInfo {
  [CmdletBinding()]
  param(
    [string] $appName,
    [string] $toLocation
  )

  $versionLocal = $null
  $appFolder = $null

  # folder has a info.json, test folder in $tolocaltion and it's direct subfolder
  if (!$versionLocal ) {
    $it = @(gci $toLocation -Filter "$appName*" -Directory -Depth 1 -FollowSymlink -ErrorAction Ignore)
    if ($it) {
      # Write-Host $it
      if ($it.Count -gt 1) {
        write-error "find more than one $appName in dir in $toLocation : $($it.FullName) "
        break
      }

      $dir = $it[0]
      $jsonFile = gi "$dir\info.json" -ErrorAction Ignore
      if ($jsonFile) {
        Write-Verbose "query local version via the info.json in dir $($dir.FullName)"
        $info = Get-Content -Raw "$jsonFile" | ConvertFrom-Json
        $versionLocal = $info.version
        $appFolder = $jsonFile.Directory.Parent.FullName
      }

    }
  }

  # get version info from the app's property
  if (!$versionLocal) {
    $it = @(gci $toLocation -Filter "$appName*.exe" -File -FollowSymlink -Depth 2 -ErrorAction Ignore)
    if ($it) {
      if ($it.count -gt 1) {
        Write-Warning "find more than one app in $toLocation : $($it.FullName) "
        # break
      }

      $app = $it[0]
      $appFolder = $app.Directory.FullName
      if ($app.Directory.Name -like "$appName*") {
        $appFolder = $app.Directory.Parent.FullName
      }
      try {
        Write-Verbose "query local version via 'gcm' $app"
        $cmd = gcm "$app"
        $versionLocal = [Version]::new($cmd.version)
      }
      catch {
        try {
          $app.VersionInfo.FileVersion -match "^[\d\.]+" > $null
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

    # file or dir directly in app folder and the name has version info
    if (!$versionLocal ) {
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
          $appFolder = $toLocation

        }
        else {
          write-Host "no version info in directory name: $($dir.name)"
        }

      }
    }
  }
  Write-Verbose "local version: $versionLocal"
  # the folder is where app.exe or app folder located
  return @{ver = $versionLocal; folder = $appFolder; }
}