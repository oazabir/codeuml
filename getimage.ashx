<%@ WebHandler Language="C#" Class="getimage" %>

using System;
using System.Web;
using System.Net;
using System.IO;
using System.Configuration;
using System.Drawing;

public class getimage : IHttpHandler, System.Web.SessionState.IReadOnlySessionState {
    private const string WatermarkText = "codeuml.com";
    private static readonly Font _font = new Font("Tahoma", 10, FontStyle.Regular, GraphicsUnit.Pixel);

    public void ProcessRequest (HttpContext context) {
        
        if (context.Request.ContentLength > 10000)
        {
            throw new ApplicationException("Too large payload");
        }

        string key = context.Request["key"];
        string umltext = context.Cache[key] as string;

        if (string.IsNullOrEmpty(umltext))
            throw new ApplicationException("UML text seems to be lost. Try again.");
        
        context.Response.ContentType = "image/png";
        context.Response.Cache.SetCacheability(HttpCacheability.Private);
        context.Response.Cache.SetExpires(DateTime.Now.AddMinutes(5));
        
        if (context.Request["saveMode"] == "1")
        {                
            context.Response.AddHeader("Content-Disposition", "attachment; filename=diagram.png");
        }
        
        var connection = PlantUmlConnectionPool.Get(TimeSpan.FromSeconds(15));
        if (connection == null)
            throw new ApplicationException("Connection not found in pool.");

        try
        {
            var uploadFileName = key + ".txt";
            var downloadFileName = key + ".png";
            
            connection.Upload(uploadFileName, 
                "@startuml " + downloadFileName + Environment.NewLine +
                umltext + Environment.NewLine +
                "@enduml");
            
            System.Threading.Thread.Sleep(100);

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

                using (Bitmap b = Bitmap.FromStream(memoryStream, true, false) as Bitmap)
                using (Bitmap newBitmap = new Bitmap(b.Width, b.Height + 20))
                using (Graphics g = Graphics.FromImage(newBitmap))
                {
                    // Put the original image on the top left corner.
                    g.FillRectangle(Brushes.White, 0, 0, newBitmap.Width, newBitmap.Height);
                    g.DrawImage(b, 0, 0);
                    
                    // Add the watermark
                    SizeF size = g.MeasureString(WatermarkText, _font);
                    g.DrawString(WatermarkText, _font, Brushes.Black, newBitmap.Width - size.Width, newBitmap.Height - 15);

                    // Save the image to the response stream directly.
                    newBitmap.Save(context.Response.OutputStream, System.Drawing.Imaging.ImageFormat.Png);
                }

                context.Response.Flush();
            }
                
            connection.Delete(downloadFileName);
            connection.Delete(uploadFileName);
        }
        finally
        {
            PlantUmlConnectionPool.Put(connection);
        }
        
        context.Response.End();
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }   

}