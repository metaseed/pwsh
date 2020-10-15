function Update-Path {
    param (
        [# directory to add to path
        Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String]
        $Dir,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [bool]
        $User = $false
    )
    
    if (-not $env:Path.Contains($dir)) {
        $scope = Test-Admin? "Machine": "User"
        [Environment]::SetEnvironmentVariable("Path", "$dir;" + $env:Path, $scope)
    }

}