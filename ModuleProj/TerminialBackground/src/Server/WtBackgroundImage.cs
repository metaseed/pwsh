using System.Threading.Tasks;

namespace Metaseed.TerminalBackground
{
    public class WtBackgroundImage
    {
        readonly CyclicWTBackground cyclicBackground = new();

        public void StartCyclic(string settingsPath)
        {
            cyclicBackground.StartCyclic(settingsPath);
        }

        public async void StopCyclic()
        {
            await cyclicBackground.StopCyclic();
        }

        /// <summary>
        /// finish the ongoing gif
        /// </summary>
        TaskCompletionSource<object> completionSource;
        Task setImageTask;
        public async void SetBackgroundImage(string profile, float durationInSeconds, string jsonProfileValueString)
        {
            if (setImageTask != null && !setImageTask.IsCompleted)
            {
                completionSource.SetResult(null);
                await setImageTask;
            }
            
            completionSource = new();
            setImageTask = Task.Run(async () =>
            {
                await cyclicBackground.SetBackgroundImage(profile, durationInSeconds, jsonProfileValueString, completionSource.Task);
            });

        }

    }
}
