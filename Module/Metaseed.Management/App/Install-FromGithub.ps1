function Install-FromGithub {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    # ornization name on github
    $org,
    # repo name on github
    [Parameter(Mandatory = $true)]
    $app,
    # regex to filter out the file from resource names
    [Parameter(Mandatory = $true)]
    $filter, # = '-windows\.zip$', # '(?<!\.Light).Portable.x64.zip$'

    # where to unzip/install the app
    $toLocation = $env:MS_App,
    # version type: stable or preview
    [Parameter()]
    [string]
    [ValidateSet('preview', 'stable')]
    $versionType = 'preview',

    # scriptblock to get the online app version
    [scriptblock]$getOnlineVer = { param($name, $tag_name) 
      # $versionRegex = "_(\d+\.\d+\.?\d*\.*\d*)_x64"
      # $_.name -match $versionRegex >$null
      # $ver_online = [Version]::new($matches[1])
      $ver_online = $tag_name.trim('v', 'e', 'r')
      $ver_online = [Version]::new($ver_online)
      $ver_online
    },
    # scriptblock to get local installed app version
    [scriptblock]$getLocalVer = {

      # $it = gci $toLocation -Directory -Filter "$app*"
      # if ($it) {
      #   $it.Name -match $versionRegex >$null
      #   $versionLocal = [Version]::new($matches[1])
      # }
      Write-Verbose  "query version: $toLocation\$app*\$app*.exe"
      $it = gi "$toLocation\$app*\$app*.exe" -ErrorAction SilentlyContinue
      if ($it) {
        try {
          $versionLocal = [Version]::new($it.VersionInfo.ProductVersion)
        }
        catch {
          $versionLocal = [Version]::new($it.VersionInfo.FileVersion)
        }
      }
      $versionLocal
    },
    [scriptblock]$install = {
      param($downloadedFilePath)

      if ($downloadedFilePath -match '\.zip|\.zipx|\.7z|\.rar') {
        Write-Action "expand archive to $toLocation\temp..."
        Expand-Archive $downloadedFilePath -DestinationPath "$toLocation\temp"
        $children = gci "$toLocation\temp" -Directory
        if ($children.count -eq 1) {
          $children | Move-Item -Destination $toLocation
          ri "$toLocation\temp" -Force
          return "$children"
        }
        else {
          Move-Item "$toLocation\temp" -Destination "$toLocation\$app"
          return "$toLocation\$app"
        }
      }
      else {
        Move-Item "$_" -Destination $toLocation
        return $toLocation
      }
    },
    # force reinstall
    [switch]$force
  )
  Assert-Admin

  Breakable-Pipeline {
    Get-GithubRelease -OrgName $org -RepoName $app -Version $versionType -fileNamePattern $filter |
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
      if (!$versionLocal) {
        Write-Host "install the latest ${app}: $ver_online"
      }
      else {
        if ($ver_online -le $versionLocal) {
          Write-Host "You are using the latest version of $app.`n $versionLocal is the latest version available."
          if(!$force) {
            break
          }
          Write-Warning "Forcely install the latest version..."
        }
        write-host "You are using $app $versionLocal.`n The latest version is $ver_online."
      }
      return $_
    } |
    Download-GithubRelease | 
    % {
      gci $toLocation -Directory -Filter "$app*" |
      Remove-Item -Recurse -Force

      $des = Invoke-Command -ScriptBlock $install -ArgumentList "$_"
      write-host "app installed to $des!"

    }
  }
}