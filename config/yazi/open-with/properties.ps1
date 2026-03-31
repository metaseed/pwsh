param([string]$path)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class ShellProps {
    [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
    public static extern bool SHObjectProperties(IntPtr hwnd, uint shopObjectType, string pszObjectName, string pszPropertyPage);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr FindWindowW(string lpClassName, string lpWindowName);
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool IsWindow(IntPtr hWnd);
    public const uint SHOP_FILEPATH = 0x2;
}
"@

$title = "$(Split-Path -Leaf $path) Properties"
$existing = [ShellProps]::FindWindowW('#32770', $title)

[ShellProps]::SHObjectProperties([IntPtr]::Zero, [ShellProps]::SHOP_FILEPATH, $path, $null)

if ($existing -ne [IntPtr]::Zero) { return }

$hwnd = [IntPtr]::Zero
while ($hwnd -eq [IntPtr]::Zero) {
    Start-Sleep -Milliseconds 100
    $hwnd = [ShellProps]::FindWindowW('#32770', $title)
}
while ([ShellProps]::IsWindow($hwnd)) {
    Start-Sleep -Milliseconds 200
}

# [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
# [System.Windows.Forms.MessageBox]::Show("Properties dialog closed.`nTitle searched: $title", 'Debug')