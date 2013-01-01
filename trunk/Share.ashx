<%@ WebHandler Language="C#" Class="Share" %>

using System;
using System.Web;

public class Share : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        string uml = context.Request["uml"];
        string url = context.Request["id"];

        // Gist.com solution
        //System.Xml.Linq.XDocument xml = GistHelper.CreateNewGist("Codeuml diagram", "codeuml.txt", uml);
        //var enu = xml.Element("gist").Descendants("raw_url").GetEnumerator();
        //if (enu.MoveNext())
        //{
        //    var url = enu.Current.Value;
        //    context.Response.ContentType = "text/plain";
        //    context.Response.Write(url);
        //}

        // Tinyurl.com solution
        //using (var client = new System.Net.WebClient())
        //{
        //    var param = new System.Collections.Specialized.NameValueCollection();
        //    param.Add("is_private", "1");
        //    param.Add("title", "Codeuml.com Diagram");
        //    param.Add("paste", uml);
        //    var xmlDoc = System.Xml.Linq.XDocument.Load(
        //        new System.IO.StreamReader(
        //            new System.IO.MemoryStream(
        //                client.UploadValues("http://tny.cz/api/create.xml", param))));
        //    var id = xmlDoc.Element("result").Element("response").Value;
        //    context.Response.ContentType = "text/plain";
        //    context.Response.Write(id);   
        //}
        
        // App_Data storage solution
        var fileName = string.IsNullOrEmpty(url) ? DateTime.Now.Ticks.ToString() : url.Trim();
        var filePath = context.Server.MapPath("~/App_Data/" + fileName);
        System.IO.File.WriteAllText(filePath, uml);
        context.Response.ContentType = "text/plain";
        context.Response.Write(fileName);
        
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}