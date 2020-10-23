using namespace System.IO
using module Admin
function Update-PathEnv {
    param (
        [# directory to add to path
        Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String]
        $Dir
    )
    
    $scope = (Test-Admin) ? "Machine": "User"
    if (-not (Test-PathEnv $env:Path $dir)) {
        $env:Path = "$dir;" + $env:Path
        Write-Information "'$dir' was added to current `$env:Path"
    } else {
        Write-Information "current `$env:Path already contains $dir"
    }

    $envPath = [Environment]::GetEnvironmentVariable("Path", $scope)
    if(-not (Test-PathEnv $envPath $dir)) {
        [Environment]::SetEnvironmentVariable("Path", $env:Path, $scope)
        Write-Information "'$dir' was added to Environment variable: Path"
    } else {
        Write-Information "`Envirionment Variable Path already contains $dir"
    }

}

function Test-PathEnv {
    [CmdletBinding()]
    param (
     [String] $pathEnv,
     [String]$dir
    )
    $pathEnv -split ';' | Where-Object {
        if([String]::IsNullOrEmpty($_)) { return $false;}
        $path = [Path]::GetFullPath($_);
        $path.Equals([Path]::GetFullPath($dir), [StringComparison]::OrdinalIgnoreCase)}
}   

Export-ModuleMember -Function Test-PathEnv, Update-PathEnv
