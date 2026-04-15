function Show-Window {
	param([System.IntPtr]$hWnd)

	if (-not ([System.Management.Automation.PSTypeName]'Win32_RaiseWindow').Type) {
		Add-Type @"
			using System;
			using System.Runtime.InteropServices;
			public class Win32_RaiseWindow {
				[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
				[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
				[DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
				[DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
				 [DllImport("user32.dll")] public static extern int  GetWindowThreadProcessId(IntPtr hWnd, out int lpdwProcessId);
    			[DllImport("kernel32.dll")] public static extern int  GetCurrentThreadId();
    			[DllImport("user32.dll")] public static extern bool AttachThreadInput(int idAttach, int idAttachTo, bool fAttach);
    			[DllImport("user32.dll")] public static extern bool AllowSetForegroundWindow(int dwProcessId);
			}
"@
	}

	if ([Win32_RaiseWindow]::IsIconic($hwnd)) {
		# is minimized
		[Win32_RaiseWindow]::ShowWindow($hwnd, 3) | Out-Null  # 9:SW_RESTORE, 3: SW_MAXIMIZE, 1: SW_SHOWNORMAL
	}
	$targetTid = [Win32_RaiseWindow]::GetWindowThreadProcessId($hWnd, [ref]0)
	$selfTid = [Win32_RaiseWindow]::GetCurrentThreadId()
	[Win32_RaiseWindow]::BringWindowToTop($hWnd) | Out-Null
	[Win32_RaiseWindow]::SetForegroundWindow($hwnd) | Out-Null
	[Win32_RaiseWindow]::AttachThreadInput($selfTid, $targetTid, $false) | Out-Null
}