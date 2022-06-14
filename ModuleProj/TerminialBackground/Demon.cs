using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Metaseed.TerminalBackground.Communication;

namespace Metaseed.TerminalBackground
{
    public class Demon: IDisposable
    {
        private readonly NamedPipeServer _server = new NamedPipeServer();

        public Demon()
        {
            _server.Start();
            _server.Received += (sender, args) =>
            {

            };
        }

        public void Dispose()
        {
            _server.Stop();
        }
    }
}
