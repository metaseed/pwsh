using System.Management.Automation;
using Metaseed.TerminalBackground;

namespace TerminialBackground
{
    [Cmdlet("Start", "WTCyclicBgImg")]
    public class WTStartCyclicBackgroundImage : PSCmdlet
    {
        [Parameter(
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string SettingsPath { get; set; }
        
        protected override void EndProcessing()
        {
            Client.CommandRuntime = CommandRuntime;
            new Client().StartCyclic(SettingsPath);

        }
    }

}