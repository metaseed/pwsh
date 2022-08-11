# function Clear-SystemTmp {
#Calling Powershell as Admin and setting Execution Policy to Bypass to avoid Cannot run Scripts error
# Invoke-Admin $PSCommandPath $PSBoundParameters -break
Assert-Admin
# Rename Title Window
# $host.ui.RawUI.WindowTitle = "Clean Browser Temp Files"
# https://github.com/Bromeego/Clean-Temp-Files/blob/master/Clear-TempFiles.ps1
# Set Date for Log
$LogDate = Get-Date -Format "MM-d-yy-HHmm"
    
# Set Deletion Date for Downloads Folder
$DelDownloadsDate = (Get-Date).AddDays(-20)
$DelTempDate = (Get-Date).AddDays(-30)

# Set Deletion Date for Inetpub Log Folder
$DelInetLogDate = (Get-Date).AddDays(10)

# Set Deletion Date for System32 Log Folder
$System32LogDate = (Get-Date).AddMonths(-2)

# Set Deletion Date for Azure Logs Folder
$DelAZLogDate = (Get-Date).AddDays(-7)

# Set Deletion Date for Office File Cache Folder
$DelOfficeCacheDate = (Get-Date).AddDays(-7)

# Set Deletion Date for LFSAgent Logs Folder
$DelLFSAGentLogDate = (Get-Date).AddDays(-30)

# Set Deletion Date for SotiMobicontroller Logs
$DelSotiLogDate = (Get-Date).AddYears(-1)

# Get the size of the Windows Updates folder (SoftwareDistribution)
$WUfoldersize = (Get-ChildItem "$env:windir\SoftwareDistribution" -Recurse | Measure-Object Length -sum).sum / 1Gb

# Ask the user if they would like to clean the Windows Update folder
if ($WUfoldersize -gt 1.5) {
  Write-Host "The Windows Update folder is" ("{0:N2} GB" -f $WUFoldersize)
  $CleanWU = Read-Host "Do you want clean the Software Distribution folder and reset Windows Updates? (Y/N)"
}

# Get Disk Size
$Before = Show-DiskSpace

# Define log file location
$Cleanuplog = "$env:temp\Cleanup$LogDate.log"

# Start Logging
Start-Transcript -Path "$CleanupLog"

# Create list of users
Write-Action "Getting the list of Users"
$UsersPath = split-path $env:USERPROFILE
$Users = Get-ChildItem "$UsersPath" | Select-Object Name
$users = $Users.Name 

# Begin!
Write-Step "Clear Browsers Cache..."

# Clear Firefox Cache
Foreach ($user in $Users) {
  if (Test-Path "$UsersPath\$user\AppData\Local\Mozilla\Firefox\Profiles") {
    Write-SubStep "Clearing Firefox Cache for user $user"
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Mozilla\Firefox\Profiles\*\cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Mozilla\Firefox\Profiles\*\cache2\entries\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Mozilla\Firefox\Profiles\*\thumbnails\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Mozilla\Firefox\Profiles\*\cookies.sqlite" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Mozilla\Firefox\Profiles\*\webappsstore.sqlite" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Mozilla\Firefox\Profiles\*\chromeappsstore.sqlite" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Mozilla\Firefox\Profiles\*\OfflineCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
  }
     
}
# Clear Google Chrome
Foreach ($user in $Users) {
  if (Test-Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data") {
    Write-SubStep "Clearing Google Chrome Cache for user $user"
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data\Default\Cookies" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data\Default\Cookies-Journal" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data\Default\JumpListIconsOld" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    # Comment out the following line to remove the Chrome Write Font Cache too.
    # Remove-Item -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data\Default\ChromeDWriteFontCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose

    # Check Chrome Profiles. It looks as though when creating profiles, it just numbers them Profile 1, Profile 2 etc.
    $Profiles = Get-ChildItem -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data" | Select-Object Name | Where-Object Name -Like "Profile*"
    foreach ($Account in $Profiles) {
      $Account = $Account.Name 
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data\$Account\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data\$Account\Cache2\entries\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose 
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data\$Account\Cookies" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data\$Account\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data\$Account\Cookies-Journal" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Google\Chrome\User Data\$Account\JumpListIconsOld" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    }
  }
     
}

# Clear Internet Explorer & Edge
Write-SubStep "Clearing Internet Explorer & Old Edge Cache"
Foreach ($user in $Users) {
  Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
  Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Windows\INetCache\* " -Recurse -Force -ErrorAction SilentlyContinue -Verbose
  Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Windows\WebCache\* " -Recurse -Force -ErrorAction SilentlyContinue -Verbose
}
   

# Clear Edge Chromium
taskkill /F /IM msedge.exe
Foreach ($user in $Users) {
  if (Test-Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data") {
    Write-SubStep "Clearing Edge Chromium Cache for user $user"
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    #Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data\Default\Cache2\entries\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data\Default\Cookies" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    #Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data\Default\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data\Default\Cookies-Journal" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    #Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data\Default\JumpListIconsOld" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    # Comment out the following line to remove the Edge Write Font Cache too.
    # Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data\Default\EdgeDWriteFontCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        
    # Check Edge Profiles. It looks as though when creating profiles, it just numbers them Profile 1, Profile 2 etc.
    $Profiles = Get-ChildItem -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data" | Select-Object Name | Where-Object Name -Like "Profile*"
    foreach ($Account in $Profiles) {
      $Account = $Account.Name 
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data\$Account\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      #Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data\$Account\Cache2\entries\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose 
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data\$Account\Cookies" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      #Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data\$Account\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data\$Account\Cookies-Journal" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      #Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Edge\User Data\$Account\JumpListIconsOld" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    }
  }

  # Clear Chromium
  Foreach ($user in $Users) {
    if (Test-Path "$UsersPath\$user\AppData\Local\Chromium") {
      Write-SubStep "Clearing Chromium Cache for user $user"
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Chromium\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Chromium\User Data\Default\GPUCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Chromium\User Data\Default\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Chromium\User Data\Default\Pepper Data" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Chromium\User Data\Default\Application Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    }
  }
    
  # Clear Opera
  Foreach ($user in $Users) {
    if (Test-Path "$UsersPath\$user\AppData\Local\Opera Software") {
      Write-SubStep "Clearing Opera Cache for user $user"
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Opera Software\Opera Stable\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    } 
  }

  # Clear Yandex
  Foreach ($user in $Users) {
    if (Test-Path "$UsersPath\$user\AppData\Local\Yandex") {
      Write-SubStep "Clearing Yandex Cache for user $user"
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Yandex\YandexBrowser\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Yandex\YandexBrowser\User Data\Default\GPUCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Yandex\YandexBrowser\User Data\Default\Media Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Yandex\YandexBrowser\User Data\Default\Pepper Data\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Yandex\YandexBrowser\User Data\Default\Application Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
      Remove-Item -Path "$UsersPath\$user\AppData\Local\Yandex\YandexBrowser\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    } 
  }

  # Clear User Temp Folders
  Write-Step "Clearing User Temp Folders"
  Foreach ($user in $Users) {
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Windows\AppCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\CrashDumps\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
  }
  # Clear Windows Temp Folder
  Write-Step "Clearing Windows Temp Folder"
  Foreach ($user in $Users) {
    Remove-Item -Path "C:\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$env:windir\Logs\CBS\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$env:ProgramData\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    # Only grab log files sitting in the root of the Logfiles directory
    Get-ChildItem -Path "$env:windir\System32\LogFiles" | Where-Object { ($_.name -like "*.log") -and ($_.lastwritetime -lt $System32LogDate) } |
    % {
      Remove-Item -Path "$env:windir\System32\LogFiles\$($_.name)" -Force -ErrorAction SilentlyContinue -Verbose
    }
  }
}

# Clear Inetpub Logs Folder
# the default folder for Microsoft Internet Information Services (IIS)
if (Test-Path "C:\inetpub\logs\LogFiles\") {
  Write-Step "Clearing Inetpub Logs Folder that older than $(((get-date) - $DelInetLogDate).Days)"
  Get-ChildItem -Path "C:\inetpub\logs\LogFiles\" | 
  Where-Object LastWriteTime -LT $DelInetLogDate |
  % {
    Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue -Verbose 
  }
}

$Users | % {
  $user = $_
  $UserDownloads = "$UsersPath\$user\Downloads"
  if (test-path $UserDownloads) {
    $d = Get-ChildItem -Path "$UserDownloads" -Force 
    if ($d.Count -gt 0) {
      Write-Step "Deleting files older than $(((get-date) - $DelDownloadsDate).Days) days from User($user) Downloads folder"
      $d |
      Where-Object LastWriteTime -LT $DelDownloadsDate | 
      % {
        Remove-Item $_ -Force -Recurse -ErrorAction SilentlyContinue -Verbose
      }
    }
  }
}

# Delete Windows Updates Folder (SoftwareDistribution) and reset the Windows Update Service
if ($CleanWU -eq 'Y') { 
  Write-Step "Restarting Windows Update Service and Deleting SoftwareDistribution Folder"
  # Stop the Windows Update service
  try {
    Stop-Service -Name wuauserv
  }
  catch {
    $ErrorMessage = $_.Exception.Message
    Write-Warning "$ErrorMessage" 
  }
  # Delete the folder
  Remove-Item "$env:windir\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
  Start-Sleep -s 3

  # Start the Windows Update service
  try {
    Start-Service -Name wuauserv
  }
  catch {
    $ErrorMessage = $_.Exception.Message
    Write-Warning "$ErrorMessage" 
  }
}

# Empty Recycle Bin
Write-Step "Cleaning Recycle Bin"
$objShell = New-Object -ComObject Shell.Application   
$objFolder = $objShell.Namespace(0xA)   
$objFolder.items() | % { remove-item $_.path -Recurse -Confirm:$false }
    
# $RecycleBin = "C:\`$Recycle.Bin"
# $BinFolders = Get-ChildItem $RecycleBin -Directory -Force -ErrorAction SilentlyContinue 

# Foreach ($Folder in $BinFolders) {
#   # Translate the SID to a User Account
#   $objSID = New-Object System.Security.Principal.SecurityIdentifier ($folder)
#   try {
#     $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
#     Write-Host -Foreground Yellow -Background Black "Cleaning $objUser Recycle Bin"
#   }
#   # If SID cannot be Translated, Throw out the SID instead of error
#   catch {
#     $objUser = $objSID.Value
#     Write-Host -Foreground Yellow -Background Black "$objUser"
#   }
#   $Files = @()


#   $Files = Get-ChildItem $Folder.FullName -File -Recurse -Force  -ErrorAction SilentlyContinue
#   $Files += Get-ChildItem $Folder.FullName -Directory -Recurse -Force  -ErrorAction SilentlyContinue

#   $FileTotal = $Files.Count

#   for ($i = 1; $i -le $Files.Count; $i++) {
#     $FileName = Select-Object -InputObject $Files[($i - 1)]
#     Write-Progress -Activity "Recycle Bin Clean-up" -Status "Attempting to Delete File [$i / $FileTotal]: $FileName" -PercentComplete (($i / $Files.count) * 100) -Id 1
#     Remove-Item -Path $Files[($i - 1)].FullName -Recurse -Force
#   }
#   Write-Progress -Activity "Recycle Bin Clean-up" -Status "Complete" -Completed -Id 1
# }

Write-Step "Cleaning C:\temp and c:\tmp folders"
Write-SubStep "clearing C:\temp"
# Listing all files in C:\Temp\* recursively, using Force parameter displays hidden files.
Get-ChildItem -Path "C:\Temp\*"  -Force |
? LastWriteTime -LT $DelTempDate | 
% {
  Remove-Item $_ -Force -Recurse -ErrorAction SilentlyContinue -Verbose
}

Write-SubStep "clearing C:\tmp"
Get-ChildItem -Path "C:\tmp\*" -Recurse -Force |
? LastWriteTime -LT $DelTempDate | 
% {
  Remove-Item $_ -Force -Recurse -ErrorAction SilentlyContinue -Verbose
}

Write-Step "Clearing Application temp Folders..."
# Delete files older than 7 days from Office Cache Folder
Foreach ($user in $Users) {
  $officecache = "$UsersPath\$user\AppData\Local\Microsoft\Office\16.0\GrooveFileCache"
  if (Test-Path $officecache) {
    $OldFiles = Get-ChildItem -Path "$officecache\" -ErrorAction SilentlyContinue 
    if ($oldFiles.Count -gt 0) {
      Write-SubStep "Cleaning $officecache"
      $OldFiles |
      Where-Object LastWriteTime -LT $DelOfficeCacheDate |
      Remove-Item -Path "$officecache\$_" -Force -Recurse -ErrorAction SilentlyContinue -Verbose
    }
  } 
}
# Delete Microsoft Teams Previous Version files
Foreach ($user in $Users) {
  if (Test-Path "$UsersPath\$user\AppData\Local\Microsoft\Teams\") {
    Write-SubStep "Clearing Teams Previous version for user $user"
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Teams\previous\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\AppData\Local\Microsoft\Teams\stage\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
  } 
}

# Delete SnagIt Crash Dump files
Foreach ($user in $Users) {
  if (Test-Path "$UsersPath\$user\AppData\Local\TechSmith\SnagIt") {
    Write-SubStep "Clearing SnagIt Crash Dumps for user $user"
    Remove-Item -Path "$UsersPath\$user\AppData\Local\TechSmith\SnagIt\CrashDumps\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
  } 
}

# Clear Dropbox
Foreach ($user in $Users) {
  if (Test-Path "$UsersPath\$user\Dropbox\") {
    Write-SubStep "Clearing Dropbox Cache for user $user"
    Remove-Item -Path "$UsersPath\$user\Dropbox\.dropbox.cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path "$UsersPath\$user\Dropbox*\.dropbox.cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
  }
}

# Delete files older than 7 days from Azure Log folder
if (Test-Path "C:\WindowsAzure\Logs") {
  Write-SubStep "Deleting files older than 7 days from Azure Log folder"
  $AzureLogs = "C:\WindowsAzure\Logs"
  Get-ChildItem -Path "$AzureLogs\"  -ErrorAction SilentlyContinue | Where-Object LastWriteTime -LT $DelAZLogDate |
  % {
    Remove-Item -Path $_ -Force -Recurse -ErrorAction SilentlyContinue -Verbose
  }
} 
# Delete files older than 30 days from LFSAgent Log folder https://www.lepide.com/
if (Test-Path "$env:windir\LFSAgent\Logs") {
  Write-SubStep "Deleting files older than 30 days from LFSAgent Log folder"
  $LFSAgentLogs = "$env:windir\LFSAgent\Logs"
  Get-ChildItem -Path "$LFSAgentLogs\" -ErrorAction SilentlyContinue | Where-Object LastWriteTime -LT $DelLFSAGentLogDate |
  % {
    Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue -Verbose
  }
}         

# Delete SOTI MobiController Log files older than 1 year
if (Test-Path "C:\Program Files (x86)\SOTI\MobiControl") {
  Write-SubStep "Deleting SOTI MobiController Log files older than 1 year"
  $SotiLogFiles = Get-ChildItem -Path "C:\Program Files (x86)\SOTI\MobiControl" | Where-Object { ($_.name -like "*Device*.log" -or $_.name -like "*Server*.log" ) -and ($_.lastwritetime -lt $DelSotiLogDate) }
  foreach ($File in $SotiLogFiles) {
    Remove-Item -Path "C:\Program Files (x86)\SOTI\MobiControl\$($file.name)" -Force -ErrorAction SilentlyContinue -Verbose
  }
}

# Delete old Cylance Log files
if (Test-Path "C:\Program Files\Cylance\Desktop") {
  Write-SubStep "Deleting Old Cylance Log files"
  $OldCylanceLogFiles = Get-ChildItem -Path "C:\Program Files\Cylance\Desktop" | Where-Object name -Like "cylog-*.log"
  foreach ($File in $OldCylanceLogFiles) {
    Remove-Item -Path "C:\Program Files\Cylance\Desktop\$($file.name)" -Force -ErrorAction SilentlyContinue -Verbose
  }
}

Play-Ring
Write-Notice "All Tasks Done!"

# Get Drive size after clean
$After = Show-DiskSpace

# Sends some before and after info for ticketing purposes
Write-Notice "Before: $Before"
Write-Notice "After: $After"

# Another reminder about running Windows update if needed as it would get lost in all the scrolling text.
if ($CleanWU -eq 'Y') { 
  Write-Notic "You can rerun Windows Update to pull down the latest updates "
}

# Completed Successfully!
# Open Text File
Invoke-Item $Cleanuplog

@(
  # dmp files
  "$env:windir\LiveKernelReports",
  "$env:windir.old",
  "$env:windir\Downloaded Program Files" # activex of ie
)|% {
Remove-Item -Path "$_\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
}


# Stop Script
Stop-Transcript
# }
