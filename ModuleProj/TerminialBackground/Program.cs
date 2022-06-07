using System;
using System.CommandLine;
using System.Threading;
using System.Threading.Tasks;

namespace Metaseed.TerminalBackground
{
  public static class Program
  {

    [STAThread]
    [System.Diagnostics.DebuggerNonUserCode]
    public static async Task Main(string[] args)
    {
      var rootCommand = new RootCommand();
      rootCommand.SetHandler(async (string[] arg) =>
      {
        Console.WriteLine("start");
        new Timer(async (object state) =>
        {
          await Task.Delay(5000);
          Console.WriteLine("tick");
        }, null, 0, 1000);
        
      });
      var option = new Option("--verbose");
      option.AddAlias("-v");
      rootCommand.Add(option);
      // rootCommand.Add(new ConfigCommand()); 
       await rootCommand.InvokeAsync(args);
      // var settings = new Setting();
      // var s = settings.GetSettings();
      // // s["profiles"]["defaults"]["name"] = "test";
      // settings.SetSettings(s);
      // return 1;
    }
  }
}