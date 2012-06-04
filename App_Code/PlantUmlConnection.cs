using System;
using System.Collections.Generic;
using System.Web;
using AlexPilotti.FTPS.Client;
using System.Net;
using System.Text;
using System.IO;
using System.Diagnostics;

public class PlantUmlConnection : IDisposable
{
    private FTPSClient client = new FTPSClient();
    private string _host;
    private int _port;
    public void Connect(string host, int port)
    {
        _host = host;
        _port = port;
        Debug.WriteLine("Connecting to FTP " + host + ":" + port);
        client.Connect(host, port,
            new NetworkCredential("yourUsername","yourPassword"),
            ESSLSupportMode.ClearText,
            null,
            null,
            0,
            0,
            0,
            3000,
            true,
            EDataConnectionMode.Active
        );
        Debug.WriteLine("Connection successful " + host + ":" + port);
    }

    public void Disconnect()
    {
        Debug.WriteLine("Disconnecting from FTP " + _host + ":" + _port);
        client.Close();
        Debug.WriteLine("Disconnected from FTP " + _host + ":" + _port);
    }

    public void Upload(string remoteFileName, string content)
    {
        Debug.WriteLine("Uploading to " + _host + ":" + _port + "/" + remoteFileName);
        using (var stream = client.PutFile(remoteFileName))
        {
            byte[] data = Encoding.UTF8.GetBytes(content);
            stream.Write(data, 0, data.Length);
        }
        Debug.WriteLine("Successfully uploaded " + _host + ":" + _port + "/" + remoteFileName);
    }

    public void Delete(string remoteFileName)
    {
        Debug.WriteLine("Deleting from " + _host + ":" + _port + "/" + remoteFileName);
        client.DeleteFile(remoteFileName);
        Debug.WriteLine("Successfully deleted " + _host + ":" + _port + "/" + remoteFileName);
    }

    public byte[] Download(string remoteFileName)
    {
        Debug.WriteLine("Downloading from " + _host + ":" + _port + "/" + remoteFileName);
        using (var memoryStream = new MemoryStream())
        {
            using (var stream = client.GetFile(remoteFileName))
            {
                byte[] buffer = new byte[0x1000];
                int bytesRead;
                while ((bytesRead = stream.Read(buffer, 0, 0x1000)) > 0)
                {
                    memoryStream.Write(buffer, 0, bytesRead);
                }
            }

            Debug.WriteLine("Successfully downloaded " + _host + ":" + _port + "/" + remoteFileName);
            return memoryStream.ToArray();
        }
            
    }

    public void Download(string remoteFileName, Action<Stream> processStream)
    {
        Debug.WriteLine("Downloading from " + _host + ":" + _port + "/" + remoteFileName);
        using (var stream = client.GetFile(remoteFileName))
        {
            processStream(stream);
        }

        Debug.WriteLine("Successfully downloaded " + _host + ":" + _port + "/" + remoteFileName);
            
    }

    public void Dispose()
    {
        client.Dispose();
    }
}
