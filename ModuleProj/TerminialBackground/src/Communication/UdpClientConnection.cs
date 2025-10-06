using System.Net.Sockets;
using System.Text;

namespace Metaseed.TerminalBackground.Communication
{
    public class UdpClientConnection : IWtBgIpcClient
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
