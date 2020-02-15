//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class ServerInfoLink expands UBrowserHTTPClient;

var 	config int    			UpdateServerTimeout;
var 	ServerInfoWindow 		UpdateWindow;

//-----------------------------------------------------------------------------
function BrowseCurrentURI(string ServerAddress, string URI, int ServerPort)
{
	log("browsing " $  ServerAddress $ URI $ ":" $ ServerPort);
	Browse(ServerAddress, URI, ServerPort, UpdateServerTimeout);
}

//-----------------------------------------------------------------------------
function Failure()
{
	UpdateWindow.Failure();
}

//-----------------------------------------------------------------------------
function Success()
{
	UpdateWindow.Success();
}

//-----------------------------------------------------------------------------
function ProcessData(string Data)
{
	UpdateWindow.SetMOTD(Data);
}

//////////////////////////////////////////////////////////////////
// HTTPClient functions
//////////////////////////////////////////////////////////////////
function HTTPError(int ErrorCode)
{     
	if (ErrorCode == 404)
	{
		log("404 Error");
		UpdateWindow.SetMOTD("<html><body bgcolor=#000000><br><br><br><center><b>Information or Server Unavailable</b></center></body></html>");
	}
	else
		Failure();
}

//-----------------------------------------------------------------------------
function HTTPReceivedData(string Data)
{
	ProcessData(Data);
	Success();
}

//-----------------------------------------------------------------------------

defaultproperties
{
	UpdateServerTimeout=10
}