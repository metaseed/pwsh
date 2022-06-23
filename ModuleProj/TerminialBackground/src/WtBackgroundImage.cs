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

        /// <summary>
        /// finish the ongoing gif
        /// </summary>
        TaskCompletionSource<object> completionSource;
        Task setImageTask;
        public  async void SetBackgroundImage(string profile, float durationInSeconds, string jsonProfileValueString)
        {
            if(setImageTask !=null && !setImageTask.IsCompleted)
            {
                completionSource.SetResult(null);
                await setImageTask;
            }
            completionSource = new TaskCompletionSource<object>();
            setImageTask = Task.Run(async () =>
            {
                await cyclicBackground.SetBackgroundImage(profile, durationInSeconds, jsonProfileValueString, completionSource.Task);
            });

        }

        public  void StopCyclic()
        {
            cyclicBackground.StopCyclic();
        }
    }
}
