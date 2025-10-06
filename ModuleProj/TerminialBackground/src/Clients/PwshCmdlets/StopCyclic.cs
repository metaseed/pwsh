using System.Management.Automation;
using Metaseed.TerminalBackground;

namespace TerminialBackground
{
    [Cmdlet("Stop", "WTCyclicBgImg")]
    public class WTStopCyclicBackgroundImage : PSCmdlet
    {
        protected override void EndProcessing()
        {
            Client.CommandRuntime = CommandRuntime;
            new Client().StopCyclic();
        }
    }

}