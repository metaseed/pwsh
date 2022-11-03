# not work.
# use GDProps instead

# problems:
# 1. if not use remote session, the dialog show and disposed when the pwsh exits, we can add a sleep but just that length. one idea is to check the close
#     of the dialog and loops for sleep, but not tested
# 1. use remote session to avoid the pwsh process exit, but the ui shown is black
$s = Get-PSSession -ComputerName localhost -name ms_pwsh -ErrorAction Ignore
if (!$s) {
    $s = New-PSSession -Name ms_pwsh -ComputerName localhost | Disconnect-PSSession
}
if ($s.length -gt 1) { $s = $s[0] }

$s = connect-pssession $s
invoke-command -session $s -scriptblock {
    # https://stackoverflow.com/questions/1936682/how-do-i-display-a-files-properties-dialog-from-c
    $code = @"
using System.Runtime.InteropServices;
using System;

namespace HelloWorld
{
    public class Program
    {
        [DllImport("shell32.dll", CharSet = CharSet.Auto)]
        static extern bool ShellExecuteEx(ref SHELLEXECUTEINFO lpExecInfo);

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public struct SHELLEXECUTEINFO
        {
            public int cbSize;
            public uint fMask;
            public IntPtr hwnd;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpVerb;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpFile;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpParameters;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpDirectory;
            public int nShow;
            public IntPtr hInstApp;
            public IntPtr lpIDList;
            [MarshalAs(UnmanagedType.LPTStr)]
            public string lpClass;
            public IntPtr hkeyClass;
            public uint dwHotKey;
            public IntPtr hIcon;
            public IntPtr hProcess;
        }

        private const int SW_SHOW = 5;
        private const uint SEE_MASK_INVOKEIDLIST = 12;
        private const uint SEE_MASK_NOCLOSEPROCESS =0x40;

        public static bool ShowFileProperties(string Filename)
        {
            SHELLEXECUTEINFO info = new SHELLEXECUTEINFO();
            info.cbSize = System.Runtime.InteropServices.Marshal.SizeOf(info);
            info.lpVerb = "properties";
            info.lpFile = Filename;
            info.nShow = SW_SHOW;
            info.fMask = SEE_MASK_INVOKEIDLIST;
            var r = ShellExecuteEx(ref info);

            // System.Threading.Thread.Sleep(1000);
            return r;
        }
    }
}
"@
    if ($env:f) {
        $name = ($env:f).trim('"')
    }
    if (-not $ShowFileProperties) {
        Add-Type -TypeDefinition $code -Language CSharp
        $ShowFileProperties = $true
    }

    # $name = 'C:\Intel'
    # $p = [System.Diagnostics.Process]::GetCurrentProcess().Parent.Parent.Parent;
    # $p
    [HelloWorld.Program]::ShowFileProperties($name)
    [Threading.Thread]::Sleep(800)
}
# [Threading.Thread]::Sleep(5000)

Receive-PSSession -Name ps_pwsh -ComputerName localhost
Disconnect-PSSession  -Name ms_pwsh

# IntPtr ptr = IntPtr.Zero;

# var title = IsDirectory(sourcePath) ? new DirectoryInfo(sourcePath).Name : new FileInfo(sourcePath).Name;
# title += " Properties";
# while (ptr == IntPtr.Zero)
#     ptr = Helpers.FindWindow("#32770", title);

# Get-PSSession -ComputerName localhost -name ms_pwsh |Remove-PSSession