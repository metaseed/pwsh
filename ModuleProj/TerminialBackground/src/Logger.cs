using System;
using System.IO;

namespace Metaseed.TerminalBackground
{
  public class Logger
  {
    public static Logger Inst = new Logger(Path.Combine(Environment.GetEnvironmentVariable("temp"), "TerminalBackground_" + DateTime.Now.ToString("yyyy-MM-dd") + "_log.txt"));
    private string filePath;
    private static object _lock = new();
    public Logger(string path)
    {
      filePath = path;
      Console.WriteLine($"the log file: {path}");
    }

    public void Log(string message, Exception exception = null)
    {
      Console.WriteLine(message + exception?.ToString());

      lock (_lock)
      {
        var newline = Environment.NewLine;
        string exc = "";
        if (exception != null)
          exc = newline + "error: " + exception.GetType() + ": " + exception.Message +
                newline + exception.StackTrace + newline;
                
        File.AppendAllText(filePath, DateTime.Now + " " + message + newline + exc);
      }
    }
  }
}
