﻿using System;
using System.IO;
using System.Management.Automation;
using System.Text.Json;
using System.Text.Json.Nodes;
using Metaseed.TerminalBackground.Communication;

namespace Metaseed.TerminalBackground
{
    public class Server : IDisposable
    {
        private readonly WtServer _server = new WtServer();
        private WtBackgroundImage WtBackgroundImage = new WtBackgroundImage();
        public Server()
        {
            _server.Start();
            Logger.Inst.Log("Server started");
            _server.Received += (sender, args) =>
            {
                Logger.Inst.Log($"received:{args.Data}");
                var data = JsonNode.Parse(args.Data);
                var command = data["command"].GetValue<string>();
                if (command == "StartCyclic")
                {
                    var settingsPath = data["settingsPath"].GetValue<string>();
                    WtBackgroundImage.StartCyclic(settingsPath);
                }
                else if (command == "StopCyclic")
                {
                    WtBackgroundImage.StopCyclic();
                }
                else if (command == "SetBackgroundImage")
                {
                    var profile = data["profile"].GetValue<string>();
                    var durationInSeconds = data["durationInSeconds"].GetValue<float>();
                    var jsonProfileValueString = data["jsonProfileValueString"].ToJsonString();
                    WtBackgroundImage.SetBackgroundImage(profile, durationInSeconds, jsonProfileValueString);
                }

            };
        }

        public void Dispose()
        {
            _server.Stop();
        }
    }

    public class Client
    {
        public static ICommandRuntime CommandRuntime;
        private readonly WtClient _client = new WtClient();

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
