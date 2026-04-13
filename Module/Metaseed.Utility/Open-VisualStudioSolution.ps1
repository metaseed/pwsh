function Open-VisualStudioSolution {
	[CmdletBinding()]
	[alias('vs')]
	param (
		[Parameter(Mandatory = $true)]
		[string]$SolutionPathOrDir
	)
	if(Test-Path $SolutionPathOrDir -PathType Container){
		$SolutionPath = (Get-ChildItem $SolutionPathOrDir -Filter *.sln | Select-Object -First 1).FullName
		if(!$SolutionPath) {
			Write-Notice "No Visual Studio solution found in dir: $SolutionPathOrDir"
			return
		}
	}

	if($SolutionPathOrDir -notlike '*.sln') {
		Write-Notice "the file path is not a Visual Studio solution file, path: $SolutionPathOrDir"
		return
	} else {
		$SolutionPath = $SolutionPathOrDir
	}

	$abs = (Resolve-Path $SolutionPath).Path

	# Check if any devenv has this solution open via its window title
	$running = Get-Process devenv -ErrorAction SilentlyContinue | Where-Object {
		$_.MainWindowTitle -like "*$(Split-Path $abs -LeafBase)*"
	}
	if ($running.length -gt 1) {
		$running = $running | Select-Object -First 1
	}

	if ($running) {
		# Bring existing instance to foreground
		if (-not ([System.Management.Automation.PSTypeName]'Win32_VisualStudio').Type) {
			Add-Type @"
			using System;
			using System.Runtime.InteropServices;
			public class Win32_VisualStudio {
				[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
				[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
				[DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
			}
"@
		}

		$hwnd = $running.MainWindowHandle
		if ([Win32]::IsIconic($hwnd)) {
			[Win32]::ShowWindow($hwnd, 9)  # SW_RESTORE only if minimized
			[Win32]::SetForegroundWindow($hwnd)
		}
	}
	else {
		# C:\Program Files\Microsoft Visual Studio\18\Professional\Common7\IDE
		# in path
		& "devenv.exe" $abs
	}
}