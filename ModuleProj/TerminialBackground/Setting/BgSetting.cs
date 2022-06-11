using System.IO;
using System.Text.Json.Nodes;

namespace Metaseed.TerminalBackground
{
    public class BgSetting
    {
        public static JsonObject GetBackgroundSettings()
        {
            using (var file = File.OpenRead(".\\settings.json"))
            {
                var settings = JsonNode.Parse(file).AsObject();
                return settings;
            }
        }
    }
}
