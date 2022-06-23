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

            var dirPath = Path.GetDirectoryName(typeof(WTBackgroundImageInit).Assembly.Location);
            var exe = $"{dirPath}\\TerminalBackground.exe";
            var proc = new Process
            {
                StartInfo = new ProcessStartInfo()
                {
                    FileName         = exe,
                    UseShellExecute  = true,
                    CreateNoWindow   = true,
                    WindowStyle = ProcessWindowStyle.Hidden,
                    WorkingDirectory = dirPath
                }
            };

            proc.Start();

        }
    }
}
