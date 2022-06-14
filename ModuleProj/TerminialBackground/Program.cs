using System;
using System.CommandLine;
using System.Threading;
using System.Threading.Tasks;

namespace Metaseed.TerminalBackground
{
    public static class Program
    {
#if DEBUG
        static bool showConsole = true;
#else
        static bool showConsole = false;
#endif

        static Mutex  appMutex;
        private static Server server;
        [STAThread]
        [System.Diagnostics.DebuggerNonUserCode]
        public static async Task Main(string[] args)
        {
            appMutex = new Mutex(true, "WinTerminalBackgroundImage", out var notRunningYet);
            if (notRunningYet)
            {
                server = new Server();
            }
            var rootCommand = new RootCommand();
            rootCommand.SetHandler(() =>
            {
                Console.WriteLine("started and waiting for commands");
            });
            rootCommand.Add(new StartSubCommand());
            rootCommand.Add(new StopSubCommand());
            rootCommand.Add(new SetBackgroundImageSubCommand());
            await rootCommand.InvokeAsync(args);

            if (!notRunningYet) return;
            

            if (showConsole)
            {
                ShowConsole.ShowConsoleWindow();
            }
            new ManualResetEvent(false).WaitOne();

        }


    }
}