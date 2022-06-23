using System.Text.Json;
using System;
using System.IO;
using System.Text.Json.Nodes;

namespace Metaseed.TerminalBackground
{
    public class WtSetting
    {
        public static int DefaultDuration = 5;
        public string Path = null;

        public WtSetting()
        {
            string appDir = Environment.GetEnvironmentVariable("LocalAppData");
            string Stable = @$"{appDir}\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json";
            string Preview = @$"{appDir}\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json";
            string Unpackaged = @$"{appDir}\Microsoft\Windows Terminal\settings.json"; // Scoop, Chocolately, etc);
            if (File.Exists(Stable))
            {
                Path = Stable;

            }
            else if (File.Exists(Preview))
            {
                Path = Preview;
            }
            else if (File.Exists(Unpackaged))
            {
                Path = Unpackaged;
            }

            if (Path == null)
            {
                throw new Exception("can not find installed terminal");
            }

        }

        public JsonObject GetSettings()
        {
            using (var file = File.OpenRead(this.Path))
            {
                var settings = JsonNode.Parse(file).AsObject();
                return settings;
            }
        }

        public void SetSettings(JsonObject settings)
        {
            var options = new JsonSerializerOptions { WriteIndented = true };
             File.WriteAllText(Path, settings.ToJsonString(options));
        }
    }
}