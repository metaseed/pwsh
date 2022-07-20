using System;
using System.CommandLine;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;

namespace Metaseed.TerminalBackground
{
  public static class Program
  {
    [ModuleInitializer]
    internal static void StartServer()
    {
      Server.StartProcess();
    }
    static Mutex appSingletonMutex;

    private static EventWaitHandle handle;
    private static Server server;
    [STAThread]
    [System.Diagnostics.DebuggerNonUserCode]
    public static async Task Main(string[] args)
    {
      handle = new EventWaitHandle(false, EventResetMode.ManualReset, "WinTerminalBackgroundImageWaitHandle");

      appSingletonMutex = new Mutex(true, "WinTerminalBackgroundImage", out var notRunningYet);
      if (!notRunningYet)
      {
        Logger.Inst.Log("exit");
        return;
      }
      
      if (notRunningYet)
      {
        server = new Server();
      }
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
      handle.WaitOne();
      Console.WriteLine("exit!!!");

    }


  }

}
