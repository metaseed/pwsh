using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Threading;
using System.Threading.Tasks;

namespace Metaseed.TerminalBackground
{
    public class CyclicBackground
    {
        private readonly JsonObject _wtSettings;
        private JsonObject _bgSettings;
        private int _duration;
        private readonly WtSetting _settings;
        public bool IsStarted = false;
        private CancellationTokenSource cyclicTocken = new CancellationTokenSource();

        public CyclicBackground()
        {
            _settings = new WtSetting();
            _wtSettings = _settings.GetSettings();
        }

        public void StartCyclic(string settingsPath)
        {
            if (IsStarted)
            {
                Console.WriteLine("already started, no action this time");
                return;
            }
            _bgSettings = BgSetting.GetBackgroundSettings(settingsPath);
            _duration = _bgSettings["duration"]?.GetValue<int?>() ?? WtSetting.DefaultDuration;
            Task.Run(async () =>
            {
                while (true)
                {
                    await Run(cyclicTocken.Token);
                    Console.WriteLine("cyclically background changed");
                }
            }, cyclicTocken.Token);
            IsStarted = true;
        }

        private async Task Run(CancellationToken token)
        {
            var wtProfile = findWtProfile("defaults");
            var bgProfile = _bgSettings["defaults"];
            ModifyProfile(bgProfile, wtProfile);

            var bgList = _bgSettings["list"]?.AsObject();
            foreach (var (key, bgListProfile) in bgList)
            {
                var wtListProfile = findWtProfile(key);
                if (wtListProfile != null)
                {
                    ModifyProfile(bgListProfile, wtListProfile);
                }
            }

            _settings.SetSettings(_wtSettings);
            await Task.Delay(_duration * 1000, token);
        }

        public void StopCyclic()
        {
            if (!IsStarted)
            {
                Console.WriteLine("already stopped, no action this time");

                return;
            }
            IsStarted = false;
            cyclicTocken.Cancel();
            cyclicTocken = new CancellationTokenSource();
        }

        public async Task SetBackgroundImage(string profile, float durationInSeconds, string jsonProfile)
        {
            try
            {
                var wtProfile = findWtProfile(profile);
                var bgProfile = findBgProfile(profile);
                var bgBackground = JsonNode.Parse(jsonProfile);
                bgProfile["_explicitSet"] = true;
                var wtProfileBackup = wtProfile.Deserialize<JsonNode>();
                var keyToRemove = new List<string>();
                foreach (var (key, value) in bgBackground.AsObject())
                {
                    if (wtProfile[key] == null)
                    {
                        keyToRemove.Add(key);
                    }
                }
                SetProfileValue(bgBackground, wtProfile);
                _settings.SetSettings(_wtSettings);
                await Task.Delay((int)Math.Floor(durationInSeconds * 1000));
                bgProfile["_explicitSet"] = false;

                foreach (var key in keyToRemove)
                {
                    wtProfile.AsObject().Remove(key);
                }
                SetProfileValue(wtProfileBackup, wtProfile);
                var index = bgProfile["_usedIndex"]?.GetValue<int>() ?? -1;
                if (index != -1)
                {
                    var valueToSet = bgProfile["backgrounds"].AsArray()[index];
                    SetProfileValue(valueToSet, wtProfile);
                }

                _settings.SetSettings(_wtSettings);
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
            }
        }

        private JsonNode findWtProfile(string name)
        {
            if (name == "defaults")
            {
                return _wtSettings["profiles"]?["defaults"];
            }
            else
            {
                var wtList = _wtSettings["profiles"]?["list"]?.AsArray();

                var wtListProfile = wtList?.FirstOrDefault(list => list["name"]?.GetValue<string>() == name);
                return wtListProfile;
            }
        }

        private JsonNode findBgProfile(string name)
        {
            if (name == "defaults")
            {
                return _bgSettings["defaults"];
            }
            else
            {
                var bgList = _bgSettings["list"]?.AsArray();

                var bgListProfile = bgList?.FirstOrDefault(list => list["name"]?.GetValue<string>() == name);
                return bgListProfile;
            }
        }

        private static void ModifyProfile(JsonNode bgProfile, JsonNode wtProfile)
        {
            var bgBackgrounds = bgProfile["backgrounds"].AsArray();
            if (bgBackgrounds.Count == 0) return;

            var random = bgProfile["random"]?.GetValue<bool>() ?? false;
            var setExplicitly = bgProfile["_explicitSet"]?.GetValue<bool>() ?? false;

            var index = bgProfile["_usedIndex"]?.GetValue<int>() ?? -1;

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

            bgProfile["_usedIndex"] = index;

            var bgBackground = bgBackgrounds[index];
            if (!setExplicitly) // modified by explicitly setting
            {
                SetProfileValue(bgBackground, wtProfile);
            }
        }

        private static void SetProfileValue(JsonNode bgBackground, JsonNode wtProfile)
        {
            foreach (var (key, value) in bgBackground.AsObject())
            {
                // make a copy, because it already has a parent.
                var v = value.Deserialize<JsonNode>();
                wtProfile[key] = v;
            }
        }
    }
}