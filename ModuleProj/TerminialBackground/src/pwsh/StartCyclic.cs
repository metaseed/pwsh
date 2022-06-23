using System;
using System.IO;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Text.Json.Nodes;
using Metaseed.TerminalBackground;
using Metaseed.TerminalBackground.Communication;

namespace TerminialBackground
{
    [Cmdlet("Start", "WTCyclicBgImg")]
    public class WTStartCyclicBackgroundImage : PSCmdlet
    {
        public WTStartCyclicBackgroundImage()
        {
        }
        [Parameter(
            Position                        = 0,
            ValueFromPipeline               = true,
            ValueFromPipelineByPropertyName = true)]
        public string SettingsPath { get; set; }
        protected override void EndProcessing()
        {
            Client.CommandRuntime = CommandRuntime;
            new Client().StartCyclic(SettingsPath);

        }
    }

}