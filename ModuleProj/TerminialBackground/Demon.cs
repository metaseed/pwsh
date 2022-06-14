using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Nodes;
using System.Threading.Tasks;
using Metaseed.TerminalBackground.Communication;

namespace Metaseed.TerminalBackground
{
    public class Server : IDisposable
    {
        private readonly WtUdpServer _server = new WtUdpServer();

        public Server()
        {
            _server.Start();
            Console.WriteLine("Server started");
            _server.Received += (sender, args) =>
            {
                var data    = JsonNode.Parse(args.Data);
                Console.WriteLine($"received:{data}");
                var command = data["command"].GetValue<string>();
                if (command == "StartCyclic")
                {
                    WtBackgroundImage.StartCyclic();
                }
                else if (command == "StopCyclic")
                {
                    WtBackgroundImage.StopCyclic();
                } else if (command == "SetBackgroundImage")
                {
                    var profile = data["profile"].GetValue<string>();
                    var durationInSeconds      = data["durationInSeconds"].GetValue<float>();
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
        private readonly WtUdpClient _client = new WtUdpClient();

        public void StartCyclic()
        {
            var data = "{\"command\":\"StartCyclic\"}";
            Console.WriteLine("send:" + data);
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
