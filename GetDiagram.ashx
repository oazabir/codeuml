<%@ WebHandler Language="C#" Class="GetDiagram" %>

using System;
using System.Web;

public class GetDiagram : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        string id = context.Request["id"];
        using (var client = new System.Net.WebClient())
        {
            var param = new System.Collections.Specialized.NameValueCollection();
            param.Add("id", id);
            var xmlDoc = System.Xml.Linq.XDocument.Load(new System.IO.StreamReader(new System.IO.MemoryStream(client.UploadValues("http://tny.cz/api/get.xml", param))));
            context.Response.ContentType = "text/plain";
            context.Response.Write(xmlDoc.Element("result").Element("paste").Value);
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}