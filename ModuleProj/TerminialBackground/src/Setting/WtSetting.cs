using System.Text.Json;
using System;
using System.IO;
using System.Text.Json.Nodes;
using System.Text.Encodings.Web;

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
            string Unpackaged = @$"{appDir}\Microsoft\Windows Terminal\settings.json"; // Scoop, Chocolately, etc;
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
                var error = "can not find installed terminal";
                var ex = new Exception(error);
                Logger.Inst.Log(error, ex);
                throw ex;
            }
        }

        public JsonObject GetSettings()
        {
            using (var file = File.OpenRead(Path))
            {
                var settings = JsonNode.Parse(file).AsObject();
                return settings;
            }
        }

        public void SetSettings(JsonObject settings)
        {
            var options = new JsonSerializerOptions { WriteIndented = true,
            // prevent:  + into \u002B in keybindings, i.e. ctrl+1 should not be ctrl\u002B1
             Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping };
             File.WriteAllText(Path, settings.ToJsonString(options));
        }
    }
}