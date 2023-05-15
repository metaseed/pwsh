using System;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace Metaseed.PowerShell.Management
{

    [Cmdlet(VerbsLifecycle.Invoke,"NonAdmin")]
    public class ManagementCmdletCommand : PSCmdlet
    {
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string Process { get; set; }

        [Parameter(
            Position = 1,
            ValueFromPipelineByPropertyName = true)]
        public string Arguments { get; set; } = "";

                [Parameter(
            Position = 2,
            ValueFromPipelineByPropertyName = true)]
        public string Directory { get; set; } = "";

        // // This method gets called once for each cmdlet in the pipeline when the pipeline starts executing
        // protected override void BeginProcessing()
        // {
        //     WriteVerbose("Begin!");
        // }

        // This method will be called for each input received from the pipeline to this cmdlet; if no input is received, this method is not called
        protected override void ProcessRecord()
        {
            if(String.IsNullOrEmpty(Directory)) Directory = System.IO.Directory.GetCurrentDirectory();
            SystemUtility.ExecuteProcessUnElevated(Process, Arguments, Directory);
        }

        // // This method will be called once at the end of pipeline execution; if no input is received, this method is not called
        // protected override void EndProcessing()
        // {
        //     WriteVerbose("End!");
        // }
    }
}
