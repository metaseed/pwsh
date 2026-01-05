param(
    [Parameter(Mandatory=$true)]
    [string]$DownloadPath,

    [Parameter(Mandatory=$false)]
    [string]$OneDrivePath = "/",

    [Parameter(Mandatory=$false)]
    [switch]$ReAuthenticate
)

# Microsoft Graph API public client ID (Microsoft Graph PowerShell)
$clientId = "14d82eec-204b-4c2f-b7e8-296a70dab67e"
$redirectUri = "urn:ietf:wg:oauth:2.0:oob"
$scope = "https://graph.microsoft.com/Files.Read.All offline_access"
$tokenFile = Join-Path $env:APPDATA "OneDriveBackup\token.json"

# Function to get device code
function Start-DeviceCodeAuth {
    Write-Host "=== Device Code Authentication ===" -ForegroundColor Cyan
    Write-Host ""

    $deviceCodeUrl = "https://login.microsoftonline.com/common/oauth2/v2.0/devicecode"

    $body = @{
        client_id = $clientId
        scope = $scope
    }

    try {
        $deviceCodeResponse = Invoke-RestMethod -Method Post -Uri $deviceCodeUrl -Body $body

        Write-Host "Please complete authentication:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "1. Open your browser and go to: $($deviceCodeResponse.verification_uri)" -ForegroundColor Green
        Write-Host "2. Enter this code: $($deviceCodeResponse.user_code)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Waiting for authentication..." -ForegroundColor Cyan

        # Attempt to start browser in private/incognito mode to avoid account conflicts
        Write-Host "Attempting to open the authentication URL in a private browser window..." -ForegroundColor Cyan
        $uriToOpen = $deviceCodeResponse.verification_uri
        try {
            # Microsoft Edge
            Start-Process "msedge" -ArgumentList "--inprivate", $uriToOpen -ErrorAction Stop
        }
        catch {
            try {
                # Google Chrome
                Start-Process "chrome" -ArgumentList "--incognito", $uriToOpen -ErrorAction Stop
            }
            catch {
                try {
                    # Mozilla Firefox
                    Start-Process "firefox" -ArgumentList "-private-window", $uriToOpen -ErrorAction Stop
                }
                catch {
                    Write-Host "Could not automatically open a private browser window." -ForegroundColor Yellow
                    Write-Host "Please open the URL manually in a private/incognito window." -ForegroundColor Yellow
                    # Fallback to default browser
                    Start-Process $uriToOpen
                }
            }
        }

        return $deviceCodeResponse
    }
    catch {
        Write-Host "Failed to initiate device code flow: $_" -ForegroundColor Red
        return $null
    }
}

# Function to poll for token
function Get-TokenFromDeviceCode {
    param($DeviceCodeResponse)

    $tokenUrl = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
    $interval = $DeviceCodeResponse.interval
    $expiresIn = $DeviceCodeResponse.expires_in
    $startTime = Get-Date

    while ($true) {
        Start-Sleep -Seconds $interval

        $body = @{
            client_id = $clientId
            grant_type = "urn:ietf:params:oauth:grant-type:device_code"
            device_code = $DeviceCodeResponse.device_code
        }

        try {
            $tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body -ErrorAction Stop
            Write-Host "Authentication successful!" -ForegroundColor Green
            return $tokenResponse
        }
        catch {
            $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json

            if ($errorDetails.error -eq "authorization_pending") {
                # Still waiting for user to authenticate
                $elapsed = ((Get-Date) - $startTime).TotalSeconds
                if ($elapsed -gt $expiresIn) {
                    Write-Host "Authentication timeout. Please try again." -ForegroundColor Red
                    return $null
                }
            }
            elseif ($errorDetails.error -eq "authorization_declined") {
                Write-Host "Authentication was declined." -ForegroundColor Red
                return $null
            }
            else {
                Write-Host "Authentication error: $($errorDetails.error_description)" -ForegroundColor Red
                return $null
            }
        }
    }
}

# Function to refresh access token
function Update-AccessToken {
    param($RefreshToken)

    $tokenUrl = "https://login.microsoftonline.com/common/oauth2/v2.0/token"

    $body = @{
        client_id = $clientId
        scope = $scope
        refresh_token = $RefreshToken
        grant_type = "refresh_token"
    }

    try {
        $response = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body
        return $response
    }
    catch {
        Write-Host "Failed to refresh token: $_" -ForegroundColor Red
        return $null
    }
}

# Function to save token to file
function Save-Token {
    param($TokenResponse)

    $tokenDir = Split-Path $tokenFile
    if (-not (Test-Path $tokenDir)) {
        New-Item -ItemType Directory -Path $tokenDir -Force | Out-Null
    }

    $tokenData = @{
        access_token = $TokenResponse.access_token
        refresh_token = $TokenResponse.refresh_token
        expires_at = (Get-Date).AddSeconds($TokenResponse.expires_in).ToString("o")
    }

    $tokenData | ConvertTo-Json | Set-Content $tokenFile
    Write-Host "Token saved for future use." -ForegroundColor Green
}

# Function to load token from file
function Get-SavedToken {
    if (-not (Test-Path $tokenFile)) {
        return $null
    }

    try {
        $tokenData = Get-Content $tokenFile | ConvertFrom-Json
        return $tokenData
    }
    catch {
        return $null
    }
}

# Function to get valid access token
function Get-ValidAccessToken {
    $savedToken = Get-SavedToken

    if ($savedToken -and -not $ReAuthenticate) {
        $expiresAt = [DateTime]::Parse($savedToken.expires_at)

        # If token expires in more than 5 minutes, use it
        if ($expiresAt -gt (Get-Date).AddMinutes(5)) {
            Write-Host "Using saved access token." -ForegroundColor Green
            return $savedToken.access_token
        }

        # Try to refresh the token
        Write-Host "Access token expired. Refreshing..." -ForegroundColor Yellow
        $newToken = Update-AccessToken -RefreshToken $savedToken.refresh_token

        if ($newToken) {
            Save-Token -TokenResponse $newToken
            return $newToken.access_token
        }
    }

    # Need to authenticate
    Write-Host "Authentication required." -ForegroundColor Yellow
    $deviceCode = Start-DeviceCodeAuth

    if (-not $deviceCode) {
        return $null
    }

    $tokenResponse = Get-TokenFromDeviceCode -DeviceCodeResponse $deviceCode

    if ($tokenResponse) {
        Save-Token -TokenResponse $tokenResponse
        return $tokenResponse.access_token
    }

    return $null
}

# Function to get a single OneDrive item by path
function Get-OneDriveItem {
    param($Token, $Path)

    $headers = @{
        Authorization = "Bearer $Token"
    }

    try {
        $cleanPath = $Path.TrimStart('/')
        if ($cleanPath -eq "") {
             $uri = "https://graph.microsoft.com/v1.0/me/drive/root"
        } else {
             $encodedPath = ($cleanPath.TrimEnd('/') -split '/' | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/'
             $uri = "https://graph.microsoft.com/v1.0/me/drive/root:/${encodedPath}"
        }

        return Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    }
    catch {
        # Return null on failure (e.g., 404 Not Found), caller will handle it.
        return $null
    }
}

# Function to list OneDrive items
function Get-OneDriveItems {
    param($Token, $Path)

    $headers = @{
        Authorization = "Bearer $Token"
    }

    try {
        if ($Path -eq "/" -or $Path -eq "") {
            $uri = "https://graph.microsoft.com/v1.0/me/drive/root/children"
        }
        else {
            $cleanPath = $Path.TrimStart('/').TrimEnd('/')
            $encodedPath = ($cleanPath -split '/' | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/'
            $uri = "https://graph.microsoft.com/v1.0/me/drive/root:/${encodedPath}:/children"
        }

        $allItems = @()

        do {
            $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
            $allItems += $response.value
            $uri = $response.'@odata.nextLink'
        } while ($uri)

        return $allItems
    }
    catch {
        Write-Host "Failed to list items at path '$Path': $_" -ForegroundColor Red
        return @()
    }
}

# Function to download a file from OneDrive
function Download-OneDriveFile {
    param($Token, $Item, $LocalPath)

    $headers = @{
        Authorization = "Bearer $Token"
    }

    try {
        $downloadUrl = $Item.'@microsoft.graph.downloadUrl'

        if ($downloadUrl) {
            $fileName = $Item.name
            $filePath = Join-Path $LocalPath $fileName

            Write-Host "  Downloading: $fileName" -ForegroundColor Gray
            Invoke-WebRequest -Uri $downloadUrl -OutFile $filePath -UseBasicParsing

            return $true
        }
    }
    catch {
        Write-Host "  Failed to download $($Item.name): $_" -ForegroundColor Red
        return $false
    }
}

# Function to recursively download folder contents
function Download-OneDriveFolder {
    param($Token, $Path, $LocalPath, $Indent = 0)

    $indentStr = "  " * $Indent

    # Create local directory
    if (-not (Test-Path $LocalPath)) {
        New-Item -ItemType Directory -Path $LocalPath -Force | Out-Null
    }

    $items = Get-OneDriveItems -Token $Token -Path $Path

    foreach ($item in $items) {
        if ($item.folder) {
            # It's a folder - recurse
            $folderName = $item.name
            $newPath = if ($Path -eq "/" -or $Path -eq "") { "$folderName" } else { "$Path/$folderName" }
            $newLocalPath = Join-Path $LocalPath $folderName

            Write-Host "$indentStr📁 $folderName" -ForegroundColor Cyan
            Download-OneDriveFolder -Token $Token -Path $newPath -LocalPath $newLocalPath -Indent ($Indent + 1)
        }
        elseif ($item.file) {
            # It's a file - download
            Write-Host "$indentStr📄 " -NoNewline -ForegroundColor Gray
            Download-OneDriveFile -Token $Token -Item $item -LocalPath $LocalPath | Out-Null
        }
    }
}

# Main script logic
Write-Host "=== OneDrive Auto Backup Script ===" -ForegroundColor Cyan
Write-Host ""

# Get valid access token
$accessToken = Get-ValidAccessToken

if (-not $accessToken) {
    Write-Host "Failed to obtain access token. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Create download directory if it doesn't exist
try {
    if (-not (Test-Path $DownloadPath)) {
        New-Item -ItemType Directory -Path $DownloadPath -Force -ErrorAction Stop | Out-Null
        Write-Host "Created download directory: $DownloadPath" -ForegroundColor Green
    }
}
catch {
    Write-Host "FATAL: Failed to create download directory '$DownloadPath'." -ForegroundColor Red
    Write-Host "Please ensure you have write permissions to the parent directory or choose a different path." -ForegroundColor Red
    Write-Host "Error details: $_" -ForegroundColor Red
    exit 1
}

Write-Host "Starting backup from OneDrive..." -ForegroundColor Cyan
Write-Host "Source: $OneDrivePath" -ForegroundColor Gray
Write-Host "Destination: $DownloadPath" -ForegroundColor Gray
Write-Host ""

# Check if the path is a file or folder
$item = Get-OneDriveItem -Token $accessToken -Path $OneDrivePath

if ($item) {
    $startTime = Get-Date

    if ($item.file) {
        # It's a file, download it
        Write-Host "Source path points to a file. Downloading..." -ForegroundColor Gray
        Download-OneDriveFile -Token $accessToken -Item $item -LocalPath $DownloadPath
    }
    elseif ($item.folder) {
        # It's a folder, download its contents
        Write-Host "Source path points to a folder. Downloading contents recursively..." -ForegroundColor Gray
        # If the root folder is specified, OneDrivePath is "/" but the item name is "root".
        # We pass the original path to Download-OneDriveFolder to correctly construct sub-paths.
        Download-OneDriveFolder -Token $accessToken -Path $OneDrivePath -LocalPath $DownloadPath
    }
    else {
        Write-Host "Source path '$OneDrivePath' is not a file or a folder that can be backed up." -ForegroundColor Red
        exit 1
    }

    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host ""
    Write-Host "✅ Backup completed in $([math]::Round($duration.TotalSeconds, 2)) seconds!" -ForegroundColor Green
    Write-Host "Files downloaded to: $DownloadPath" -ForegroundColor Green

}
else {
    Write-Host "Could not find item at path '$OneDrivePath'. Please check the path and try again." -ForegroundColor Red
    Write-Host "Note: For files or folders in the root, the path should start with '/'. E.g., '/MyFile.txt'." -ForegroundColor Yellow
    exit 1
}