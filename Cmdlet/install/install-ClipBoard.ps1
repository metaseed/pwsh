ipmo Metaseed.Management -Force # for modify Install-FromGithub related code
Install-FromGithub 'https://github.com/Slackadays/ClipBoard' '-windows-amd64\.zip$' -newName cb  -filesToPickup 'cb\.exe' -Force @args

# Kill any hung cb process
# Stop-Process -Name cb -Force -ErrorAction SilentlyContinue

# Clear CB's temp clipboard state (the default clipboard)
# Remove-Item -Recurse -Force "$env:TEMP\Clipboard" -ErrorAction SilentlyContinue

# Also clear persistent clipboard if needed
# Remove-Item -Recurse -Force "$env:USERPROFILE\.local\state\clipboard" -ErrorAction SilentlyContinue