//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MatchVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class MapVoteWRI expands WRI;

var 	BDBMapVote 				MapVoteMutator;

var 	string 					MapList1[257];
var 	string 					MapList2[257];
var 	string 					MapList3[257];
var 	string 					MapList4[257];
var 	string  				MapList5[257];
var 	string 					MapList6[257];
var		string 					MapList7[257];
var 	string 					MapList8[257];
var 	string 					MapList9[257];
var 	string 					MapList10[257];
var 	string 					MapList11[257];
var 	string 					MapList12[257];
var 	string 					MapList13[257];
var 	string 					MapList14[257];
var 	string 					MapList15[257];
var 	string 					MapList16[257];
var 	string 					MapVoteResults[100];
var 	string 					PlayerName[32];

var		string 					BunnyTrackTournamentIP;
var		string 					LinkButton1;
var		string 					LinkButton1Name;
var		string 					LinkButton2;
var		string 					LinkButton2Name;
var		string 					LinkButton3;
var		string 					LinkButton3Name;
var		string 					LinkButton4;
var		string 					LinkButton4Name;
var		string 					LinkButton5;
var		string 					LinkButton5Name;

var 	string 					AdminData;
var 	bool 					bAutoOpen;
var 	int 					MapCount;
var 	int 					MinMapCount;
var 	int 					PlayerCount;
var 	int 					VoteTimeLimit;
var 	int  					ScoreBoardDelay;
var 	int 					MidGameVotePercent;

replication
{
	// Variables the server should send to the client.
	reliable if (Role == ROLE_Authority)
		MapCount,
		PlayerName,
		PlayerCount,
		AddNewPlayer,
		RemovePlayerName,
		MapVoteResults,
		UpdateMapVoteResults,
		AdminData,
		VoteTimeLimit,
		bAutoOpen,
		ScoreBoardDelay,
		MidGameVotePercent,
		MinMapCount,
		BunnyTrackTournamentIP,
		LinkButton1,
		LinkButton1Name,
		LinkButton2,
		LinkButton2Name,
		LinkButton3,
		LinkButton3Name,
		LinkButton4,
		LinkButton4Name,
		LinkButton5,
		LinkButton5Name;
}

simulated function bool SetupWindow()
{
	if (Super.SetupWindow())
		settimer(0.01, false);
	else
		log("Super.SetupWindow() = false");
}

simulated event timer()
{
	local int i, MyCount, MyPlayerCount;
	local TempMapList TempList;

	i = MapCount;
	i = PlayerCount;
	MyCount = 0;

	MapVoteTabWindow(TheWindow).MapWindow.lblMapCount.SetText("Total Maps: " $ MapCount $ " Maps");
	MapVoteTabWindow(TheWindow).MapWindow.LinkButton1 = LinkButton1;
	MapVoteTabWindow(TheWindow).MapWindow.LinkButton1Button.Text = LinkButton1Name;
	MapVoteTabWindow(TheWindow).MapWindow.LinkButton2 = LinkButton2;
	MapVoteTabWindow(TheWindow).MapWindow.LinkButton2Button.Text = LinkButton2Name;
	MapVoteTabWindow(TheWindow).MapWindow.LinkButton3 = LinkButton3;
	MapVoteTabWindow(TheWindow).MapWindow.LinkButton3Button.Text = LinkButton3Name;
	MapVoteTabWindow(TheWindow).MapWindow.LinkButton4 = LinkButton4;
	MapVoteTabWindow(TheWindow).MapWindow.LinkButton4Button.Text = LinkButton4Name;
	MapVoteTabWindow(TheWindow).MapWindow.LinkButton5 = LinkButton5;
	MapVoteTabWindow(TheWindow).MapWindow.LinkButton5Button.Text = LinkButton5Name;
	MapVoteTabWindow(TheWindow).SettingsWindow.BTServerIP = BunnyTrackTournamentIP;
	MapVoteTabWindow(TheWindow).SettingsWindow.LinkButton1 = LinkButton1;
	MapVoteTabWindow(TheWindow).SettingsWindow.LinkButton1Button.Text = LinkButton1Name;
	MapVoteTabWindow(TheWindow).SettingsWindow.LinkButton2 = LinkButton2;
	MapVoteTabWindow(TheWindow).SettingsWindow.LinkButton2Button.Text = LinkButton2Name;
	MapVoteTabWindow(TheWindow).SettingsWindow.LinkButton3 = LinkButton3;
	MapVoteTabWindow(TheWindow).SettingsWindow.LinkButton3Button.Text = LinkButton3Name;
	MapVoteTabWindow(TheWindow).SettingsWindow.LinkButton4 = LinkButton4;
	MapVoteTabWindow(TheWindow).SettingsWindow.LinkButton4Button.Text = LinkButton4Name;
	MapVoteTabWindow(TheWindow).SettingsWindow.LinkButton5 = LinkButton5;
	MapVoteTabWindow(TheWindow).SettingsWindow.LinkButton5Button.Text = LinkButton5Name;
	
	foreach AllActors(class'BTMatchVote2.TempMapList', TempList)
	{
		if (TempList.Owner == Owner)
		{
			for (i = 1; i <= MapCount; i++)
			{
				if (i < 256)               MapList1[i]         = TempList.MapList[i - 1];
				if (i >= 256 && i < 511)   MapList2[i - 255]   = TempList.MapList[i - 1];
				if (i >= 511 && i < 766)   MapList3[i - 510]   = TempList.MapList[i - 1];
        		if (i >= 766 && i < 1021)  MapList4[i - 765]   = TempList.MapList[i - 1];
        		if (i >= 1021 && i < 1276) MapList5[i - 1020]  = TempList.MapList[i - 1];
        		if (i >= 1276 && i < 1531) MapList6[i - 1275]  = TempList.MapList[i - 1];
        		if (i >= 1531 && i < 1786) MapList7[i - 1530]  = TempList.MapList[i - 1];
        		if (i >= 1786 && i < 2041) MapList8[i - 1785]  = TempList.MapList[i - 1];
        		if (i >= 2041 && i < 2296) MapList9[i - 2040]  = TempList.MapList[i - 1];
        		if (i >= 2296 && i < 2551) MapList10[i - 2295] = TempList.MapList[i - 1];
        		if (i >= 2551 && i < 2806) MapList11[i - 2550] = TempList.MapList[i - 1];
        		if (i >= 2806 && i < 3061) MapList12[i - 2805] = TempList.MapList[i - 1];
        		if (i >= 3061 && i < 3316) MapList13[i - 3060] = TempList.MapList[i - 1];
        		if (i >= 3316 && i < 3571) MapList14[i - 3315] = TempList.MapList[i - 1];
				if (i >= 3571 && i < 3826) MapList15[i - 3570] = TempList.MapList[i - 1];
        		if (i >= 3826)             MapList16[i - 3825] = TempList.MapList[i - 1];
			}
		}
	}

	// count how many PlayerNames have replicated
	while (PlayerName[MyPlayerCount++] != "");
		MapVoteTabWindow(TheWindow).UpdateAdmin(AdminData, VoteTimeLimit, ScoreBoardDelay, MidGameVotePercent);

	for(i = 0; MapVoteResults[i] != "" && i < 99; i++)
		UpdateMapVoteResults(MapVoteResults[i],i);

	if (MapCount > 0)
	{
		for (i = 1; MapList1[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList2[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList3[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList4[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList5[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList6[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList7[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList8[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList9[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList10[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList11[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList12[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList13[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList14[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList15[i] != "" && i < 256; i++) MyCount++;
		for (i = 1; MapList16[i] != "" && i < 256; i++) MyCount++;

		if (MyCount < MapCount || MyPlayerCount < PlayerCount)
		{
			SetTimer(1, false);
			return;
		}

		for (i = 1; i <= MapCount; i++)
		{
      		if (i < 256)               MapVoteTabWindow(TheWindow).AddMapName(MapList1[i]);
      		if (i >= 256 && i < 511)   MapVoteTabWindow(TheWindow).AddMapName(MapList2[i - 255]);
      		if (i >= 511 && i < 766)   MapVoteTabWindow(TheWindow).AddMapName(MapList3[i - 510]);
      		if (i >= 766 && i < 1021)  MapVoteTabWindow(TheWindow).AddMapName(MapList4[i - 765]);
      		if (i >= 1021 && i < 1276) MapVoteTabWindow(TheWindow).AddMapName(MapList5[i - 1020]);
      		if (i >= 1276 && i < 1531) MapVoteTabWindow(TheWindow).AddMapName(MapList6[i - 1275]);
      		if (i >= 1531 && i < 1786) MapVoteTabWindow(TheWindow).AddMapName(MapList7[i - 1530]);
      		if (i >= 1786 && i < 2041) MapVoteTabWindow(TheWindow).AddMapName(MapList8[i - 1785]);
      		if (i >= 2041 && i < 2296) MapVoteTabWindow(TheWindow).AddMapName(MapList9[i - 2040]);
      		if (i >= 2296 && i < 2551) MapVoteTabWindow(TheWindow).AddMapName(MapList10[i - 2295]);
      		if (i >= 2551 && i < 2806) MapVoteTabWindow(TheWindow).AddMapName(MapList11[i - 2550]);
      		if (i >= 2806 && i < 3061) MapVoteTabWindow(TheWindow).AddMapName(MapList12[i - 2805]);
      		if (i >= 3061 && i < 3316) MapVoteTabWindow(TheWindow).AddMapName(MapList13[i - 3060]);
      		if (i >= 3316 && i < 3571) MapVoteTabWindow(TheWindow).AddMapName(MapList14[i - 3315]);
      		if (i >= 3571 && i < 3826) MapVoteTabWindow(TheWindow).AddMapName(MapList15[i - 3571]);
      		if (i >= 3826)             MapVoteTabWindow(TheWindow).AddMapName(MapList16[i - 3825]);
		}
		// fill player list-box with player names
		for (i = 0; i < PlayerCount; i++)
			MapVoteTabWindow(TheWindow).AddPlayerName(PlayerName[i]);
	}
}

//-----------------------------------------------------------------------------
// executes on server
//-----------------------------------------------------------------------------
function GetServerConfig()
{
	if (class'BTMatchVote2.BDBMapVote'.default.bAutoOpen)
		AdminData = AdminData $ "1";
	else
		AdminData = AdminData $ "0";

	bAutoOpen          			= class'BTMatchVote2.BDBMapVote'.default.bAutoOpen;
	VoteTimeLimit      			= class'BTMatchVote2.BDBMapVote'.default.VoteTimeLimit;
	ScoreBoardDelay    			= class'BTMatchVote2.BDBMapVote'.default.ScoreBoardDelay;
	MidGameVotePercent 			= class'BTMatchVote2.BDBMapVote'.default.MidGameVotePercent;
	BunnyTrackTournamentIP		= class'BTMatchVote2.BDBMapVote'.default.BunnyTrackTournamentIP;
	LinkButton1					= class'BTMatchVote2.BDBMapVote'.default.LinkButton1;
	LinkButton1Name				= class'BTMatchVote2.BDBMapVote'.default.LinkButton1Name;
	LinkButton2					= class'BTMatchVote2.BDBMapVote'.default.LinkButton2;
	LinkButton2Name				= class'BTMatchVote2.BDBMapVote'.default.LinkButton2Name;
	LinkButton3					= class'BTMatchVote2.BDBMapVote'.default.LinkButton3;
	LinkButton3Name				= class'BTMatchVote2.BDBMapVote'.default.LinkButton3Name;
	LinkButton4					= class'BTMatchVote2.BDBMapVote'.default.LinkButton4;
	LinkButton4Name				= class'BTMatchVote2.BDBMapVote'.default.LinkButton4Name;
	LinkButton5					= class'BTMatchVote2.BDBMapVote'.default.LinkButton5;
	LinkButton5Name				= class'BTMatchVote2.BDBMapVote'.default.LinkButton5Name;
}

//-------------------------------------------------------------------
// executes on client
//-------------------------------------------------------------------
simulated function AddNewPlayer(string NewPlayerName)
{
	MapVoteTabWindow(TheWindow).AddPlayerName(NewPlayerName);
}

//-------------------------------------------------------------------
// executes on client
//-------------------------------------------------------------------
simulated function RemovePlayerName(string OldPlayerName)
{
	MapVoteTabWindow(TheWindow).RemovePlayerName(OldPlayerName);
}

//-------------------------------------------------------------------
// executes on client
//-------------------------------------------------------------------
simulated function UpdateMapVoteResults(string Text, int i)
{
	MapVoteTabWindow(TheWindow).UpdateMapVoteResults(Text, i);
}

//-------------------------------------------------------------------
// WinHeight=shirina WinWidth - visota
//-------------------------------------------------------------------

defaultproperties
{
    WindowClass=Class'BTMatchVote2.MapVoteTabWindow'
    WinLeft=50
    WinTop=30
    WinWidth=946
    WinHeight=746
}