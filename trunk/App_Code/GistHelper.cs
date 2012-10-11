using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Xml.Linq;

public static class GistHelper
{
    const string newGistUrl = "https://api.github.com/gists";
    const string singleGistUrl = "https://api.github.com/gists/{0}";
    const string updateGistUrl = "https://api.github.com/gists/{0}";

    public static XDocument CreateNewGist(string description, string filename, string body)
    {
        var xml = new XElement("gist",
            new XElement("description", description),
            new XElement("public", true),
            new XElement("files",
                new XElement(filename,
                    new XElement("content", body)
                )
            )
        );
        var json = JsonConvert.SerializeXNode(xml, Formatting.Indented, true);

        var request = WebRequest.Create(newGistUrl) as HttpWebRequest;
        request.AllowAutoRedirect = false;
        request.Method = "POST";
        using (var postStream = new StreamWriter(request.GetRequestStream()))
        {
            postStream.Write(json);
            postStream.WriteLine();
            postStream.WriteLine();
        }
        using (var response = request.GetResponse())
        {
            using (var responseStream = new StreamReader(response.GetResponseStream()))
            {
                var responseJson = responseStream.ReadToEnd();

                var responseXml = JsonConvert.DeserializeXNode(responseJson, "gist") as XDocument;
                return responseXml;
            }
        }            
    }

    public static XDocument GetGist(string url)
    {
        using (var client = new WebClient())
        {
            var json = client.DownloadString(url);
            return JsonConvert.DeserializeXNode(json, "gist");
        }
    }

    public static XDocument UpdateGist(string id, string description, string filename, string body)
    {
        var xml = new XElement("gist",
            new XElement("description", description),
            new XElement("public", true),
            new XElement("files",
                new XElement(filename,
                    new XElement("content", body)
                )
            )
        );
        var json = JsonConvert.SerializeXNode(xml, Formatting.Indented, true);

        var request = WebRequest.Create(string.Format(updateGistUrl, id)) as HttpWebRequest;
        request.AllowAutoRedirect = false;
        request.Method = "PATCH";
        using (var postStream = new StreamWriter(request.GetRequestStream()))
        {
            postStream.Write(json);
            postStream.WriteLine();
            postStream.WriteLine();
        }
        using (var response = request.GetResponse())
        {
            using (var responseStream = new StreamReader(response.GetResponseStream()))
            {
                var responseJson = responseStream.ReadToEnd();

                var responseXml = JsonConvert.DeserializeXNode(responseJson, "gist") as XDocument;
                return responseXml;
            }
        }            
    }
}
