[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force
Install-FromGithub 'NuGetPackageExplorer/NuGetPackageExplorer' 'PackageExplorer\.[\.\d]+\.zip$' -versionType 'previews' @Remaining
register-FTA "C:\App\NuGetPackageExplorer\NuGetPackageExplorer.exe" .nupkg
