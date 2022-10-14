# install pwsh 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
  write-warning "install powershell version great than 7"
  if (gcm winget -ErrorAction Ignore) {
    winget install  Microsoft.PowerShell
  }
  else {
    ## enable https
    Write-Host "Qurer pwsh version..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    $url = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
    $response = Invoke-RestMethod -Uri $url -Method Get -UseBasicParsing
    $v = $response.tag_name # 'v7.2.6'
    "version: $v"
    $psv = $v.substring(1)
    ## install pwsh
    $ps = gcm pwsh -ErrorAction Ignore
    if (-not $ps) {
      function Download {
        param (
          $Address
        )
        $File = Split-Path $address -Leaf
        $Exe = "$env:TEMP\$File"
        $ProgressPreference = 'SilentlyContinue' # imporve iwr speed
        Invoke-WebRequest $Address -OutFile $Exe
        $ProgressPreference = $pro
        return $Exe
      }
      Write-Host "Microsoft pwsh is not installed, download and install version $psv"
      Write-host "Downloadling Microsoft pwsh(v$psv)..."
      $exe = Download "https://github.com/PowerShell/PowerShell/releases/download/v$psv/PowerShell-$psv-win-x64.msi"
      Write-host "Installing pwsh(v$psv)..."
      Start-Process msiexec.exe -Wait -ArgumentList "/package $exe /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1"
      # update path env
      $env:path = [Environment]::GetEnvironmentVariable('path', "machine");
    }
    else {
      "pwsh already exists"
    }

  }
}
# # note this file is invoked from downloaded string. so the $MyInvocation.MyCommand.Path is not available
# # pwsh -file "$($MyInvocation.MyCommand.Path)"
# pwsh -NoExit -command "https://pwsh.page.link/0|iex"
# return