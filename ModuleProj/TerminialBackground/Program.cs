using System;
namespace Metaseed.TerminalBackground
{
    public static class Program
    {

        [STAThread]
        [System.Diagnostics.DebuggerNonUserCode]
        public static int Main(string[] args)

        {
            var settings = new Setting();
            var s = settings.GetSettings();
            s["profiles"]["defaults"]["name"] = "test";
            settings.SetSettings(s);
            return 1;
        }
    }
}