function Test-ProcessElevated {
  [CmdletBinding()]
  param (
      [Parameter()]
      [IntPtr]
      $ProcessHandle
  )
  # https://stackoverflow.com/questions/1220213/detect-if-running-as-administrator-with-or-without-elevated-privileges/17492949#answer-1220234
  # https://github.com/falahati/UACHelper
  # https://www.nuget.org/packages/UACHelper/
  $code = @"
  using System;
  using System.ComponentModel;
  using System.Runtime.ConstrainedExecution;
  using System.Runtime.InteropServices;
  using System.Security;
  using System.Security.Principal;

  public static class TestProcessElevated
  {

      const int MAXIMUM_ALLOWED = 25;
      [DllImport("kernel32.dll", SetLastError = true)]
      [return: MarshalAs(UnmanagedType.Bool)]
      static extern bool CloseHandle(IntPtr hObject);

      [DllImport("advapi32.dll", SetLastError = true)]
      [return: MarshalAs(UnmanagedType.Bool)]
      static extern bool OpenProcessToken(IntPtr processHandle,
          uint desiredAccess, out IntPtr tokenHandle);

      public static bool IsProcessElevated(IntPtr pHandle)
      {

          if (!OpenProcessToken(pHandle, MAXIMUM_ALLOWED, out var token))
              throw new Win32Exception(Marshal.GetLastWin32Error(), "OpenProcessToken failed");

          var identity = new WindowsIdentity(token);
          var principal = new WindowsPrincipal(identity);
          var result = principal.IsInRole(WindowsBuiltInRole.Administrator)
                       || principal.IsInRole(0x200); //Domain Administrator
          CloseHandle(token);
          return result;
      }
  }
"@
  if (!$TestProcessElevated) {
    Add-Type -TypeDefinition $code
    $TestProcessElevated = $true
  }

  [TestProcessElevated]::IsProcessElevated($ProcessHandle)

}

Get-Process -n explorer | % {Test-ProcessElevated $_.Handle}