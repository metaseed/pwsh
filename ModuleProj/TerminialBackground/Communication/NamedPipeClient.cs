using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Pipes;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
// https://weblogs.asp.net/ricardoperes/local-machine-interprocess-communication-with-net
// shared mem is only for windows
namespace Metaseed.TerminalBackground.Communication
{
    public class NamedPipeClient : IWtBgIpcClient
    {
        public void Send(string data)
        {
            using var client = new NamedPipeClientStream(".", nameof(IWtBgIpcClient), PipeDirection.Out);
            client.Connect();

            using var writer = new StreamWriter(client);
            writer.WriteLine(data);
        }
    }
}
