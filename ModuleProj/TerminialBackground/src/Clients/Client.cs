using System.IO;
using System.Management.Automation;
using System.Text.Json;
using Metaseed.TerminalBackground.Communication;

namespace Metaseed.TerminalBackground
{
  public class Client
  {
    public static ICommandRuntime CommandRuntime;

    private readonly UdpClientConnection _client = new UdpClientConnection();

    public void StartCyclic(string settingsPath)
    {
      if (settingsPath == null) settingsPath = "";
      settingsPath = settingsPath.Trim('"', '\'');

      if (!string.IsNullOrEmpty(settingsPath) && !File.Exists(settingsPath))
      {
        CommandRuntime?.WriteVerbose($"'{settingsPath}' not exist.");
        if (CommandRuntime == null) Logger.Inst.Log($"'{settingsPath}' not exist.");
        return;
      }

      var p = JsonSerializer.Serialize(settingsPath);
      var data = $"{{\"command\":\"StartCyclic\", \"settingsPath\": {p}}}";
      // hide output from profile loading
      CommandRuntime?.WriteVerbose("send:" + data);
      if (CommandRuntime == null) Logger.Inst.Log("send:" + data);
      _client.Send(data);
    }

    public void StopCyclic()
    {
      var data = "{\"command\":\"StopCyclic\"}";
      _client.Send(data);
      CommandRuntime?.WriteVerbose("send:" + data);
      if (CommandRuntime == null) Logger.Inst.Log("send:" + data);
    }

    public void SetBackgroundImage(string profile, float durationInSeconds, string jsonProfileValueString)
    {
      var data = $"{{\"command\": \"SetBackgroundImage\", \"profile\":\"{profile}\", \"durationInSeconds\": {durationInSeconds}, \"jsonProfileValueString\": {jsonProfileValueString} }}";
      CommandRuntime?.WriteVerbose("send:" + data);
      if (CommandRuntime == null) Logger.Inst.Log("send:" + data);

      _client.Send(data);
    }

  }
}
