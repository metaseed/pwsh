using System;
using System.Collections.Generic;
using System.CommandLine;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Threading;
using System.Threading.Tasks;

namespace Metaseed.TerminalBackground
{
    public static class Program
    {
        static Mutex appMutex;
        static readonly CyclicBackground cyclicBackground = new CyclicBackground();
        [STAThread]
        [System.Diagnostics.DebuggerNonUserCode]
        public static async Task Main(string[] args)
        {
            bool notRunningYet;
            appMutex = new Mutex(true, "WinTerminalBackgroundImage", out notRunningYet);

            var rootCommand = new RootCommand();
            rootCommand.SetHandler(async (string[] arg) =>
            {
                Console.WriteLine("start");
               

            });
            // var option = new Option("--verbose");
            // option.AddAlias("-v");
            // rootCommand.Add(option);
            //  await rootCommand.InvokeAsync(args);

            // rootCommand.Add(new ConfigCommand()); 

            while (true)
            {
                await cyclicBackground.Run();
            }

        }
    }
}