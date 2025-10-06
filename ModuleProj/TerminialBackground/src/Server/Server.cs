using System;
using System.Diagnostics;
using System.IO;
using System.Text.Json.Nodes;
using Metaseed.TerminalBackground.Communication;

namespace Metaseed.TerminalBackground
{
  public class Server : IDisposable
  {
    public static void StartProcess()
    {
        var name = Process.GetCurrentProcess().MainModule.FileName;
    // Logger.Inst.Log($"main module {name}");
    // main module C:\Program Files\PowerShell\7\pwsh.exe
    // main module M:\Script\Pwsh\Module\Metaseed.Terminal\_bin\TerminalBackground.exe
      if(name.EndsWith("TerminalBackground.exe")) {
        return;
      }
        
      var assembly = typeof(Server).Assembly;
      var dirPath = Path.GetDirectoryName(assembly.Location);
      var exe = $"{dirPath}\\TerminalBackground.exe";
      var proc = new Process
      {
        StartInfo = new ProcessStartInfo()
        {
          FileName = exe,
          UseShellExecute = true,
          CreateNoWindow = true,
          WindowStyle = ProcessWindowStyle.Hidden,
          WorkingDirectory = dirPath
        }
      };

      proc.Start();
    }
    private readonly UdpServerConnection udpConnection = new();
    private WtBackgroundImage backgroundImage = new();
    public Server()
    {
      udpConnection.Open();
      Logger.Inst.Log("Server started");
      
      udpConnection.Received += (sender, args) =>
      {
        Logger.Inst.Log($"received:{args.Data}");
        var data = JsonNode.Parse(args.Data);
        var command = data["command"].GetValue<string>();
        if (command == "StartCyclic")
        {
          var settingsPath = data["settingsPath"].GetValue<string>();
          backgroundImage.StartCyclic(settingsPath);
        }
        else if (command == "StopCyclic")
        {
          backgroundImage.StopCyclic();
        }
        else if (command == "SetBackgroundImage")
        {
          var profile = data["profile"].GetValue<string>();
          var durationInSeconds = data["durationInSeconds"].GetValue<float>();
          var jsonProfileValueString = data["jsonProfileValueString"].ToJsonString();
          backgroundImage.SetBackgroundImage(profile, durationInSeconds, jsonProfileValueString);
        }

      };
    }

    public void Dispose()
    {
      udpConnection.Close();
    }
  }
}
