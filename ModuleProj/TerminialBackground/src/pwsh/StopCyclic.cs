using System;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using Metaseed.TerminalBackground;

namespace TerminialBackground
{
    [Cmdlet("Stop", "WTCyclicBgImg")]
    public class WTStopCyclicBackgroundImage : PSCmdlet
    {
        protected override void EndProcessing()
        {
            Client.HostUI = Host.UI;

            new Client().StopCyclic();
        }
    }

}