using System;
using System.Collections.Generic;
using System.Web;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Text;

public static class PlantUmlProcessManager
{
    private static readonly List<Process> _processes = new List<Process>();

    public static void Startup()
    {
        if (_processes.Count > 0)
            Shutdown();

        var javaPath = ConfigurationManager.AppSettings["java"];

        if (!File.Exists(javaPath))
            throw new ApplicationException("Java.exe not found: " + javaPath);

        var host = ConfigurationManager.AppSettings["plantuml.host"];
        var startPort = Convert.ToInt32(ConfigurationManager.AppSettings["plantuml.start_port"]);
        var instances = Convert.ToInt32(ConfigurationManager.AppSettings["plantuml.instances"]);
            
        var plantumlPath = ConfigurationManager.AppSettings["plantuml.path"];
        if (!File.Exists(plantumlPath))
            throw new ApplicationException("plantuml.jar not found in " + plantumlPath);

        for (int i = 0; i < instances; i++)
        {
            var argument = "-jar " + plantumlPath + " -ftp:" + (startPort + i);
            ProcessStartInfo pInfo = new ProcessStartInfo(javaPath, argument);

            pInfo.CreateNoWindow = true;
            pInfo.UseShellExecute = false;
            pInfo.RedirectStandardInput = true;
            pInfo.RedirectStandardError = true;
            pInfo.RedirectStandardOutput = true;
                
            Process process = Process.Start(pInfo);
            Thread.Sleep(5000);
            _processes.Add(process);

            PlantUmlConnection connection = new PlantUmlConnection();
            connection.Connect(host, startPort + i);
            PlantUmlConnectionPool.Put(connection);
        }
    }

    public static void Shutdown()
    {
        PlantUmlConnectionPool.Dispose();

        foreach (Process process in _processes)
        {
            try
            {
                process.StandardInput.WriteLine("\x3");
                process.StandardInput.Flush();

                Thread.Sleep(1);
                Debug.WriteLine(string.Format("Process {0} has exited: {1}", process.Id, process.HasExited));
                    
                process.Kill();
                    
                process.Dispose();
            }
            catch (Exception x)
            {
                Debug.WriteLine(x);
            }
        }
        _processes.Clear();
    }

    public static void Recycle()
    {
        Shutdown();
        Startup();
    }
}
