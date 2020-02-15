//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class ServerInfoWindow expands UWindowPageWindow;

var 	UWindowVSplitter 						VSplitter;
var 	ServerInfoLink 							Link;
var 	UBrowserUpdateServerTextArea 			TextArea;

var 	localized string 						QueryText;
var 	localized string 						FailureText;
var 	class<ServerInfoLink> 					LinkClass;
var 	class<UBrowserUpdateServerTextArea> 	TextAreaClass;
var 	bool 									bGotMOTD;
var 	string 									StatusBarText;
var 	bool 									bHadInitialQuery;
var 	int 									Tries;
var 	int 									NumTries;
var 	string 									WebServer;
var 	string 									FilePath;
var 	int 									Port;

var 	bool 									bNavBar;

//var string InfoServerAddress;
//var int    InfoServerPort;
//var string InfoFilePath;
//var string ServerInfoFile;
var 	string 									ServerInfoURL;
var 	string 									MapInfoURL;

//-----------------------------------------------------------------------------
function Created()
{
	Super.Created();

	SetSize(ParentWindow.WinWidth, ParentWindow.WinHeight);

	if (bNavBar == true) { 
		TextArea = UBrowserUpdateServerTextArea(CreateControl(TextAreaClass, 0, 0, WinWidth, WinHeight, Self));

		VSplitter = UWindowVSplitter(CreateWindow(class'UWindowVSplitter', 0, 0, WinWidth, WinHeight));
		VSplitter.TopClientWindow    = TextArea;
		VSplitter.bSizable           = false;
		VSplitter.bBottomGrow        = false;
		VSplitter.SplitPos           = 430;
		VSplitter.BottomClientWindow = VSplitter.CreateWindow(class'MapVoteNavBar', 0, 0, WinWidth, WinHeight, OwnerWindow);
	}

	SetAcceptsFocus();
}

function disableNavBar(bool disableIt)
{
	if (disableIt == true) {
		bNavBar = false;
	}
}

//-----------------------------------------------------------------------------
function BrowseWebPage(string p_URLString)
{
	local int p1, p2;

	//www.planetunreal.com:80/BDBUnreal/ServerInfo.htm
	//---------------------->_________________________
	//      WebServer     |  |       FilePath
	//                   p2 p1
	p1 = InStr(p_URLString, "/");
	if (p1 <= 0)
	{
		log("Invalid URL");
		return;
	}

	WebServer = left(p_URLString, p1);
	FilePath = Mid(p_URLString, p1);
	p2 = InStr(WebServer, ":");

	if (p2 <= 0)
		Port = 80;
	else
	{
		if (int(Mid(WebServer, p2 + 1)) < 2)
		{
			log("Invalid web server port");
			return;
		}

		WebServer = left(WebServer, p2);
		Port = int(Mid(WebServer, p2 + 1));
	}

	log("WebServer=" $ WebServer);
	log("FilePath=" $ FilePath);
	log("Port=" $ Port);
	Query();
}

//-----------------------------------------------------------------------------
function Query()
{
	log("Query()...");
	bHadInitialQuery = True;
	StatusBarText = QueryText;

	if (Link != None)
	{
		Link.UpdateWindow = None;
		Link.Destroy();
	}

	Link = GetEntryLevel().Spawn(LinkClass);
	Link.UpdateWindow = Self;

	// Link.BrowseCurrentURI("www.planetunreal.com", "/BDBUnreal/serverinfo.htm", 80);
	Link.BrowseCurrentURI(WebServer, FilePath, Port);
	bGotMOTD = False;
}

//-----------------------------------------------------------------------------
function BeforePaint(Canvas C, float X, float Y)
{
	local UBrowserMainWindow W;

	Super.BeforePaint(C, X, Y);
	TextArea.SetSize(WinWidth, WinHeight);
}

//-----------------------------------------------------------------------------
function Paint(Canvas C, float X, float Y)
{
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
}

//-----------------------------------------------------------------------------
function SetMOTD(string MOTD)
{
	TextArea.SetHTML(MOTD);
}

//-----------------------------------------------------------------------------
function Failure()
{
	log("Browse Failure");
	Link.UpdateWindow = None;
	Link.Destroy();
	Link = None;
	Tries++;

	if (Tries < NumTries)
	{
		Query();
		return;
	}

	StatusBarText = FailureText;
	Tries = 0;
	SetMOTD("<html><body bgcolor=#000000><br><br><br><center><b>Information Unavailable</b></center></body></html>");
}

//-----------------------------------------------------------------------------
function Success()
{
	// log("Browse Successful");
	StatusBarText = "";

	Link.UpdateWindow = None;
	Link.Destroy();
	Link = None;
	Tries = 0;
}

//-----------------------------------------------------------------------------
//function KeyDown(int Key, float X, float Y)
//{
//     switch(Key)
//     {
//     case 0x74: // IK_F5;
//          TextArea.Clear();
//          Query();
//          break;
//     }
//}

//-----------------------------------------------------------------------------
//simulated function SetInfoServerAddress(string p_InfoServerAddress,
//                                        int    p_InfoServerPort,
//                                        string p_InfoFilePath,
//                                        string p_ServerInfoFile)
//{
//   InfoServerAddress = p_InfoServerAddress;
//   InfoServerPort = p_InfoServerPort;
//   InfoFilePath = p_InfoFilePath;
//   ServerInfoFile = p_ServerInfoFile;
//}

//-----------------------------------------------------------------------------
simulated function SetInfoServerAddress(string p_ServerInfoURL, string p_MapInfoURL)
{
	ServerInfoURL = p_ServerInfoURL;
	MapInfoURL = p_MapInfoURL;
}

//-----------------------------------------------------------------------------

defaultproperties
{
	QueryText="Querying Server..."
	FailureText="The server did not respond."
	LinkClass=Class'BTMapVote1.ServerInfoLink'
	TextAreaClass=Class'UBrowser.UBrowserUpdateServerTextArea'
	NumTries=3
}