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
        ni $env:temp\temp -ItemType Directory
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
    }
    else {
      $children | Move-Item -Destination $toLocation -Force
      ri "$env:temp\temp" -Force
    }
    $info = @{version = "$ver_online" }
    $info | ConvertTo-Json | Set-Content -path "$toLocation\info.json" -force
    return "$toLocation"
  }
}