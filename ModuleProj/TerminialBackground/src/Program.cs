using System;
using System.CommandLine;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Threading.Tasks;

namespace Metaseed.TerminalBackground
{
  public static class Program
  {
    [ModuleInitializer] // auto start when the module is loaed, i.e. when loaded by pwsh cmdlet or command line
    internal static void StartServer()
    {
      Server.StartProcess();
    }
    
    static Mutex appSingletonMutex;

    private static EventWaitHandle handle = new EventWaitHandle(false, EventResetMode.ManualReset, "WinTerminalBackgroundImageWaitHandle");
    private static Server server;
    [STAThread]
    [System.Diagnostics.DebuggerNonUserCode]
    public static async Task Main(string[] args)
    {
      appSingletonMutex = new Mutex(true, "WinTerminalBackgroundImage", out var notRunningYet);
      if (!notRunningYet)
      {
        Logger.Inst.Log("another instance is running, exit!");
        return;
      }

      if (notRunningYet)
      {
        server = new Server();
      }
      /// command line commands
      var rootCommand = new RootCommand();
      rootCommand.SetHandler(() =>
      {
        Logger.Inst.Log("started and waiting for commands");
      });

      rootCommand.Add(new StartSubCommand());
      rootCommand.Add(new StopSubCommand());
      rootCommand.Add(new SetBackgroundImageSubCommand());
      await rootCommand.InvokeAsync(args);

#if !DEBUG
     ShowConsole.HideConsoleWindow();
#endif

      Logger.Inst.Log("started!");
      handle.WaitOne(); // block the exit
      Console.WriteLine("exit!!!");

    }


  }

}
