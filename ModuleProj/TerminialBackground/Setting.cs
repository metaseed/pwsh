using System.Text.Json;
using System.Text.Json.Serialization;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json.Nodes;

namespace Metaseed.TerminalBackground
{
    //public interface IProfile
    //{
    //  string guid { get; set; }
    //  bool hidden { get; set; }
    //  string name { get; set; }
    //  string backgroundImage { get; set; }
    //  string backgroundImageAlignment { get; set; }
    //  string backgroundImageOpacity   { get; set; }
    //  string backgroundImageStretchMode { get; set; }
    //  string opacity {get;set;}
    //  bool useAcrylic { get; set; }
    //}
    //public interface IProfiles
    //{
    //  IProfile defaults { get; set; }
    //  IProfile[] list { get; set; }
    //}
    //public interface ISetting
    //{
    //  IProfiles profiles { get; set; }
    //}
    public class Setting
    {
        public string Path = null;

        public Setting()
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
            //using (var file = File.Create("C:\\Users\\metaseed\\OneDrive\\Documents/1.json"))
            //{
            //    var options = new JsonSerializerOptions { WriteIndented = true };
            //          JsonSerializer.Serialize(file, settings,options);
            //}
        }
    }
}