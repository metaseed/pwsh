function Install-App {
  [CmdletBinding()]
  param($downloadedFilePath, $ver_online, $appName, $toLocation, [switch]$CreateFolder)
  Write-Host "Install $appName ..."
  Write-Host $downloadedFilePath
  # ignore error, may not exist
  gci $toLocation -Filter "$appName*" |
  Remove-Item -Recurse -Force

  if ($downloadedFilePath -match '\.exe$') {
    Move-Item "$_" -Destination $toLocation -Force
    return $toLocation
  }
  else {
    Remove-Item $env:temp\temp -Force -Recurse -ErrorAction Ignore
    Write-Action "expand archive to $env:temp\temp..."
    if ($downloadedFilePath -match '\.zip|\.zipx|\.7z|\.rar') {
      Expand-Archive $downloadedFilePath -DestinationPath "$env:temp\temp"
    }
    elseif ($downloadedFilePath -match '\.tar\.gz') {
      if (!(test-path $env:temp\temp)) {
        $null = ni $env:temp\temp -ItemType Directory
      }
      tar -xf $downloadedFilePath -C "$env:temp\temp"
    }
    else {
      write-error "$downloadedFilePath is not a know copressed archive!"
      break
    }

    $children = @(gci "$env:temp\temp")
    if ($children.count -ne 1 -or $CreateFolder) {
      $toLocation = "$toLocation\${appName}"
      Move-Item "$env:temp\temp" -Destination $toLocation
      # _${ver_online}
      $info = @{version = "$ver_online" }
      $info | ConvertTo-Json | Set-Content -path "$toLocation\info.json" -force
    }
    else {
      $app = $children[0]
      $ver_online -match "^[\d\.]+" > $null
      $ver_online = [Version]::new($Matches[0])

      # $app.VersionInfo
      $verLocal = $app.VersionInfo.ProductVersion ? $app.VersionInfo.ProductVersion : $app.VersionInfo.FileVersion

      if ($verLocal) {
        $app.VersionInfo.ProductVersion -match "^[\d\.]+" > $null
        $verLocal = [Version]::new($Matches[0])
        write-host "local version: $verLocal"

      }

      if (!$verLocal -or $verLocal -ne $ver_online) {
        write-host "modify app version from $verLocal to $ver_online"
        c:\app\rcedit-x64 "$app" --set-file-version $ver_online --set-product-version $ver_online
      }
      Move-Item $app -Destination $toLocation -Force
      ri "$env:temp\temp" -Force

    }
    return "$toLocation"
  }
}