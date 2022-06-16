using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Threading;
using System.Threading.Tasks;
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
            Console.WriteLine("Server started");
            _server.Received += (sender, args) =>
            {
                Console.WriteLine($"received:{args.Data}");
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
        private readonly WtClient _client = new WtClient();

        public void StartCyclic(string settingsPath)
        {
            settingsPath = settingsPath.Trim('"', '\'');
            if (!File.Exists(settingsPath))
            {
                Console.WriteLine("file not exist!");
                return;
            }
            var p = JsonSerializer.Serialize(settingsPath);
            var data = $"{{\"command\":\"StartCyclic\", \"settingsPath\": {p}}}";
            //Console.WriteLine("send:" + data);
            _client.Send(data);
        }

        public void StopCyclic()
        {
            var data = "{\"command\":\"StopCyclic\"}";
            Console.WriteLine("send:" + data);
            _client.Send(data);

        }

        public void SetBackgroundImage(string profile, float durationInSeconds, string jsonProfileValueString)
        {
            var data = $"{{\"command\": \"SetBackgroundImage\", \"profile\":\"{profile}\", \"durationInSeconds\": {durationInSeconds}, \"jsonProfileValueString\": {jsonProfileValueString} }}";
            Console.WriteLine("send:" + data);
            _client.Send(data);
        }

    }
}
