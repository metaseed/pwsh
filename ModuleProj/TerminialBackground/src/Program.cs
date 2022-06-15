using System;
using System.CommandLine;
using System.Text.Json;
using System.Text.Json.Nodes;
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

        static         Mutex           appMutex;
        private static EventWaitHandle handle;
        private static Server          server;
        [STAThread]
        [System.Diagnostics.DebuggerNonUserCode]
        public static async Task Main(string[] args)
        {
            //var a = "\"abc def\"";
            //a      = a.Trim('\'', '"');
            handle = new EventWaitHandle(false, EventResetMode.ManualReset, "WinTerminalBackgroundImageWaitHandle");

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

            if (!notRunningYet)
            {
                Console.WriteLine("exit");
                return;
            }
            

            //if (showConsole)
            //{
            //    ShowConsole.ShowConsoleWindow();
            //}
                handle.WaitOne();
                Console.WriteLine("exit!!!");
            //new ManualResetEvent(false).WaitOne();

        }


    }
}