using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Pipes;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
// https://docs.microsoft.com/en-us/dotnet/standard/io/how-to-use-anonymous-pipes-for-local-interprocess-communication
namespace Metaseed.TerminalBackground.Communication
{
    public sealed class NamedPipeServer : IWtBgIpcServer
    {
        private readonly NamedPipeServerStream _server = new NamedPipeServerStream(nameof(IWtBgIpcClient), PipeDirection.In);

        private void OnReceived(DataReceivedEventArgs e)
        {
            var handler = this.Received;

            if (handler != null)
            {
                handler(this, e);
            }
        }

        public event EventHandler<DataReceivedEventArgs> Received;

        public void Start()
        {
            Task.Factory.StartNew(() =>
            {
                while (true)
                {
                    this._server.WaitForConnection();

                    using var reader = new StreamReader(this._server);
                    this.OnReceived(new DataReceivedEventArgs(reader.ReadToEnd()));
                }
            });
        }

        public void Stop()
        {
            Console.WriteLine("Server stopped!");
            this._server.Disconnect();
        }

        void IDisposable.Dispose()
        {
            this.Stop();
            Console.WriteLine("Server disposed!");

            this._server.Dispose();
        }
    }
}
