using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

namespace Metaseed.TerminalBackground.Communication
{
    public sealed class WtUdpServer : IWtBgIpcServer
    {
        private readonly UdpClient server = new UdpClient(9000);

        void IDisposable.Dispose()
        {
            this.Stop();

            (this.server as IDisposable).Dispose();
        }

        public void Start()
        {
            Task.Factory.StartNew(() =>
            {
                var ip = new IPEndPoint(IPAddress.Any, 0);

                while (true)
                {
                    var bytes = this.server.Receive(ref ip);
                    var data  = Encoding.Default.GetString(bytes);
                    this.OnReceived(new DataReceivedEventArgs(data));
                }
            });
        }

        private void OnReceived(DataReceivedEventArgs e)
        {
            var handler = this.Received;

            if (handler != null)
            {
                handler(this, e);
            }
        }

        public void Stop()
        {
            this.server.Close();
        }

        public event EventHandler<DataReceivedEventArgs> Received;
    }
}
