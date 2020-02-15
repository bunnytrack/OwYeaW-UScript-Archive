//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class MapVoteNavBar expands UMenuDialogClientWindow;

var 	UWindowSmallButton 		ServerInfoButton;
var 	UWindowSmallButton 		MapInfoButton;
var 	UWindowSmallButton 		ReportButton1;
var 	UWindowSmallButton 		ReportButton2;
var 	UWindowSmallButton 		TipsButton;
var 	UWindowSmallButton 		AboutButton;
var 	UWindowSmallButton 		HelpButton;
var 	UWindowSmallButton 		CloseButton;
var 	bool 					bShowWelcomeWindow;

//-----------------------------------------------------------------------------
function Created()
{
	Super.Created();

	ServerInfoButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 1, 10, 59, 10));
	ServerInfoButton.Text= "Server Info";

	MapInfoButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 61, 10, 59, 10));
	MapInfoButton.Text= "Map Info";

	ReportButton1 = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 121, 10, 49, 10));
	ReportButton1.Text= "Report 1";
	ReportButton1.bDisabled = true;

	ReportButton2 = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 171, 10, 49, 10));
	ReportButton2.Text= "Report 2";
	ReportButton2.bDisabled = true;

	AboutButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 221, 10, 39, 10));
	AboutButton.Text= "About";

	TipsButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 261, 10, 69, 10));
	TipsButton.Text= "MapVote Tips";

	HelpButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 331, 10, 39, 10));
	HelpButton.Text= "Help";

	CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 371, 10, 30, 10));
	CloseButton.DownSound = sound 'UnrealShare.WeaponPickup';
	CloseButton.Text= "Close";
}

//-----------------------------------------------------------------------------
function Notify(UWindowDialogControl C, byte E)
{
	local string CurrentMapName;
	local int pos;
	local ServerInfoWindow MainWindow;

	MainWindow = ServerInfoWindow(ParentWindow.ParentWindow);

	Super.Notify(C, E);

	switch(E)
	{
		case DE_Click:
			switch(C)
			{
				case ServerInfoButton:
					MainWindow.BrowseWebPage(MainWindow.ServerInfoURL);
				break;

				case MapInfoButton:
					CurrentMapName = GetPlayerOwner().GetURLMap();
					pos = InStr(CurrentMapName, ".");
					if (pos > 0)
						CurrentMapName = Left(CurrentMapName, pos);

					if(CurrentMapName != "")
						MainWindow.BrowseWebPage(MainWindow.MapInfoURL $ CurrentMapName $ ".htm");

				break;

				case ReportButton1:
					GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE REPORT PC");
				break;

				case ReportButton2:
					GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE REPORT SEQ");
				break;

				case TipsButton:
					MainWindow.BrowseWebPage("www.planetunreal.com:80/BDBUnreal/MapVoteTips.htm");
				break;

				case AboutButton:
					MainWindow.BrowseWebPage("www.planetunreal.com:80/BDBUnreal/AboutMapVote303.htm");
				break;

				case HelpButton:
					MainWindow.BrowseWebPage("www.planetunreal.com:80/BDBUnreal/MapVoteHelp.htm");
				break;

				case CloseButton:
					Root.CloseActiveWindow();
				break;
			}
		break;
	}
}

//-----------------------------------------------------------------------------
function Close(bool ByParent)
{
	// only show first time
	class'MapVoteNavBar'.default.bShowWelcomeWindow = false;
	Super.Close(ByParent);
}