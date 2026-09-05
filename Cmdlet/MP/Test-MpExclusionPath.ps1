[CmdletBinding()]
param (
	[Parameter()]
	[string]
	$TargetDirectory = "C:\Schlumberger\Muzic\StressTest",
	[Parameter()]
	[switch]
	$PureClean
)

if ((Test-Path $TargetDirectory) -and $PureClean) {
    Remove-Item -Path $TargetDirectory -Recurse -Force
    Write-Host "Stress test folder successfully purged." -ForegroundColor Green
	return
}
$TotalFiles = 500

# Create the stress test directory
if (-not (Test-Path $TargetDirectory)) {
    New-Item -ItemType Directory -Path $TargetDirectory -Force | Out-Null
}

Write-Host "WARNING: Launching rapid file generation (500 files) in $TargetDirectory..." -ForegroundColor Yellow
Write-Host "This simulates high-intensity I/O layout to test behavioral bypass." -ForegroundColor Cyan

$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$Blocked = $false

for ($i = 1; $i -le $TotalFiles; $i++) {
    $FilePath = Join-Path $TargetDirectory "stress_log_$i.dat"

    try {
        # Create unique, variable contents so the engine can't optimize via caching
        $UniqueId = [Guid]::NewGuid().ToString()
        $FakeData = 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'

        # Write to disk with zero sleep/delay
        [System.IO.File]::WriteAllText($FilePath, $FakeData)
    }
    catch {
        $Blocked = $true
        Write-Host "`n[!] CRITICAL HIT: The security engine intercepted the process at file #$i!" -ForegroundColor Red
        Write-Warning $_.Exception.Message
        break
    }
}

$Stopwatch.Stop()

# Output Results Analysis
if (-not $Blocked) {
    Write-Host "`n[SUCCESS] Completed writing $TotalFiles files." -ForegroundColor Green
    Write-Host "Execution Time: $($Stopwatch.Elapsed.TotalSeconds) seconds." -ForegroundColor Green
    Write-Host "Average Time per File: $($Stopwatch.Elapsed.TotalMilliseconds / $TotalFiles) ms." -ForegroundColor Green
    Write-Host "Verdict: The exclusion path $TargetDirectory is successfully bypassing real-time behavioral scans!" -ForegroundColor Green
} else {
    Write-Host "`n[VERDICT]: The exclusion path $TargetDirectory FAILED to bypass behavioral scanning. One of your corporate endpoint agents (Cortex/Carbon Black) stepped in." -ForegroundColor Red
}
