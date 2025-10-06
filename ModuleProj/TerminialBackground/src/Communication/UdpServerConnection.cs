using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

namespace Metaseed.TerminalBackground.Communication
{
    public sealed class UdpServerConnection : IWtBgIpcServer
    {
        private readonly UdpClient udpClient = new UdpClient(9000);

        void IDisposable.Dispose()
        {
            Close();

            (udpClient as IDisposable).Dispose();
        }

        public void Open()
        {
            Task.Factory.StartNew(() =>
            {
                var ip = new IPEndPoint(IPAddress.Any, 0);

                while (true)
                {
                    var bytes = udpClient.Receive(ref ip);
                    var data  = Encoding.Default.GetString(bytes);
                    OnReceived(new DataReceivedEventArgs(data));
                }
            });
        }

        private void OnReceived(DataReceivedEventArgs e)
        {
            var handler = Received;

            if (handler != null)
            {
                handler(this, e);
            }
        }

        public void Close()
        {
            udpClient.Close();
        }

        public event EventHandler<DataReceivedEventArgs> Received;
    }
}
