
function Get-GithubRelease {
  [CmdletBinding()]
  param (
    # orgnization name
    [Parameter(Mandatory = $true)]
    [string]
    $OrgName,

    # repository name
    [Parameter(Mandatory = $true)]
    [string]
    $RepoName,

    [Parameter()]
    [string]
    [ValidateSet('preview', 'stable')]
    $version = 'stable',

    [Parameter()]
    [string]
    $fileNamePattern
  )

  Write-Step "query version($version)..."

  # if ($version -eq 'stable') {
  # only the stable latest release
  #   $url = "https://api.github.com/repos/$OrgName/$RepoName/releases/latest"
  # }
  # else {
  $url = "https://api.github.com/repos/$OrgName/$RepoName/releases"
  # }

  $response = Invoke-RestMethod -Uri $url -Method Get -UseBasicParsing

  # if ($version -eq 'preview') {
  #   # first one is the latest release
  #   $response = $response.SyncRoot[0]
  # }
  write-host "$version"
  # Write-Verbose "$response"
  foreach ($release in $response) {
    if ($version -eq 'stable' -and $release.prerelease) {
      Write-Host "skip preview version: $($release.name)"
      continue;
    }

    $assets = $release.assets |
    ? { $_.name -match $fileNamePattern } |
    select -Property 'name',
    @{label = 'tag_name'; expression = { $release.tag_name } },
    'browser_download_url',
    @{label = 'releaseNote'; expression = { $release.body } }

    if (!$assets) {
      write-warning "can not find assets with '$fileNamePattern', in release: $($release.name)"
      $release.assets | select name | Format-Table | out-string | write-host
      $yes = Confirm-Continue "Are you want to continue searching from old release?" -Result
      if ($yes) {
        continue;
      }
      start "https://github.com/$OrgName/$RepoName/releases"
      return @()
    }

    if ($assets.Count -ne 1 ) {
      foreach ($asset in $assets) {
        Write-Warning $asset.name
      }
      Write-Warning "Expected one asset, but found $($assets.Count), please make the filer more specific!"
    }
    return @(, $assets) # use , (unary array operator) to pass a array inside a array, so the pipeline will process the $assets together
  }
  write-error "can not find any assets with '$fileNamePattern' in any release."
  return @()
}

function Download-GithubRelease {
  [CmdletBinding()]
  param (
    # assets
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [object]
    $assets,
    # output directory
    [string]
    $outputDir = $env:TEMP
  )
  if (!$assets -or $assets.count -eq 0) {
    Write-Error "no file found"
  }
  elseif ($assets.count -gt 1) {
    foreach ($asset in $assets) {
      Write-Host $asset.name
    }
    Write-Error "multiple files found:"
  }
  else {
    $asset = $assets[0]
    $url = $asset.browser_download_url
    Write-Debug $url
    $output = "$outputDir\$($asset.name)"
    if (Test-Path $output) {
      if ( ((get-date) - (gi $output).LastWriteTime).Hours -lt 8) {
        Write-Host "reuse last time download: $output"
        return $output
      }
    }
    Write-Step "downloading $($asset.name)... "
    Write-Host "from $url, please wait..."
    $pro = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue' # imporve iwr speed
    if ($PSVersionTable.PSVersion.Major -lt 7) {
      iwr $url -UseB -OutFile $output
    }
    else {
      iwr $url -OutFile $output
    }
    $ProgressPreference = $pro
    Write-Debug "saved to $output"
    return $output
  }

}

Export-ModuleMember Download-GithubRelease

# old implementation, just latest stable release
# (iwr https://github.com/microsoft/terminal/releases/latest) -match "(?<=<a href=`").*Microsoft.WindowsTerminal_$platform_.*\.msixbundle" |out-null
# $url = "http://github.com$($matches[0])"
# $file = ($url -split '/')[-1]
# write-host $file

# tests:
# Get-GithubRelease -OrgName 'microsoft' -RepoName 'terminal' -version 'preview' -fileNamePattern '_win10_.*\.msixbundle'
# Get-GithubRelease -OrgName 'microsoft' -RepoName 'terminal' -version 'stable' -fileNamePattern '_win10_.*\.msixbundle$' | Download-GithubRelease