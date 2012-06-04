<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Manage.aspx.cs" Inherits="Manage" ValidateRequest="false" %>
<%@ OutputCache NoStore="true" Location="None" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:Button Text="Start" ID="Start" OnClick="Start_Clicked" runat="server" />
        <asp:Button Text="Stop" ID="Stop" OnClick="Stop_Clicked" runat="server" />
        <asp:Button Text="Recycle" ID="Recycle" OnClick="Recycle_Clicked" runat="server" />
        <hr />
        <label>File Name: <asp:TextBox runat="server" ID="FileName" TextMode="SingleLine" Text="Test" /></label><br />
        <label>UML Text: <asp:TextBox runat="server" ID="UmlText" TextMode="MultiLine" Columns="40" Rows="10" Text="Alice -&gt; Bob"></asp:TextBox></label><br />
        
        <asp:Button Text="Test" runat="server" OnClick="Test_Clicked" /><br />
        <img id="DiagramImage" runat="server" />
    </div>
    </form>
</body>
</html>
