# PowerShell script to install nvm-windows and Node.js
# Requires Administrator privileges

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("latest", "lts", "none")]
    [string]$Version = "none"
)

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit 1
}

# Function to check if nvm is installed
function Test-NvmInstalled {
    $nvmPath = Get-Command nvm -ErrorAction SilentlyContinue
    return $null -ne $nvmPath
}

# Function to get latest nvm-windows version
function Get-LatestNvmVersion {
    try {
        $releasesUrl = "https://api.github.com/repos/coreybutler/nvm-windows/releases/latest"
        $response = Invoke-RestMethod -Uri $releasesUrl -UseBasicParsing
        return $response.tag_name
    }
    catch {
        Write-Host "Failed to fetch latest version, using fallback version 1.2.2" -ForegroundColor Yellow
        return "1.2.2"
    }
}

# Function to install nvm-windows
function Install-Nvm {
    Write-Host "Installing nvm-windows..." -ForegroundColor Cyan
    
    Write-Host "Fetching latest version..." -ForegroundColor Yellow
    $nvmVersion = Get-LatestNvmVersion
    $nvmInstaller = "nvm-setup.exe"
    $downloadUrl = "https://github.com/coreybutler/nvm-windows/releases/download/$nvmVersion/$nvmInstaller"
    $installerPath = Join-Path $env:TEMP $nvmInstaller
    
    try {
        # Download nvm-windows installer
        Write-Host "Downloading nvm-windows $nvmVersion..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UseBasicParsing
        
        # Run installer silently
        Write-Host "Running installer..." -ForegroundColor Yellow
        Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT" -Wait
        
        # Clean up
        Remove-Item $installerPath -Force
        
        Write-Host "nvm-windows installed successfully!" -ForegroundColor Green
        Write-Host "Refreshing environment variables..." -ForegroundColor Yellow
        
        # Refresh environment variables for current session
        $env:NVM_HOME = [System.Environment]::GetEnvironmentVariable("NVM_HOME","Machine")
        $env:NVM_SYMLINK = [System.Environment]::GetEnvironmentVariable("NVM_SYMLINK","Machine")
        
        # Update PATH with both Machine and User paths
        $machinePath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
        $userPath = [System.Environment]::GetEnvironmentVariable("Path","User")
        $env:Path = "$machinePath;$userPath"
        
        Write-Host "Environment variables refreshed. You can now use nvm commands." -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to install nvm-windows: $_" -ForegroundColor Red
        return $false
    }
}

# Main script
Write-Host "=== Node.js Installation Script ===" -ForegroundColor Cyan
Write-Host ""

# Check if nvm is already installed
if (Test-NvmInstalled) {
    Write-Host "nvm is already installed." -ForegroundColor Green
    nvm version
}
else {
    Write-Host "nvm not found. Installing..." -ForegroundColor Yellow
    $installed = Install-Nvm
    
    if (-not $installed) {
        Write-Host "Installation failed. Exiting." -ForegroundColor Red
        exit 1
    }
    
    # Verify nvm is now accessible
    Write-Host ""
    Write-Host "Verifying nvm installation..." -ForegroundColor Cyan
    
    # Try to run nvm command
    try {
        $nvmTest = nvm version 2>&1
        Write-Host "nvm version: $nvmTest" -ForegroundColor Green
    }
    catch {
        Write-Host "Warning: nvm command not found in current session." -ForegroundColor Yellow
        Write-Host "Please restart your PowerShell terminal or run: refreshenv" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Alternatively, you can manually refresh the environment by running:" -ForegroundColor Yellow
        Write-Host '  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")' -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "Installing Node.js ($Version version)..." -ForegroundColor Cyan

try {
    if ($Version -eq "none") {
        Write-Host "Skipping Node.js installation (Version set to 'none')." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "nvm is ready to use. You can install Node.js later with:" -ForegroundColor Cyan
        Write-Host "  nvm install lts" -ForegroundColor White
        Write-Host "  nvm install latest" -ForegroundColor White
        Write-Host "  nvm install <version>" -ForegroundColor White
    }
    elseif ($Version -eq "lts") {
        Write-Host "Installing latest LTS version..." -ForegroundColor Yellow
        nvm install lts
        nvm use lts
        
        Write-Host ""
        Write-Host "Node.js installed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Installed versions:" -ForegroundColor Cyan
        nvm list
        Write-Host ""
        Write-Host "Node version:" -ForegroundColor Cyan
        node --version
        Write-Host ""
        Write-Host "npm version:" -ForegroundColor Cyan
        npm --version
    }
    else {
        Write-Host "Installing latest version..." -ForegroundColor Yellow
        nvm install latest
        nvm use latest
        
        Write-Host ""
        Write-Host "Node.js installed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Installed versions:" -ForegroundColor Cyan
        nvm list
        Write-Host ""
        Write-Host "Node version:" -ForegroundColor Cyan
        node --version
        Write-Host ""
        Write-Host "npm version:" -ForegroundColor Cyan
        npm --version
    }
}
catch {
    Write-Host "Failed to install Node.js: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "You may need to restart your terminal for changes to take effect." -ForegroundColor Yellow