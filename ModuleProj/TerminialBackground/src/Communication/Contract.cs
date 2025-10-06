using System;

namespace Metaseed.TerminalBackground.Communication
{
    public interface IWtBgIpcClient
    {
        void Send(string data);
    }

    public interface IWtBgIpcServer : IDisposable
    {
        void Open();
        void Close();

        event EventHandler<DataReceivedEventArgs> Received;
    }

    [Serializable]
    public sealed class DataReceivedEventArgs : EventArgs
    {
        public DataReceivedEventArgs(string data)
        {
            this.Data = data;
        }

        public string Data { get; private set; }
    }
}
