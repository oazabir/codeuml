There are several pre-requisits before you run this website. 

1. Install Java
===============
Download and install latest Java. Make sure you know where
you are installing java. Usually it will be:

"c:\Program Files\Java\jre6\bin" 

1. Configure Graphviz
=============================================================
First, you have to install graphviz. 

http://www.graphviz.org/

Once you have installed, create a SYSTEM environment variable
called GRAPHVIZ_DOT which points to the dot.exe found in the 
graphviz bin folder. Usually it is:
c:\Program Files\Graphviz2.26.3\bin\dot.exe

Once you have done so, start a new command line window and run
this:

set graphviz_dot

If this shows you:
GRAPHVIZ_DOT=c:\Program Files\Graphviz2.26.3\bin\dot.exe

Then it is ok.

2. Installing on IIS 7+
=============================================================
If you are hosting this on a Windows Server, there are various
steps you need to do:

* First create a new app pool. 
* Create a new website or virtual directory that points to this website.
* Give the app pool user (IIS AppPool\YourAppPoolName or NETWORK SERVICE)
Read & Execute permission on the:
	** Java folder. Eg. "c:\Program Files\Java\jre6\bin" 
	** Graphviz bin folder: Eg c:\Program Files\Graphviz2.26.3\bin
	** Within this website: plantuml folder. 

3. Configuring web.config
==============================================================
You must fix the following entries before you can run:

<add key="java" 
	value="c:\Program Files\Java\jre6\bin\java.exe" />
<add key="plantuml.path" 
	value="C:\Dropbox\Dropbox\OSProjects\PlantUmlRunner\plantuml\plantuml.jar"/>
    
These are both absolute paths. No relative path allowed. 


4. Running and testing the website
============================================================
Run the Manage.aspx. 
It will take a while to start the page as it tries to launch java
and run the plantuml engine at the application_start event.

Once the site is up and running, click on Test button to test
a UML generation. If it works, you have congfigured everything 
properly.

Disable the Manage.aspx on production.