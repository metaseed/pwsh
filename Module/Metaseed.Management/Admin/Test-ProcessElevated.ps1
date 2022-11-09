
function Test-ProcessElevated {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ParameterSetName = 'processid', ValueFromPipeline)]
        [IntPtr[]]
        $ProcessHandles,
        [Parameter(Position = 0, ParameterSetName = 'process',ValueFromPipeline)]
        [System.Diagnostics.Process[]]
        $Processes
    )

    process {
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

      const UInt32 MAXIMUM_ALLOWED = 25;
      const UInt32 TOKEN_QUERY = 0x0008;
      [DllImport("kernel32.dll", SetLastError = true)]
      [return: MarshalAs(UnmanagedType.Bool)]
      static extern bool CloseHandle(IntPtr hObject);

      [DllImport("advapi32.dll", SetLastError = true)]
      [return: MarshalAs(UnmanagedType.Bool)]
      static extern bool OpenProcessToken(IntPtr processHandle,
          uint desiredAccess, out IntPtr tokenHandle);

      // https://learn.microsoft.com/en-us/windows/win32/api/winnt/ne-winnt-token_information_class
      enum TOKEN_INFORMATION_CLASS
      {
          TokenUser = 1,
          TokenGroups,
          TokenPrivileges,
          TokenOwner,
          TokenPrimaryGroup,
          TokenDefaultDacl,
          TokenSource,
          TokenType,
          TokenImpersonationLevel,
          TokenStatistics,
          TokenRestrictedSids,
          TokenSessionId,
          TokenGroupsAndPrivileges,
          TokenSessionReference,
          TokenSandBoxInert,
          TokenAuditPolicy,
          TokenOrigin,
          TokenElevationType
      }
      enum TOKEN_ELEVATION_TYPE
      {
          TokenElevationTypeDefault = 1,
          TokenElevationTypeFull,
          TokenElevationTypeLimited
      }

      [DllImport("advapi32.dll", SetLastError = true)]
      static extern bool GetTokenInformation(
          IntPtr tokenHandle,
          TOKEN_INFORMATION_CLASS tokenInformationClass,
          IntPtr tokenInformation,
          int tokenInformationLength,
          out int returnLength);

      public static bool IsProcessElevated(IntPtr pHandle)
      {

          if (!OpenProcessToken(pHandle, TOKEN_QUERY, out var token))
              throw new Win32Exception(Marshal.GetLastWin32Error(), "OpenProcessToken failed");
          var tokenInfoLength = 4;
          //var tokenInfoLength = 0;
          //GetTokenInformation(token, TOKEN_INFORMATION_CLASS.TokenElevationType, IntPtr.Zero, tokenInfoLength, out tokenInfoLength);
          var tokenInformation = Marshal.AllocHGlobal(tokenInfoLength);
          //Console.Write(tokenInfoLength);
          var result = GetTokenInformation(token, TOKEN_INFORMATION_CLASS.TokenElevationType, tokenInformation, tokenInfoLength, out tokenInfoLength);
          if (!result)
          {
              throw new Win32Exception(Marshal.GetLastWin32Error(), "GetTokenInformation failed");
          }

          var v = Marshal.ReadInt32(tokenInformation);
          //Console.WriteLine(v);
          return v == (int)TOKEN_ELEVATION_TYPE.TokenElevationTypeFull;
      }

  }
"@
    $yes =  Get-Variable -Scope Global -Name TestProcessElevated -ValueOnly -ErrorAction Ignore
        if (!$yes) {
            Add-Type -TypeDefinition $code
            $global:TestProcessElevated = $true
        }

        if ($pscmdlet.parametersetname -eq 'process') {
            $ProcessHandles = $processes.Handle
        }

        foreach($ProcessHandle in $ProcessHandles) {
            [TestProcessElevated]::IsProcessElevated($ProcessHandle)
        }
    }
}

# Get-Process -n slack | % {Test-ProcessElevated $_.Handle}