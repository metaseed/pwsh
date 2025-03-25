using System.Management.Automation;
using Metaseed.TerminalBackground;

namespace TerminialBackground
{
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
            
            Client.CommandRuntime = CommandRuntime;
            new Client().SetBackgroundImage(Profile, DurationInSeconds, JsonProfileValueString);
        }
    }
}
