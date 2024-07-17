using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Threading;
using System.Threading.Tasks;

namespace Metaseed.TerminalBackground
{
    public class CyclicBackground
    {
        private JsonObject _wtSettings;
        private JsonObject _bgSettings;
        private int _duration;
        private readonly WtSetting _settings;
        Task CyclicTask;
        private CancellationTokenSource cyclicToken = new CancellationTokenSource();

        public CyclicBackground()
        {
            _settings = new WtSetting();
            _wtSettings = _settings.GetSettings();
            var dirPath = Path.GetDirectoryName(typeof(CyclicBackground).Assembly.Location);

            _bgSettings = BgSetting.GetBackgroundSettings($"{dirPath}\\settings.json");
        }

        object _startCyclicLock = new object();

        public void StartCyclic(string settingsPath)
        {
            lock (_startCyclicLock)
            {
                if (CyclicTask != null)
                {
                    Logger.Inst.Log("the Cyclic task already started, restart it");
                    StopCyclic().Wait();
                }

                _bgSettings = BgSetting.GetBackgroundSettings(settingsPath);
                _duration = _bgSettings["duration"]?.GetValue<int?>() ?? WtSetting.DefaultDuration;
                CyclicTask = Task.Run(async () =>
                {
                    while (true)
                    {
                        try
                        {
                            var run = Run(cyclicToken.Token);
                            if (run.IsCanceled) break;
                            await run;
                            //Logger.Inst.Log("cyclically background changed");
                        }
                        catch (Exception e)
                        {
                            Logger.Inst.Log(e.ToString());
                        }
                    }
                }, cyclicToken.Token);
            }
        }

        private async Task Run(CancellationToken token)
        {
            await Task.Delay(_duration * 1000, token);
            // use the latest setting, that maybe modified by user at any time
            _wtSettings = _settings.GetSettings();
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
        }

        public async Task StopCyclic()
        {
            if (CyclicTask == null)
            {
                Logger.Inst.Log("already stopped, no action this time");
                return;
            }
            cyclicToken.Cancel();
            cyclicToken = new CancellationTokenSource();
            try
            {
                await CyclicTask;
            }
            catch
            {
                // cancel happens
            }
            CyclicTask = null;
        }

        public async Task SetBackgroundImage(string profile, float durationInSeconds, string jsonSettings, Task finish)
        {
            try
            {
                _wtSettings = _settings.GetSettings();
                var wtProfile = findWtProfile(profile);
                var bgProfile = findBgProfile(profile);
                var bgBackground = JsonNode.Parse(jsonSettings);
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
                var delay = Task.Delay((int)Math.Floor(durationInSeconds * 1000));
                await Task.WhenAny(delay, finish);
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
                Logger.Inst.Log(e.ToString());
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