<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<%@ OutputCache Location="None" NoStore="true" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Codeuml.com</title>
    <link href="Styles/reset.css" rel="stylesheet" type="text/css" />
    <link href="Scripts/codemirror.css" rel="stylesheet" type="text/css" />
    <link href="Styles/codeuml.css" rel="stylesheet" type="text/css" />
    <link href="Styles/ticker-style.css" rel="Stylesheet" type="text/css" />

    <script src="Scripts/jquery-1.7.1.min.js" type="text/javascript"></script>
    <script src="Scripts/jquery-1.4.1-vsdoc.js" type="text/javascript"></script>
    <script src="Scripts/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
    <script src="Scripts/splitter.js" type="text/javascript"></script>
    <script src="Scripts/codemirror.js" type="text/javascript"></script>
    <script src="Scripts/cookie.js" type="text/javascript"></script>
    <script src="Scripts/jquery.base64.js" type="text/javascript"></script>
    <!--<script src="Scripts/jquery.ticker.js" type="text/javascript"></script>
    <script src="http://omaralzabir.com/ticker.php" type="text/javascript"></script>-->

    <script type="text/javascript">

        var myCodeMirror;
        var defaultUmlText;
        var DEFAULT_DIAGRAM_TYPE = "sequence_diagram";

        var lastUmlDiagram = readCookie("t");
        if (lastUmlDiagram == null)
            lastUmlDiagram = DEFAULT_DIAGRAM_TYPE;

        var diagramUrl = "";
        if (document.location.href.indexOf('?') > 0) {
            diagramUrl = document.location.href.substr(document.location.href.indexOf('?') + 1).trim();
        }

        $(document).ready(function () {

            //setIframeBackground();

            // -------------------- Begin Splitter -----------------------------

            // Main vertical splitter, anchored to the browser window
            $("#MySplitter").splitter({
                type: "v",
                outline: true,
                minLeft: 60, sizeLeft: 100, maxLeft: 250,
                anchorToWindow: true,
                resizeOnWindow: true,
                accessKey: "L"
            });
            // Second vertical splitter, nested in the right pane of the main one.
            $("#CenterAndRight").splitter({
                type: "v",
                outline: true,
                minRight: 200, sizeRight: ($(window).width() * 0.6), maxRight: ($(window).width() * 0.9),
                accessKey: "R"
            });
            $(window).resize(function () {
                $("#MySplitter").trigger("resize");
            });

            // -------------------- End Splitter -----------------------------

    
            // --------------- Begin UML snippet bar ------------------

            $("#umlsnippets").find(".button").click(function () {
                var diagramType = $(this).parent().attr("class");

                if (lastUmlDiagram !== diagramType) {
                    if (!confirm("The current diagram will be cleared? Do you want to continue?"))
                        return;

                    myCodeMirror.setValue("");
                }

                changeDiagramType(diagramType);

                var umlsnippet = $(this).find("pre.umlsnippet").text();
                
                var pos = myCodeMirror.getCursor(true);

                // When replaceRange or replaceSelection is called
                // to insert text, in IE 8, the code editor gets 
                // screwed up. So, it needs to be recreated after this.
                myCodeMirror.replaceRange(umlsnippet, myCodeMirror.getCursor(true));

                // recreate the code editor to fix screw up in IE 7/8
                myCodeMirror.toTextArea();
                myCodeMirror = CodeMirror.fromTextArea($('#umltext').get(0),
                {
                    onChange: refreshDiagram
                });

                myCodeMirror.focus();
                myCodeMirror.setCursor(pos);

                refreshDiagram();
            });

            // -------------------- End UML Snippet Bar -----------------------------

            // -------------------- Begin UML Code editor -----------------------------

            defaultUmlText = $('#umltext').val();

            myCodeMirror = CodeMirror.fromTextArea($('#umltext').get(0),
            {
                onChange: refreshDiagram
            });
            myCodeMirror.focus();
            myCodeMirror.setCursor({ line: myCodeMirror.lineCount() + 1, ch: 1 });

            // -------------------- End UML Code editor -----------------------------

            // -------------------- Load/Restore UML diagram -----------------------------

            // If URL has a diagram location, then load that diagram
            if (diagramUrl.length > 0) {
                $.get("GetDiagram.ashx?id=" + encodeURI(diagramUrl), function (result) {
                    myCodeMirror.setValue(result);                    
                });
            }
            else {
                // restore previously saved UML
                var existingUml = readCookie('uml');
                if (existingUml != null && $.trim(existingUml).length > 0) {
                    try {
                        var decoded = $.base64.decode(existingUml);
                        myCodeMirror.setValue(decoded);
                    }
                    catch (e) {

                    }
                }
            }
            
            $('#umlimage').bind('load', function () {
                lastTimer = null;
                hideProgress();
                refreshDiagram();
                $(this).fadeTo(0, 0.5, function () { $(this).fadeTo(300, 1.0); });
            });

        });

        var lastUmlText = "";
        var lastTimer = null;

        function refreshDiagram() {

            if (lastTimer == null) {
                
                lastTimer = window.setTimeout(function () {
                    // Remove starting and ending spaces
                    var umltext = myCodeMirror.getValue().replace(/(^[\s\xA0]+|[\s\xA0]+$)/g, '');

                    var umltextchanged = 
                        (umltext !== lastUmlText) 
                        && validDiagramText(umltext); 

                    if (umltextchanged) {
                        showProgress();

                        lastUmlText = umltext;

                        $.post("SendUml.ashx", { uml: umltext }, function (result) {
                            var key = $.trim(result);
                            $("#umlimage").attr("src", "getimage.ashx?key=" + key);
                        }, "text");

                        try {
                            var forCookie = $.base64.encode(umltext).replace(/==/, '');

                            if (forCookie.length > 3800) {
                                alert("Sorry maximum 3800 characters allowed in a diagram");
                            }
                            else {
                                createCookie('uml', forCookie, 30);
                                var test = readCookie('uml');

                                if (test !== forCookie) {
                                    createCookie('uml', '', 30);
                                }                                
                            }
                        } catch (e) {
                        }
                    }
                }, 1000);
            }
            else {
                window.clearTimeout(lastTimer);
                lastTimer = null;
                refreshDiagram();
            }

        }

        function validDiagramText(umltext) {
            var lines = umltext.split('\n');
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i];

                if (((line.split('"').length - 1) % 2) > 0)
                    return false;

                if (lastUmlDiagram == "sequence_diagram" 
                && line.indexOf('>') > 0 && line.indexOf(':') < 0)
                    return false;
                
                
            }
            
            return true;            
        }

        function changeDiagramType(diagramType) {
            lastUmlDiagram = diagramType;
            createCookie("t", lastUmlDiagram, 30);
        }

        function showProgress() {
            $('#ProgressIndicator').show();
        }

        function hideProgress() {
            $('#ProgressIndicator').hide();
        }

        // ------------------- End Diagram Drawing ----------------------


        // ------------------- Begin menu handlers -----------------

        function menu_new() {
            changeDiagramType(DEFAULT_DIAGRAM_TYPE);
            myCodeMirror.setValue(defaultUmlText);
            eraseCookie("t");
            if (diagramUrl.length > 0) {
                document.location = document.location.pathname;
            }
        }

        function menu_share() {
            showProgress();
            if (diagramUrl.length > 0 ) {
                $.post("Share.ashx", { uml: myCodeMirror.getValue(), id: diagramUrl }, function (url) {
                    hideProgress();
                });
            }
            else {
                $.post("Share.ashx", { uml: myCodeMirror.getValue() }, function (url) {
                    document.location = "?" + url;
                    hideProgress();
                }, "text");
            }
        }

        function menu_save() {
            
            $.post("SendUml.ashx", { uml: myCodeMirror.getValue() }, function (result) {
                var key = result;
                document.location = "getimage.ashx?saveMode=1&key=" + key;
            }, "text");

        }

        
    </script>
    <script type="text/javascript">

        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', 'UA-31186967-1']);
        _gaq.push(['_trackPageview']);

        (function () {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();

    </script>
</head>
<body>    
    <div id="header" class="unselectable">
        <h1>
            <div class="title">
                codeuml</div>

        </h1>
<!--        <div id="ticker">
            News ticker
        </div>-->

        <div id="menu">
            <div class="poweredby">
                Powered by <a href="http://plantuml.sourceforge.net">Plantuml</a></div>
            <a href="javascript:menu_new()">
                <div class="button">
                    <div class="icon">
                        &diams;</div>
                    <div class="title">
                        New</div>
                </div>
            </a>
            <a href="javascript:menu_share()">
                <div class="button">
                    <div class="icon">
                        &hearts;</div>
                    <div class="title">
                        Save</div>
                </div>
            </a>
            <a href="http://plantuml.sourceforge.net">
                <div class="button">
                    <div class="icon">
                        ?</div>
                    <div class="title">
                        Help</div>
                </div>
            </a>
            <a href="http://omaralzabir.com">
                <div class="button">
                    <div class="icon">
                        &copy;</div>
                    <div class="title">
                        Omar AL Zabir</div>
                </div>
            </a>
        </div>
    </div>
    <div id="MySplitter">
        <div class="SplitterPane unselectable">
            <div id="umlsnippets">
                <div id="scrollable">
                    <!-- Sequence diagram -->
                    <h2>
                        Sequence
                    </h2>
                    <div class="sequence_diagram">
                        <div class="button">
                            <div class="icon">
                                A&rarr;B</div>
                            <div class="title">
                                Sync Msg</div>
                            <pre class="umlsnippet">A -> B: Sync Message
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                A&mdash;B</div>
                            <div class="title">
                                Async Msg</div>
                            <pre class="umlsnippet">A ->> B: Async Message
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                A&rarr;A</div>
                            <div class="title">
                                Self Msg</div>
                            <pre class="umlsnippet">B -> B: Do work
activate B #FFBBBB
    
deactivate B
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                alt</div>
                            <div class="title">
                                Alternate</div>
                            <pre class="umlsnippet">alt Success
    A -> B: Success
else failed
    A -> C: Fail
end
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                &Omega;</div>
                            <div class="title">
                                Loop</div>
                            <pre class="umlsnippet">loop until some condition
    A -> B: Keep working
end
</pre>
                        </div>
                    </div>
                    <h2>
                        Use case
                    </h2>
                    <div class="usecase_diagram">
                        <div class="button">
                            <div class="icon">
                                A->(B)</div>
                            <div class="title">
                                Actor -> Usecase</div>
                            <pre class="umlsnippet">Customer -&gt; (start) : Customer starts application
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                (A)</div>
                            <div class="title">
                                Use case</div>
                            <pre class="umlsnippet">usecase (First usecase) as U1
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                Actor</div>
                            <div class="title">
                                Actor</div>
                            <pre class="umlsnippet">actor Customer as C
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                &larr;</div>
                            <div class="title">
                                Extend</div>
                            <pre class="umlsnippet">(Start) &lt;|-- (Use)
</pre>
                        </div>
                    </div>
                    <h2>
                        Class</h2>
                    <div class="class_diagram">
                        <div class="button">
                            <div class="icon">
                                &copy;</div>
                            <div class="title">
                                Class</div>
                            <pre class="umlsnippet">class Dummy {
  String data
  void methods()
}
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                &diams;&rarr;</div>
                            <div class="title">
                                Contains</div>
                            <pre class="umlsnippet">Class01 "1" *-- "many" Class02 : contains
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                &Psi;</div>
                            <div class="title">
                                Aggregation</div>
                            <pre class="umlsnippet">Class03 o-- Class04 : agregation
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                &rarr;</div>
                            <div class="title">
                                Directed</div>
                            <pre class="umlsnippet">Class05 --> "1" Class06
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                A&mdash;B</div>
                            <div class="title">
                                Association</div>
                            <pre class="umlsnippet">Driver -- Car: drives
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                &Delta;</div>
                            <div class="title">
                                Inherits</div>
                            <pre class="umlsnippet">Parent &lt;|-- Child
</pre>
                        </div>
                    </div>
                    <h2>
                        Component</h2>
                    <div class="component_diagram">
                        <div class="button">
                            <div class="icon">
                                &Omicron;</div>
                            <div class="title">
                                Interface</div>
                            <pre class="umlsnippet">HTTP - [Webserver]
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                [A]</div>
                            <div class="title">
                                Component</div>
                            <pre class="umlsnippet">[Component]
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                C&rarr;&Omicron;</div>
                            <div class="title">
                                Use</div>
                            <pre class="umlsnippet">[Client] ..> HTTP : use
</pre>
                        </div>
                        <div class="button">
                            <div class="icon">
                                &Pi;</div>
                            <div class="title">
                                Package</div>
                            <pre class="umlsnippet">package "Some Group" {
    HTTP - [First Component]
    [Another Component]
}
</pre>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div id="CenterAndRight">
            <div class="SplitterPane">
                <img src="img/ajax-loader.gif" id="ProgressIndicator" />
                <textarea id="umltext" rows="10" cols="40">Actor A
participant B

A -> B: Do Something
activate B
    B -> B: Do work
    activate B #FFBBBB
    deactivate B
    alt Success
        B ->> C: Success
    else failed
        B ->> C: Fail
    end
    B --> A: Return
deactivate B

</textarea>
            </div>
            <div class="SplitterPane">
                <div id="umlimage_container">
                    <img id="umlimage" src="img/defaultdiagram.png" />
                </div>             
            </div>
        </div>
        <!-- #CenterAndRight -->
    </div>
    <!-- #MySplitter -->
</body>
</html>
