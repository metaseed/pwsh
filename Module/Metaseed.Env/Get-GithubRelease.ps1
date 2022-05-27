
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
  
  Write-Step "query latest ($version)version..."

  if($version -eq 'stable'){
    $url = "https://api.github.com/repos/$OrgName/$RepoName/releases/latest"
  }else{
    $url = "https://api.github.com/repos/$OrgName/$RepoName/releases"
  }

  $response = Invoke-RestMethod -Uri $url -Method Get -UseBasicParsing 

  if($version -eq 'preview'){
    # first one is the latest release
    $response = $response.SyncRoot[0]
  }

  $assets = @($response.assets | where {$_.name -match $fileNamePattern} | select -Property 'name','browser_download_url')

  return $assets

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
  if($assets.count -eq 0){
    Write-Error "no file found"
  } elseif($assets.count -gt 1){
    foreach($asset in $assets){
      Write-Host $asset.name
    }
    Write-Error "multiple files found:"
  } else {
    $asset = $assets[0]
    $url = $asset.browser_download_url
    Write-Debug $url
    $output = "$outputDir\$($asset.name)"
    Write-Step "downloading $($asset.name)... "
    Write-Host "from $url"
    Invoke-RestMethod -Uri $url -Method Get -UseBasicParsing -OutFile $output
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