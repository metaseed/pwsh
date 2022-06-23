using System;
using System.IO;

namespace Metaseed.TerminalBackground
{
    public class Logger
    {
        public static Logger Inst = new Logger(Environment.GetEnvironmentVariable("temp"));
        private string filePath;
        private static object _lock = new object();
        public Logger(string path)
        {
            filePath = path;
        }

        public void Log(string message, Exception exception = null)
        {
            Console.WriteLine(message + exception?.ToString());

            lock (_lock)
            {
                string fullFilePath = Path.Combine(filePath, "TerminalBackground_"+ DateTime.Now.ToString("yyyy-MM-dd") + "_log.txt");
                var n = Environment.NewLine;
                string exc = "";
                if (exception != null) exc = n + exception.GetType() + ": " + exception.Message + n + exception.StackTrace + n;
                File.AppendAllText(fullFilePath, DateTime.Now.ToString() + " " + message + n + exc);
            }
        }
    }
}
