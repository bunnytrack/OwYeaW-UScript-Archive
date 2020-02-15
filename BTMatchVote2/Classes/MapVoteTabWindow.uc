//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MatchVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class MapVoteTabWindow expands UWindowDialogClientWindow;

var 	UMenuPageControl 		Pages;
var 	MapVoteClientWindow 	MapWindow;
var 	SettingsWindow 			SettingsWindow;
var 	AdminTabWindow 			AdminWindow;
var 	string					PrevSelectedMap;
var		bool					bGoldTheme;
//-----------------------------------------------------------------------------
function Created()
{  
	local UWindowPageControlPage PageControl;
	WinLeft = (Root.WinWidth - WinWidth) / 2;
	WinTop = (Root.WinHeight - WinHeight) / 2;
	
	if (Root.LookAndFeelClass != "UMenu.UMenuBlueLookAndFeel" )
		bGoldTheme = True;

	Pages = UMenuPageControl(CreateWindow(class'MapVotePageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(false);

	// Add the Maplist Window
	PageControl = Pages.AddPage("BT Maplist", class'MapVoteClientWindow');
	MapWindow = MapVoteClientWindow(PageControl.Page);

	// Add the Settings window
	PageControl = Pages.AddPage( "BT Settings", class'SettingsWindow');
	SettingsWindow = SettingsWindow(PageControl.Page);
/*
	if (GetPlayerOwner().PlayerReplicationInfo.bAdmin) // only show this tab to the Admin
	{
		// Add the Admin window
		PageControl = Pages.AddPage("Admin", class'AdminTabWindow');
		AdminWindow = AdminTabWindow(PageControl.Page);
	}
*/	
	Super.Created();
}

//-----------------------------------------------------------------------------
function AddMapName(String MapName)
{
	local UMenuMapVoteList I;

	I = UMenuMapVoteList(MapWindow.MapListBox.Items.Append(class'UMenuMapVoteList'));
	I.MapName = MapName;
}

//-----------------------------------------------------------------------------
function AddPlayerName(String PlayerName)
{
	local PlayerVoteListItem I;
	local UWindowList Item;

	 log("AddPlayerName("$PlayerName$")");
	// check to see if this player name is already in the list
	for (Item = MapWindow.PlayerListBox.Items; Item != None;Item = Item.Next)
	{
		if (PlayerVoteListItem(Item).PlayerName == PlayerName)
			return;
	}

	// add it to the list box
	I = PlayerVoteListItem(MapWindow.PlayerListBox.Items.Append(class'PlayerVoteListItem'));
	I.PlayerName = PlayerName;
}

//-----------------------------------------------------------------------------
function RemovePlayerName(string PlayerID)
{
	local UWindowList Item;

	// Changed from using PlayerName to PlayerIDs. Example PlayerID = 005
	for (Item = MapWindow.PlayerListBox.Items; Item != None;Item = Item.Next)
	{
		// PlayerName Format in list box = TPPPNNNNNNNN  T = Team, PPP = PlayerID, NNNN = PlayerName
		if (Mid(PlayerVoteListItem(Item).PlayerName, 1, 3) == PlayerID)
		{
			Item.Remove();
			return;
		}
	}
}

//-----------------------------------------------------------------------------
function UpdateAdmin(string p_AdminData, int p_VoteTimeLimit, int p_ScoreBoardDelay, int p_MidGameVotePercent)
{
	local AdminWindow Window;

	if (AdminWindow != None)
	{
		Window = AdminWindow(AdminWindow.ClientArea);

		Window.cbLoadFromCache.bChecked     = bool(Mid(p_AdminData, 3, 1)); 
		Window.cbUseMapList.bChecked        = bool(Mid(p_AdminData, 4, 1)); 
		Window.cbAutoOpen.bChecked          = bool(Mid(p_AdminData, 5, 1));
		Window.sldVoteTimeLimit.SetValue(p_VoteTimeLimit);
		Window.sldScoreBoardDelay.SetValue(p_ScoreBoardDelay);
		Window.sldMidGameVotePercent.SetValue(p_MidGameVotePercent);
	}
}

//-----------------------------------------------------------------------------
simulated function UpdateMapVoteResults(string Text, int i)
{
	local UWindowList Item;
	local string MapName;
	local int c, pos;

	if (Text == "Clear")
	{
		if (MapWindow.MapStatus.SelectedItem != None)
			PrevSelectedMap = MapStatusListItem(MapWindow.MapStatus.SelectedItem).MapName;

		MapWindow.MapStatus.Items.Clear();
		return;
	}

	pos = Instr(Text, ",");
	if (pos > 0)
	{
		MapName = left(Text, pos);
		c = int(Mid(Text, pos + 1));
	}

	// check to see if MapName is already in the list
	for (Item = MapWindow.MapStatus.Items; Item != None; Item = Item.Next)
	{
		if (MapStatusListItem(Item).MapName == MapName)
		{
			MapStatusListItem(Item).Rank = i + 1;
			MapStatusListItem(Item).VoteCount = c;
			return;
		}
	}

	// Add it to the list
	Item = MapStatusListItem(MapWindow.MapStatus.Items.Append(class'MapStatusListItem'));
	MapStatusListItem(Item).Rank = i + 1;
	MapStatusListItem(Item).MapName = MapName;
	MapStatusListItem(Item).VoteCount = c;

	// re-select previously selected map
	if (PrevSelectedMap == MapName)
		MapWindow.MapStatus.SelectMap(PrevSelectedMap);
}