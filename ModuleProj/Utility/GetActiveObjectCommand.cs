using System;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Runtime.InteropServices;
using System.Runtime.Versioning;
using System.Security;

namespace Utility
{
  [Cmdlet(VerbsCommon.Get, "ActiveComObject")]
  public class GetActiveComObjectCmdletCommand : PSCmdlet
  {
    [Parameter(
    Mandatory = true,
    Position = 0,
    ValueFromPipeline = true,
    ValueFromPipelineByPropertyName = true)]
    public string progID { get; set; }
    // This method gets called once for each cmdlet in the pipeline when the pipeline starts executing
    protected override void BeginProcessing()
    {
      WriteVerbose("Begin!");
    }

    // This method will be called for each input received from the pipeline to this cmdlet; if no input is received, this method is not called
    protected override void ProcessRecord()
    {
      var obj = Marshal2.GetActiveObject(progID);
      WriteObject(obj);
    }

    // This method will be called once at the end of pipeline execution; if no input is received, this method is not called
    protected override void EndProcessing()
    {
      WriteVerbose("End!");
    }
  }


  public static class Marshal2
  {
    internal const String OLEAUT32 = "oleaut32.dll";
    internal const String OLE32 = "ole32.dll";

    [System.Security.SecurityCritical]  // auto-generated_required
    public static Object GetActiveObject(String progID)
    {
      Object obj = null;
      Guid clsid;

      // Call CLSIDFromProgIDEx first then fall back on CLSIDFromProgID if
      // CLSIDFromProgIDEx doesn't exist.
      try
      {
        CLSIDFromProgIDEx(progID, out clsid);
      }
      //            catch
      catch (Exception)
      {
        CLSIDFromProgID(progID, out clsid);
      }

      GetActiveObject(ref clsid, IntPtr.Zero, out obj);
      return obj;
    }

    //[DllImport(Microsoft.Win32.Win32Native.OLE32, PreserveSig = false)]
    [DllImport(OLE32, PreserveSig = false)]
    [ResourceExposure(ResourceScope.None)]
    [SuppressUnmanagedCodeSecurity]
    [System.Security.SecurityCritical]  // auto-generated
    private static extern void CLSIDFromProgIDEx([MarshalAs(UnmanagedType.LPWStr)] String progId, out Guid clsid);

    //[DllImport(Microsoft.Win32.Win32Native.OLE32, PreserveSig = false)]
    [DllImport(OLE32, PreserveSig = false)]
    [ResourceExposure(ResourceScope.None)]
    [SuppressUnmanagedCodeSecurity]
    [System.Security.SecurityCritical]  // auto-generated
    private static extern void CLSIDFromProgID([MarshalAs(UnmanagedType.LPWStr)] String progId, out Guid clsid);

    //[DllImport(Microsoft.Win32.Win32Native.OLEAUT32, PreserveSig = false)]
    [DllImport(OLEAUT32, PreserveSig = false)]
    [ResourceExposure(ResourceScope.None)]
    [SuppressUnmanagedCodeSecurity]
    [System.Security.SecurityCritical]  // auto-generated
    private static extern void GetActiveObject(ref Guid rclsid, IntPtr reserved, [MarshalAs(UnmanagedType.Interface)] out Object ppunk);

  }
}
