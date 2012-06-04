using System;
using System.Collections.Generic;
using System.Web;
using System.Threading;
using System.IO;

public static class DiagramHelper
{   
    public static byte[] Generate(string uploadFileName, string downloadFileName, string content)
    {
        var connection = PlantUmlConnectionPool.Get(TimeSpan.FromSeconds(15));
        if (connection == null)
            throw new ApplicationException("Connection not found in pool.");

        try
        {
            connection.Upload(uploadFileName, content);
            Thread.Sleep(100);

            using (MemoryStream memoryStream = new MemoryStream())
            {
                connection.Download(downloadFileName, stream =>
                {
                    byte[] buffer = new byte[0x1000];
                    int bytesRead;
                    while ((bytesRead = stream.Read(buffer, 0, 0x1000)) > 0)
                    {
                        memoryStream.Write(buffer, 0, bytesRead);
                    }

                });
                connection.Delete(downloadFileName);
                connection.Delete(uploadFileName);
                return memoryStream.ToArray();
            }                
        }
        finally
        {
            PlantUmlConnectionPool.Put(connection);
        }
    }
}
