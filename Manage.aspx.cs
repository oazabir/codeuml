using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Manage : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void Start_Clicked(object sender, EventArgs e)
    {
        PlantUmlProcessManager.Startup();
    }

    protected void Stop_Clicked(object sender, EventArgs e)
    {
        PlantUmlProcessManager.Shutdown();
    }

    protected void Recycle_Clicked(object sender, EventArgs e)
    {
        PlantUmlProcessManager.Recycle();
    }
    protected void Test_Clicked(object sender, EventArgs e)
    {
        var fileName = FileName.Text;
        var diagramFileName = fileName + ".txt";
        var imageFileName = fileName + ".png";
            
        var umltext = 
            "@startuml " + imageFileName + Environment.NewLine +
            UmlText.Text + Environment.NewLine +
            "@enduml";

        var key = Guid.NewGuid().ToString();
        Context.Cache.Add(key, umltext, null, DateTime.Now.AddSeconds(60), System.Web.Caching.Cache.NoSlidingExpiration,
            System.Web.Caching.CacheItemPriority.Default, null);

        DiagramImage.Src = "getimage.ashx?key=" + key;
    }
}
