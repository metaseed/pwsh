
[CmdletBinding()]
param (
  # version
  [Parameter()]
  [string]
  $version = 'stable'
)
Assert-Admin
Breakable-Pipeline {
  Get-GithubRelease -OrgName 'Powershell' -RepoName 'PowerShell' -Version $version -fileNamePattern 'win-x64.msi$' |
  % {
    $assets = $_
    if ($assets.Count -ne 1 ) {
      foreach ($asset in $assets) {
        Write-Host $asset.name
      }
      Write-Error "Expected one asset, but found $($assets.Count)"
      break;
    }
    
    $_.name -match "-(\d+\.\d+\.\d+\.*\d*)-" >$null
    $ver_online = [Version]::new($matches[1])
    $version = $PSVersionTable.PSVersion
    if ($ver_online -le $version) {
      Write-Host "You are using the latest version of PowerShell.`n $version is the latest version available."
      break
    }
    write-host "You are using PowerShell $version.`n The latest version is $ver_online."
    return $_
  } |
  Download-GithubRelease | 
  % {
    Confirm-Continue "to install power shell: $_ `nwe would kill all running pwsh processes.`n"
    Start-Process msiexec.exe -ArgumentList "/package $_ /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1"
    Write-Notice "installation started in background, please check later..."
    Get-Process -Name pwsh | Stop-Process -Force
  }
}
  
