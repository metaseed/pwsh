using System.IO;
using System.Text.Json.Nodes;

namespace Metaseed.TerminalBackground
{
    public class BgSetting
    {
        public static JsonObject GetBackgroundSettings(string settingsPath)
        {
            if (string.IsNullOrEmpty(settingsPath))
            {
                settingsPath = ".\\settings.json";
            }
            using (var file = File.OpenRead(settingsPath))
            {
                var settings = JsonNode.Parse(file).AsObject();
                return settings;
            }
        }
    }
}
