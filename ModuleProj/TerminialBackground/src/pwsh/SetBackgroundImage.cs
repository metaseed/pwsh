using System;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using Metaseed.TerminalBackground;

namespace TerminialBackground
{
    /// Test-SampleCmdlet 1 Cat
    [Cmdlet("Set", "WTBgImg")]
    //[OutputType(typeof(FavoriteStuff))]
    public class WTBackgroundImage : PSCmdlet
    {
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipelineByPropertyName = true)]
        public string Profile { get; set; }

        [Parameter(
            Position = 1,
            ValueFromPipelineByPropertyName = true)]
        //[ValidateSet("Cat", "Dog", "Horse")]
        public float DurationInSeconds { get; set; } = 6;

        [Parameter(
            Mandatory = true,
            Position = 2,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string JsonProfileValueString { get; set; }
        //protected override void BeginProcessing()
        //{
        //    WriteVerbose("Begin!");
        //}

        //protected override void ProcessRecord()
        //{
        //    //WriteObject(new FavoriteStuff { 
        //    //    FavoriteNumber = FavoriteNumber,
        //    //    FavoritePet = FavoritePet
        //    //});
        //}

        protected override void EndProcessing()
        {
            Client.HostUI = Host.UI;
            new Client().SetBackgroundImage(Profile, DurationInSeconds, JsonProfileValueString);
        }
    }

    //public class FavoriteStuff
    //{
    //    public int FavoriteNumber { get; set; }
    //    public string FavoritePet { get; set; }
    //}
}
