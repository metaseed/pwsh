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
        static readonly CyclicBackground cyclicBackground = new CyclicBackground();
        [STAThread]
        [System.Diagnostics.DebuggerNonUserCode]
        public static async Task Main(string[] args)
        {
            // var rootCommand = new RootCommand();
            // rootCommand.SetHandler(async (string[] arg) =>
            // {
            //   Console.WriteLine("start");
            //   new Timer(async (object state) =>
            //   {
            //     await Task.Delay(5000);
            //     Console.WriteLine("tick");
            //   }, null, 0, 1000);

            // });
            // var option = new Option("--verbose");
            // option.AddAlias("-v");
            // rootCommand.Add(option);
            //  await rootCommand.InvokeAsync(args);

            // rootCommand.Add(new ConfigCommand()); 
            while (true)
            {
                await cyclicBackground.Start();
            }

        }
    }
}