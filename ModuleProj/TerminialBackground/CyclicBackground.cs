using System;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Threading.Tasks;

namespace Metaseed.TerminalBackground
{
    public  class CyclicBackground
    {
        private readonly JsonObject _wtSettings;
        private readonly JsonObject _bgSettings;
        private readonly int        _duration;
        private readonly WtSetting  _settings;

        public CyclicBackground()
        {
            _settings   = new WtSetting();
            _wtSettings = _settings.GetSettings();
            _bgSettings = BgSetting.GetBackgroundSettings();
            _duration   = _bgSettings["duration"]?.GetValue<int?>() ?? WtSetting.DefaultDuration;
        }
        public async Task  Start()
        {
            var     wtProfile = _wtSettings["profiles"]?["defaults"];
                var bgProfile = _bgSettings["defaults"];
                CyclicBackground.ModifyProfile(bgProfile, wtProfile);

                var wtList = _wtSettings["profiles"]?["list"]?.AsArray();
                var bgList = _bgSettings["list"]?.AsObject();
                foreach (var (key, bgListProfile) in bgList)
                {
                    var wtListProfile = wtList.FirstOrDefault(list => list["name"]?.GetValue<string>() == key);
                    if (wtListProfile != null)
                    {
                        ModifyProfile(bgListProfile, wtListProfile);
                    }
                }

                _settings.SetSettings(_wtSettings);
                await Task.Delay(_duration * 1000);
        
        }
        private static void ModifyProfile(JsonNode bgProfile, JsonNode wtProfile)
        {
            var bgBackgrounds = bgProfile["backgrounds"].AsArray();
            if (bgBackgrounds.Count == 0) return;

            var random = bgProfile["random"]?.GetValue<bool>() ?? false;

            var index = bgProfile["usedIndex"]?.GetValue<int>() ?? -1;

            if (random)
            {
                int va;
                do
                {
                    va = new Random().Next(0, bgBackgrounds.Count);
                } while (va == index);

                index = va;
            }
            else
            {
                index = index + 1;
                if (index >= bgBackgrounds.Count) index = 0;
            }

            bgProfile["usedIndex"] = index;

            var bgDefault = bgBackgrounds[index];
            foreach (var (key, value) in bgDefault.AsObject())
            {
                var v = value.Deserialize<JsonNode>();
                wtProfile[key] = v;
            }
        }
    }
}