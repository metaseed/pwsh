using System.Diagnostics;
using System.IO;
using System.Management.Automation;

namespace Metaseed.TerminalBackground.src.pwsh
{
    [Cmdlet("Initialize", "WTBgImg")]
    public class WTBackgroundImageInit : PSCmdlet
    {
        protected override void EndProcessing()
        {
            Client.CommandRuntime = CommandRuntime;

            var dir = Path.GetDirectoryName(typeof(WTBackgroundImageInit).Assembly.Location);
            var exe = $"{dir}\\TerminalBackground.exe";
            var proc = new Process
            {
                StartInfo = new ProcessStartInfo()
                {
                    FileName         = exe,
                    UseShellExecute  = true,
                    CreateNoWindow   = true,
                    WindowStyle      = ProcessWindowStyle.Hidden,
                    WorkingDirectory = dir
                }
            };

            proc.Start();

        }
    }
}
