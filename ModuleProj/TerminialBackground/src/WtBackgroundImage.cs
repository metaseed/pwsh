using System.Threading.Tasks;

namespace Metaseed.TerminalBackground
{
    public class WtBackgroundImage
    {
        readonly CyclicBackground cyclicBackground = new CyclicBackground();

        public  void StartCyclic(string settingsPath)
        {
            cyclicBackground.StartCyclic(settingsPath);
        }

        public  void SetBackgroundImage(string profile, float durationInSeconds, string jsonProfileValueString)
        {
            Task.Run(async () =>
            {
                await cyclicBackground.SetBackgroundImage(profile, durationInSeconds, jsonProfileValueString);
            });
        }

        public  void StopCyclic()
        {
            cyclicBackground.StopCyclic();
        }
    }
}
