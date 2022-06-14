using System.Threading.Tasks;

namespace Metaseed.TerminalBackground
{
    public static class WtBackgroundImage
    {
        static readonly CyclicBackground cyclicBackground = new CyclicBackground();

        public static void StartCyclic()
        {
            cyclicBackground.StartCyclic();
        }

        public static void SetBackgroundImage(string profile, float durationInSeconds, string jsonProfileValueString)
        {
            Task.Run(async () =>
            {
                await cyclicBackground.SetBackgroundImage(profile, durationInSeconds, jsonProfileValueString);
            });
        }

        public static void StopCyclic()
        {
            cyclicBackground.StopCyclic();
        }
    }
}
