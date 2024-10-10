Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Win32 {
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        [DllImport("user32.dll")]
        public static extern bool IsIconic(IntPtr hWnd);

        [DllImport("user32.dll")]
        public static extern int SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    }
"@

function Show-AppWindow {
	param (
		# application name
		[Parameter()]
		[string]
		$ApplicationName
	)

	$processes = Get-Process $ApplicationName -ErrorAction SilentlyContinue
	if ($processes) {
		$processes | % {
			$process = $_
			$hwnd = $process.MainWindowHandle
			# $process
			if ($hwnd -ne [IntPtr]::Zero) {
				# Check if the window is minimized
				if ([Win32]::IsIconic($hwnd)) {
					[void][Win32]::ShowWindow($hwnd, 9) # 9 = SW_RESTORE
				}

				# Try to set foreground window
				if (-not [Win32]::SetForegroundWindow($hwnd)) {
					# If SetForegroundWindow fails, try to force it
					[void][Win32]::ShowWindow($hwnd, 6) # 6 = SW_MINIMIZE
					[void][Win32]::ShowWindow($hwnd, 9) # 9 = SW_RESTORE
				}

				# Send a WM_SYSCOMMAND message to force activation
				[void][Win32]::SendMessage($hwnd, 0x0112, 0xF120, 0) # 0x0112 = WM_SYSCOMMAND, 0xF120 = SC_RESTORE

				Write-Host "bring $($process.ProcessName) to foreground."
			}
			else {
				Write-Warning "The process $($process.ProcessName) does not have a main window handle."
			}
		}
	}
	else {
		Write-Warning "No process found with the name '$ApplicationName'"
	}
}

# Show-AppWindow *pdf24*