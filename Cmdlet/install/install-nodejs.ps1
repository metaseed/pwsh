param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("latest", "lts")]
    [string]$Version = "lts"
)

function Install-NodeJS {
    param(
        [string]$VersionType
    )
    
    try {
        Write-Host "Fetching Node.js version information..." -ForegroundColor Yellow
        
        # Get all available versions
        $response = Invoke-RestMethod -Uri "https://nodejs.org/dist/index.json" -ErrorAction Stop
        
        if ($VersionType -eq "latest") {
            # Get the very latest version (first in the list)
            $selectedVersion = $response[0]
            Write-Host "Selected: Latest version $($selectedVersion.version)" -ForegroundColor Green
        } else {
            # Get the latest LTS version
            $selectedVersion = $response | Where-Object { $_.lts -ne $false } | Select-Object -First 1
            Write-Host "Selected: Latest LTS version $($selectedVersion.version) ($($selectedVersion.lts))" -ForegroundColor Green
        }
        
        # Construct download URL for Windows x64 MSI
        $version = $selectedVersion.version
        $url = "https://nodejs.org/dist/$version/node-$version-x64.msi"
        $output = "$env:TEMP\nodejs-$version.msi"
        
        Write-Host "Downloading from: $url" -ForegroundColor Cyan
        
        # Download the installer
        Invoke-WebRequest -Uri $url -OutFile $output -ErrorAction Stop
        
        # Verify file was downloaded
        if (-not (Test-Path $output)) {
            throw "Download failed - installer file not found"
        }
        
        Write-Host "Installing Node.js $version..." -ForegroundColor Yellow
        
        # Install silently
        $installProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$output`" /quiet /norestart" -Wait -PassThru
        
        if ($installProcess.ExitCode -eq 0) {
            Write-Host "✓ Node.js $version installed successfully!" -ForegroundColor Green
        } else {
            throw "Installation failed with exit code: $($installProcess.ExitCode)"
        }
        
        # Clean up installer file
        Remove-Item $output -Force
        Write-Host "Cleaned up installer file" -ForegroundColor Gray
        
        # Verify installation
        Write-Host "`nVerifying installation..." -ForegroundColor Yellow
        
        # Refresh environment variables for current session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        try {
            $nodeVersion = & node --version 2>$null
            $npmVersion = & npm --version 2>$null
            
            if ($nodeVersion -and $npmVersion) {
                Write-Host "✓ Node.js version: $nodeVersion" -ForegroundColor Green
                Write-Host "✓ npm version: $npmVersion" -ForegroundColor Green
                Write-Host "`nInstallation completed successfully! You may need to restart your terminal." -ForegroundColor Green
            } else {
                Write-Host "⚠ Installation completed but verification failed. Try restarting your terminal." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "⚠ Installation completed but verification failed. Try restarting your terminal." -ForegroundColor Yellow
        }
        
    } catch {
        Write-Error "Error during installation: $($_.Exception.Message)"
        
        # Clean up on error
        if (Test-Path $output) {
            Remove-Item $output -Force
        }
        
        exit 1
    }
}

# Main execution
Write-Host "Node.js Installer Script" -ForegroundColor Magenta
Write-Host "========================" -ForegroundColor Magenta

Install-NodeJS -VersionType $Version