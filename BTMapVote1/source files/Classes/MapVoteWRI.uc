//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
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

var 	string 					Mode;
var 	string 					ReportText;
var 	string 					MapInfoURL;
var 	string 					ServerInfoURL;
var 	string 					AdminData;
var 	string 					GameTypes;
var 	string 					OtherClass;
var 	string 					PreFixSwap;
var 	string 					OtherPreFix;
var 	string 					HasStartWindow;
var 	string 					MapPreFixOverRide;
var 	string 					MapVoteHistoryType;
var		string 					BunnyTrackTournamentIP;

var 	int 					MapCount;
var 	int 					MinMapCount;
var 	int 					PlayerCount;
var 	int 					RepeatLimit;
var 	int 					VoteTimeLimit;
var 	int  					ScoreBoardDelay;
var 	int 					MidGameVotePercent;

var 	bool 					bAutoOpen;
var 	bool 					bAutoDetect;
var 	bool 					bUseMapList;
var 	bool 					bEntryWindows;
var 	bool 					bSortWithPreFix;
var 	bool 					bCheckOtherGameTie;

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
	OtherClass,
	VoteTimeLimit,
	bUseMapList,
	bAutoOpen,
	ScoreBoardDelay,
	bAutoDetect,
	bCheckOtherGameTie,
	ServerInfoURL,
	MapInfoURL,
	SendReportText,
	Mode,
	RepeatLimit,
	MapVoteHistoryType,
	MidGameVotePercent,
	MinMapCount,
	MapPreFixOverRide,
	PreFixSwap,
	OtherPreFix,
	HasStartWindow,
	bEntryWindows,
	bSortWithPreFix,
	BunnyTrackTournamentIP;
}

simulated function bool SetupWindow()
{
	local int i;

	// Increase the length of time messages stay on screen
	class'SayMessagePlus'.default.Lifetime      = class'BTMapVote1.BDBMapVote'.default.MsgTimeOut;
	class'CriticalStringPlus'.default.Lifetime  = class'BTMapVote1.BDBMapVote'.default.MsgTimeOut;
	class'RedSayMessagePlus'.default.Lifetime   = class'BTMapVote1.BDBMapVote'.default.MsgTimeOut;
	class'TeamSayMessagePlus'.default.Lifetime  = class'BTMapVote1.BDBMapVote'.default.MsgTimeOut;
	class'StringMessagePlus'.default.Lifetime   = class'BTMapVote1.BDBMapVote'.default.MsgTimeOut;
	class'DeathMessagePlus'.default.Lifetime    = class'BTMapVote1.BDBMapVote'.default.MsgTimeOut;

	if (Super.SetupWindow())
		settimer(1, false);
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

	foreach AllActors(class'BTMapVote1.TempMapList', TempList)
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
    MapVoteTabWindow(TheWindow).UpdateAdmin(AdminData, OtherClass, VoteTimeLimit, ScoreBoardDelay, RepeatLimit, MapVoteHistoryType, MidGameVotePercent, Mode, MinMapCount, MapPreFixOverRide);

	for(i = 0; MapVoteResults[i] != "" && i < 99; i++)
		UpdateMapVoteResults(MapVoteResults[i],i);

	MapVoteTabWindow(TheWindow).MapWindow.lblMapCount.SetText("Total Maps: " $ MapCount $ " Maps");
	MapVoteTabWindow(TheWindow).SettingsWindow.BTServerIP = BunnyTrackTournamentIP;

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
			settimer(1, false);
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
	if (class'BTMapVote1.BDBMapVote'.default.bBT)
		GameTypes = GameTypes $ "1";
	else
		GameTypes = GameTypes $ "0";

	if (class'BTMapVote1.BDBMapVote'.default.bCTF)
		GameTypes = GameTypes $ "1";
	else
		GameTypes = GameTypes $ "0";

	if (class'BTMapVote1.BDBMapVote'.default.bOther)
		GameTypes = GameTypes $ "1";
	else
		GameTypes = GameTypes $ "0";

	if (class'BTMapVote1.BDBMapVote'.default.UseCache)
		AdminData = "1";
	else
		AdminData = "0";

	if (class'BTMapVote1.BDBMapVote'.default.bUseMapList)
		AdminData = AdminData $ "1";
	else
		AdminData = AdminData $ "0";

	if (class'BTMapVote1.BDBMapVote'.default.bAutoOpen)
		AdminData = AdminData $ "1";
	else
		AdminData = AdminData $ "0";

	if (class'BTMapVote1.BDBMapVote'.default.bAutoDetect)
		AdminData = AdminData $ "1";
	else
		AdminData = AdminData $ "0";

	if (class'BTMapVote1.BDBMapVote'.default.bCheckOtherGameTie)
		AdminData = AdminData $ "1";
	else
		AdminData = AdminData $ "0";

	AdminData          		= GameTypes $AdminData;
	OtherClass         		= class'BTMapVote1.BDBMapVote'.default.OtherClass;
	VoteTimeLimit      		= class'BTMapVote1.BDBMapVote'.default.VoteTimeLimit;
	bUseMapList        		= class'BTMapVote1.BDBMapVote'.default.bUseMapList;
	bAutoOpen          		= class'BTMapVote1.BDBMapVote'.default.bAutoOpen;
	ScoreBoardDelay    		= class'BTMapVote1.BDBMapVote'.default.ScoreBoardDelay;
	bAutoDetect        		= class'BTMapVote1.BDBMapVote'.default.bAutoDetect;
	bCheckOtherGameTie 		= class'BTMapVote1.BDBMapVote'.default.bCheckOtherGameTie;
	ServerInfoURL      		= class'BTMapVote1.BDBMapVote'.default.ServerInfoURL;
	MapInfoURL         		= class'BTMapVote1.BDBMapVote'.default.MapInfoURL;
	Mode               		= class'BTMapVote1.BDBMapVote'.default.Mode;
	RepeatLimit        		= class'BTMapVote1.BDBMapVote'.default.RepeatLimit;
	MapVoteHistoryType 		= class'BTMapVote1.BDBMapVote'.default.MapVoteHistoryType;
	MidGameVotePercent 		= class'BTMapVote1.BDBMapVote'.default.MidGameVotePercent;
	MinMapCount        		= class'BTMapVote1.BDBMapVote'.default.MinMapCount;
	MapPreFixOverRide  		= class'BTMapVote1.BDBMapVote'.default.MapPreFixOverRide;
	HasStartWindow     		= class'BTMapVote1.BDBMapVote'.default.HasStartWindow;
	bEntryWindows      		= class'BTMapVote1.BDBMapVote'.default.bEntryWindows;
	PreFixSwap         		= class'BTMapVote1.BDBMapVote'.default.PreFixSwap;
	BunnyTrackTournamentIP	= class'BTMapVote1.BDBMapVote'.default.BunnyTrackTournamentIP;

	if (MapVoteMutator.OtherGameClass != None)
		OtherPreFix = MapVoteMutator.OtherGameClass.default.MapPreFix;

	bSortWithPreFix = class'BTMapVote1.BDBMapVote'.default.bSortWithPreFix;
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
simulated function SendReportText(string p_ReportText)
{
	if (p_ReportText == "")
	{
		MapVoteTabWindow(TheWindow).InfoWindow.SetMOTD(ReportText);
		ReportText = "";
	}
	else
		ReportText = ReportText $ p_ReportText;
}

//-------------------------------------------------------------------
// WinHeight=shirina WinWidth - visota
//-------------------------------------------------------------------

defaultproperties
{
    WindowClass=Class'BTMapVote1.MapVoteTabWindow'
    WinLeft=50
    WinTop=30
    WinWidth=946
    WinHeight=746
}