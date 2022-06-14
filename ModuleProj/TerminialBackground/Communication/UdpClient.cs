using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

namespace Metaseed.TerminalBackground.Communication
{
    public class WtUdpClient : IWtBgIpcClient
    {
        public void Send(string data)
        {
            using (var client = new UdpClient())
            {
                client.Connect(string.Empty, 9000);

                var bytes = Encoding.Default.GetBytes(data);

                client.Send(bytes, bytes.Length);
            }
        }
    }
}
