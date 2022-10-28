
Install-FromGithub 'NuGetPackageExplorer/NuGetPackageExplorer' 'PackageExplorer\.[\.\d]+\.zip$' -versionType 'previews'
register-FTA "C:\App\NuGetPackageExplorer\NuGetPackageExplorer.exe" .nupkg
