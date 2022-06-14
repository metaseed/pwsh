using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.PowerShell.Commands;

namespace Metaseed.TerminalBackground
{
    public static class WtBackgroundImage
    {
        static readonly CyclicBackground cyclicBackground = new CyclicBackground();

        public static void StartCyclic()
        {
            cyclicBackground.StartCyclic();
        }

        public static void SetBackgroundImage(string profile, int durationInSeconds, string jsonProfileValueString)
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
