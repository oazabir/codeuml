<%@ WebHandler Language="C#" Class="SendUml" %>

using System;
using System.Web;

public class SendUml : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        string uml = context.Request["uml"];
        string key = Guid.NewGuid().ToString();

        context.Cache.Add(key, uml, null, DateTime.Now.AddSeconds(60), System.Web.Caching.Cache.NoSlidingExpiration,
            System.Web.Caching.CacheItemPriority.Default, null);
        
        context.Response.ContentType = "text/plain";
        context.Response.Write(key);
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}