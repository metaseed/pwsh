#region Private helpers

function Find-SolutionPath {
	param([string]$SolutionPathOrDir)
	if (!$SolutionPathOrDir) { $SolutionPathOrDir = '.' }
	if (Test-Path $SolutionPathOrDir -PathType Container) {
		$sln = (Get-ChildItem $SolutionPathOrDir -Filter *.sln | Select-Object -First 1).FullName
		if (!$sln) {
			Write-Host -Foreground Yellow "No Visual Studio solution found in dir: $SolutionPathOrDir"
			return $null
		}
		return $sln
	}

	if ($SolutionPathOrDir -notlike '*.sln') {
		Write-Host -Foreground Yellow "Not a Visual Studio solution file: $SolutionPathOrDir"
		return $null
	}

	return $SolutionPathOrDir
}

function Get-DevenvProcess {
	param([string]$Title)

	$procs = Get-Process devenv -ErrorAction SilentlyContinue |
	Where-Object { ($_.MainWindowHandle -ne 0) -and ($_.MainWindowTitle -like "*${Title}*") }

	if ($procs.Count -gt 1) {
		Write-Host -Foreground Yellow "$($procs.Count) instances of '$Title' open in Visual Studio, using first"
		return $procs | Select-Object -First 1
	}

	return $procs  # single match or $null
}

#endregion

function Open-VisualStudioSolution {
	[CmdletBinding()]
	[Alias('ov')]
	param (
		[Parameter(ValueFromPipeline)]
		[string]$SolutionPathOrDir
	)

	$sln = Find-SolutionPath $SolutionPathOrDir
	if (!$sln) { return }

	$abs = (Resolve-Path $sln).Path
	$title = Split-Path $abs -LeafBase
	$proc = Get-DevenvProcess $title

	if ($proc) {
		Show-Window $proc.MainWindowHandle
		Write-Host "$title already open by Visual Studio"
	}
	else {
		if (Get-Command devenv -ErrorAction SilentlyContinue) {
			& devenv.exe $abs
		}
		else {
			Invoke-Item $abs
		}
	}
}

function Close-VisualStudioSolution {
	[CmdletBinding()]
	[Alias('cv')]
	param (
		[Parameter(ValueFromPipeline)]
		[string]$SolutionPathOrDir
	)

	$sln = Find-SolutionPath $SolutionPathOrDir
	if (!$sln) { return }

	$abs = (Resolve-Path $sln).Path
	$title = Split-Path $abs -LeafBase
	$proc = Get-DevenvProcess $title

	if (!$proc) {
		Write-Host -Foreground Yellow "$title is not opened by Visual Studio"
		return
	}

	$proc.CloseMainWindow() | Out-Null
}

Export-ModuleMember -Function @('Close-VisualStudioSolution')
