//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class BDBMapVote expands Mutator config (BTMapVote1);

var 	bool   					bInitialized, bMidGameVote;
var 	bool 					NeedSaving, NeedLoading;
var 	string 					MapList[4096], MapStatusText[100];
var 	int    					PlayerIDList[32];			// список ид игроков   
var 	int      				PlayerVote[32];				// индекс проголосованных карт
var 	float    				EndGameTime;
var 	int      				CurrentID,JoinTickCount, MapCount;
var 	string   				AllowedSymbols;
var 	int   					CountBTPref;
var 	string 					ServerIdentKey;          	// ключ защиты от переноса на другой сервер

var		config string			BunnyTrackTournamentIP;		// BunnyTrack Tournament Server IP - RESPECT THE MAKER OF THE MAPVOTE, AND KEEP THE BUTTON WORKING ;)
var		config string			BTGameType;					// BT GAMETYPE - FOR EXAMPLE: BunnyTrack2.BunnyTrackGame OR Botpack.CTFGame
var 	config bool 			bResetIfNotVoted;			// SERVER SWITCHES TO RESET MAP IF NOT VOTED AT END OF GAME
var		config string 			ResetMap;					// RESET MAP - FOR bResetIfNotVoted
var 	config int 				MidGameVotePercent;         // процент проголосовавших, при котором срабатывает автоматический запуск мапвоты
var 	config int 				VoteTimeLimit;
var 	config int 				ScoreBoardDelay;
var 	config int 				NotVoteTime;                // время после старта сервера, при котором  нельзя ещё голосовать;
var 	config string 			UpdateKey;               	// Ключ апдейта карт, позволяет синхронизировать кеши клиента и сервера;
var 	config int 				MapsCacheCount;             // количество карт в кеше
var 	config string 			MapCacheList[4096] ;      	// список карт в кеше

var 	bool 					bAutoDetect;                // Автодетектирование режимов
var 	bool 					bCTF, bBT, bOther, bBT_CTF; // Префиксы, которые будут использоваться при загрузке карт
var 	bool 					bSortWithPreFix;            // Установить false для отмены сортировки по префиксам;
var 	bool 					bUseMapList;                // Использовать маплисты из самих модов; 
var 	bool 					bAutoOpen;                  // Автооткрытие в конце игры окна голосования
var 	bool 					bCheckOtherGameTie;
var 	bool 					bEntryWindows;              // false = не открывать окно приветствия и окно бинда при входе игрока на сервер
var 	bool 					UseCache;                   // Разрешение использовать кеш на стороне сервера (упростить!)
var 	string 					OtherClass;               	// Используется для определения режима при автодетектировании или использовании неизвестного класса;
var 	string 					Mode;                     	// Режим мапвоты (упростить!);
var 	string 					MapPreFixOverRide;        	// Разрешает сменить префиксы в списке карт на заданные;
var 	string 					PreFixSwap;               	// map name prefix to change too
var 	string 					MapVoteHistoryType;       	// Тип используемой истории??
var 	string 					ServerInfoURL;            	//  путь к информации о сервере
var 	string 					MapInfoURL;               	//  путь к информации о карте
var 	string 					HasStartWindow;           	// Yes,No,Auto - Разрешение запуска стартовых окон (например, )

var 	int 					MsgTimeOut;                 // настройка клиента. Устанавливает время отображения сообщений ???
var 	int 					RepeatLimit;
var 	int 					MinMapCount;

var 	string 					AccName[32];              	// use for Accumulation mode
var 	int    					AccVotes[32];             	// use for Accumulation mode

var 	int 					TimeLeft, ScoreBoardTime, ServerTravelTime;
var 	class<GameInfo> 		OtherGameClass;
var 	TempMapList 			TML;
var 	class<MapVoteHistory> 	MapVoteHistoryClass;
var 	bool 					bLevelSwitchPending;
var 	string 					ServerTravelString;
var 	int 					MarkedMapCount;          	// total number of maps that have not been elimitated.

//-----------------------------------------------------------------------------
function PreBeginPlay()
{
	local int x, z;

	if (!bInitialized)
	{
		for (x = 0; x < 32; x++)
			PlayerIDList[x] = -1;

		if (!UseCache || MapCacheList[0] == "")
		{
			LoadMaps();    // load all the map names in the maplist array
			SortMapList(); // sort the maplist in alphabetic order
		}
		if (UseCache && MapCacheList[0] != "")
		{
			NeedLoading=True;
			CacheOperator();
		}
		bInitialized = true;
	}

	Super.PreBeginPlay();
}

//-----------------------------------------------------------------------------
function Mutate(string MutateString, PlayerPawn Sender)
{
	local string MapName;
	local string PlayerName;
	local int PlayerID, pos, seq;
	local MapVoteReport MVReport;
	local int ObjectCount;
	local MapVoteWRI MVWRI;
	local MapVoteHistory MVHistory;

	Super.Mutate(MutateString, Sender);

	// MUTATE BDBMAPVOTE VOTEMENU
	if (left(Caps(MutateString), 10) == "BDBMAPVOTE")
	{
		if (Mid(Caps(MutateString), 11, 8) == "VOTEMENU")
		{
			// make sure they cant vote before other players have joined server
			if (Level.TimeSeconds > NotVoteTime || Level.Netmode == NM_Standalone)
			{
				if (!Sender.IsA('Spectator'))
				{
					CleanUpPlayerIDs();
					OpenVoteWindow(Sender);
				}
				else
				{
					CleanUpPlayerIDs();
					OpenVoteWindow(Sender);
					if (Sender.bAdmin)
						Sender.ClientMessage("[BT-MapVote] You are admin and can switch map");
				}
			}
			else
				Sender.ClientMessage("Please Wait" @ int(NotVoteTime - Level.TimeSeconds) @ "seconds to vote");
		}

    //---------------------------------------------
    if (Mid(Caps(MutateString), 11, 3) == "MAP")
    {
		MapName = mid(MutateString, 15);
		if (Sender.bAdmin)
		{
			// remove [X]
			if (Left(MapName, 3) == "[X]")
				MapName = mid(MapName, 3);

			BroadcastMessage("[BT-MapVote] The Server Admin has forced a map switch to " $ MapName, true);
			ServerTravelString = SetupGameMap(MapName);
			CloseAllVoteWindows();
			Level.ServerTravel(ServerTravelString, false);
		}
	    else 
			SubmitVote(MapName,Sender);
    }

    //---------------------------------------------
    if (Mid(Caps(MutateString), 11, 10) == "RELOADMAPS")
    {
		if (Sender.bAdmin)
		{
			MapCacheList[0] = "";
			LoadMaps();
			SortMapList();
			BroadcastMessage("[BT-MapVote] MapVote configuration has been changed, Re-Open Voting window for updates", true);
		}
    }

    //---------------------------------------------
    if (Mid(Caps(MutateString), 11, 6) == "REPORT")
    {
		// count MapVoteReports
		ObjectCount = 0;
		foreach AllActors(class'MapVoteReport', MVReport)
        ObjectCount++;

		if (ObjectCount > 0)
		{   
			Sender.ClientMessage("[BT-MapVote] Sorry, The server can only run one report at a time, please try again later");
			return;
		}

		MVReport = spawn(class'MapVoteReport');
		if (MVReport != none)
        MVReport.RunRport(Caps(Mid(MutateString, 18)), Sender, MapVoteHistoryClass);
		else
			log("Failed to spawn MVReport");
    }

    //---------------------------------------------
    if (Mid(Caps(MutateString), 11, 6) == "STATUS")
    {
		Sender.ClientMessage("[BT-MapVote] Total Map Count is " $ MapCount);

		// count MapVoteWRIs
		ObjectCount = 0;
		foreach AllActors(class'MapVoteWRI', MVWRI)
        ObjectCount++;

		Sender.ClientMessage("[BT-MapVote] Active MapVoteWRI count is " $ ObjectCount);

		// count MapVoteReports
		ObjectCount = 0;
		foreach AllActors(class'MapVoteReport', MVReport)
        ObjectCount++;

		Sender.ClientMessage("[BT-MapVote] Active MapVoteReport count is " $ ObjectCount);

		// count MapVoteHistorys
		ObjectCount = 0;
		foreach AllActors(class'MapVoteHistory', MVHistory)
        ObjectCount++;

		Sender.ClientMessage("[BT-MapVote] Active MapVoteHistory count is " $ ObjectCount);
    }

    //---------------------------------------------
    //       0123456789012345678901234567890
    //MUTATE BDBMAPVOTE SETSEQ MAPNAME -1
    if (Mid(Caps(MutateString), 11, 6) == "SETSEQ")
    {
		if (Sender.bAdmin)
		{
			MapName = Mid(MutateString, 18);
			pos = InStr(MapName, " ");

			if (pos < 1)
			{
				Sender.ClientMessage("[BT-MapVote] Syntax Error");
				return;
			}

			seq = int(Mid(MapName, pos + 1));
			MapName = Left(MapName, pos);
			MVHistory = spawn(MapVoteHistoryClass);
			MVHistory.SetMapSequence(MapName, seq);
			MVHistory.Save();
			MVHistory.Destroy();
			Sender.ClientMessage("Sequence changed !");
		}
		else
			Sender.ClientMessage("[BT-MapVote] You must be a server admin to perform this fuction");
    }

    //---------------------------------------------
    //       0123456789012345678901234567890
    //MUTATE BDBMAPVOTE SETPC MAPNAME -1
    if (Mid(Caps(MutateString), 11, 5) == "SETPC")
    {
		if (Sender.bAdmin)
		{
			MapName = Mid(MutateString, 17);
			pos = InStr(MapName, " ");

			if (pos < 1)
			{
				Sender.ClientMessage("[BT-MapVote] Syntax Error");
				return;
			}

			seq = int(Mid(MapName, pos + 1));
			MapName = Left(MapName, pos);
			MVHistory = spawn(MapVoteHistoryClass);
			MVHistory.SetPlayCount(MapName, seq);
			MVHistory.Save();
			MVHistory.Destroy();
			Sender.ClientMessage("PlayCount changed !");
		}
		else
			Sender.ClientMessage("[BT-MapVote] You must be a server admin to perform this fuction");
		}
	}
}

//-----------------------------------------------------------------------------
function OpenVoteWindow(PlayerPawn Sender)
{
	local MapVoteWRI MVWRI;
	local int x, playercount, y, i;
	local pawn p;
	local MapVoteWRI A;
	local int TeamID;
	local string PID;
	local bool LetsGo;

	if (bLevelSwitchPending)
		return;

	foreach AllActors(class'BTMapVote1.MapVoteWRI', A) // check all existing WRIs
	{
		if (Sender == A.Owner)
			return;
	}

	foreach AllActors(class'BTMapVote1.TempMapList', TML)
	{
		if (TML.Owner==Sender && TML.TransferDone)
			LetsGo = True;
	}

	if (LetsGo)
	{
		MVWRI = Spawn(class'BTMapVote1.MapVoteWRI', Sender, , Sender.Location);

		if (MVWRI == None)
		{
			Log("#### -- PostLogin :: Fail:: Could not spawn WRI");
			return;
		}

		MVWRI.MapCount = MapCount;
		MVWRI.MapVoteMutator = self;
		playercount = 0;

		for (p = Level.PawnList; p != None; p = p.nextPawn)
		{
			if (PlayerPawn(p) != none && p.bIsPlayer)
			{
				if (p.IsA('Spectator'))
					TeamID = 9;
				else
				{
					if (PlayerPawn(p).PlayerReplicationInfo.Team == 255)
						TeamID = 0;
					else
						TeamID = PlayerPawn(p).PlayerReplicationInfo.Team;      
				}
				PID = right("000" $ PlayerPawn(p).PlayerReplicationInfo.PlayerID, 3);
				MVWRI.PlayerName[playercount++] = TeamID $ PID $ PlayerPawn(p).PlayerReplicationInfo.PlayerName;
				// example: 1004BDB  =  Team 1, PlayerID 4, PlayerName BDB
			}
		}

		MVWRI.PlayerCount = playercount;

		// transfer Map Voting Status to status page window
		for (x = 0; MapStatusText[x] != "" && x < 99; x++)
			MVWRI.MapVoteResults[x] = MapStatusText[x];

		MVWRI.MapVoteResults[x] = "";
		y = 0;
		MVWRI.GetServerConfig();
	}
	if (!LetsGO)
		Sender.ClientMessage("[BT-MapVote] Downloading Maplist...");
}

//-----------------------------------------------------------------------------
function ReplicedTempMaplist(PlayerPawn Sender)
{
	local TempMapList A;
	local int i;

	if (bLevelSwitchPending)
		return;

	foreach AllActors(class'BTMapVote1.TempMapList', A)
	{
		if (Sender == A.Owner) 
			return;
	}

	TML = Spawn(class'BTMapVote1.TempMapList', Sender, , Sender.Location);
	if (TML == None)
	{
		Log("#### -- PostLogin :: Fail:: Could not spawn TempMapList");
		return;
	}

	TML.MapsCacheCount = MapsCacheCount;
	TML.ActorOwner = Sender;
	TML.serverUpdateKey = UpdateKey;

	for (i = 0; i <= MapsCacheCount; i++)
	{
		if (i < 256)               TML.TempList1[i]         = MapList[i];
		if (i >= 256 && i < 511)   TML.TempList2[i - 255]   = MapList[i];
		if (i >= 511 && i < 766)   TML.TempList3[i - 510]   = MapList[i];
		if (i >= 766 && i < 1021)  TML.TempList4[i - 765]   = MapList[i];
		if (i >= 1021 && i < 1276) TML.TempList5[i - 1020]  = MapList[i];
		if (i >= 1276 && i < 1531) TML.TempList6[i - 1275]  = MapList[i];
		if (i >= 1531 && i < 1786) TML.TempList7[i - 1530]  = MapList[i];
		if (i >= 1786 && i < 2041) TML.TempList8[i - 1785]  = MapList[i];
		if (i >= 2041 && i < 2296) TML.TempList9[i - 2040]  = MapList[i];
		if (i >= 2296 && i < 2551) TML.TempList10[i - 2295] = MapList[i];
		if (i >= 2551 && i < 2806) TML.TempList11[i - 2550] = MapList[i];
		if (i >= 2806 && i < 3061) TML.TempList12[i - 2805] = MapList[i];
		if (i >= 3061 && i < 3316) TML.TempList13[i - 3060] = MapList[i];
		if (i >= 3316 && i < 3571) TML.TempList14[i - 3315] = MapList[i];
		if (i >= 3571 && i < 3826) TML.TempList15[i - 3570] = MapList[i];
		if (i >= 3826)             TML.TempList16[i - 3825] = MapList[i];
	}
}

//-----------------------------------------------------------------------------
// this funtion maintains the list of players
// uses the PlayerID which should be unique for every player
// find the PlayerID in PlayerIDList array if it exists
function int FindPlayerIndex(int PlayerID)
{
	local int x;

	for (x = 0; x < 32; x++)
	{
		if (PlayerIDList[x] == PlayerID)
			return x;
	}

	// not found, so add to bottom of array
	for (x = 0; x < 32; x++)
	{
		if (PlayerIDList[x] == -1)
		{
			PlayerIDList[x] = PlayerID;
			return x;
		}
	}

	log("MAPVOTE ERROR ---- Could not find PlayerIndex");

	return -1;
}

//-----------------------------------------------------------------------------
// adds a player name to all open Voting windows
function AddNewPlayer(string NewPlayerName)
{
	local MapVoteWRI MVWRI;
	local pawn p;

	// check all existing WRIs
	foreach AllActors(class'BTMapVote1.MapVoteWRI', MVWRI)
		MVWRI.AddNewPlayer(NewPlayerName);
}

//-----------------------------------------------------------------------------
// removes a players name from all open Voting windows
function RemovePlayerName(string OldPlayerName)
{
	local MapVoteWRI MVWRI;
	local pawn p;

	// check all existing WRIs
	foreach AllActors(class'BTMapVote1.MapVoteWRI', MVWRI)
		MVWRI.RemovePlayerName(OldPlayerName);
}

//-----------------------------------------------------------------------------
// funkciia udaliaet ingormaciu pro vote igroka esli on pokinul server
function CleanUpPlayerIDs()
{
	local Pawn aPawn;
	local int x;
	local bool bFound;   

	for (x = 0; x < 32; x++) 
	{
		if (PlayerIDList[x] > -1)
		{
			bFound = false;
			for (aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn)
			{
				if (aPawn.bIsPlayer && aPawn.IsA('PlayerPawn') && PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID == PlayerIDList[x])
				{
					bFound = true;  
					break;
				}
			}
			if (!bFound)  
			{
				PlayerVote[x] = 0;
				PlayerIDList[x] = -1;
			}
		}
	}
}

//-----------------------------------------------------------------------------
// Получение имени игрока
// poluchit imia igroka po ego ID
//-----------------------------------------------------------------------------
function string GetPlayerName(int PlayerID)
{
	local pawn aPawn;
	local string PlayerName;

	PlayerName = "unknown";                                                        
	for (aPawn = Level.PawnList; aPawn!=None; aPawn = aPawn.NextPawn)
	{
		if (aPawn.bIsPlayer && PlayerPawn(aPawn) != None)
		{
			if (PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID == PlayerID)
			{
				PlayerName = right("000" $ PlayerID, 3) $ aPawn.PlayerReplicationInfo.PlayerName;
				break;
			}
		}
	}

	return PlayerName;
}

//-----------------------------------------------------------------------------
// Получение очков игрока
//-----------------------------------------------------------------------------
function float GetPlayerScore(int PlayerIndex)
{
	local pawn aPawn;
	local float PlayerScore;

	for (aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn)
	{
		if (aPawn.bIsPlayer && PlayerPawn(aPawn) != None)
		{
			if (PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID == PlayerIDList[PlayerIndex])
			{
				PlayerScore = PlayerPawn(aPawn).PlayerReplicationInfo.Score;
				break;
			}
		}
	}

	if (PlayerScore < 1)
		PlayerScore = 1;

	return PlayerScore;
}

//-----------------------------------------------------------------------------
// Получение результатов  аккумулятивного голосования
//-----------------------------------------------------------------------------
function int GetAccVote(int PlayerIndex)
{
	local pawn aPawn;
	local int x, PlayerAccVotes;
	local string PlayerName;

	for (aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn)
	{
		if (aPawn.bIsPlayer && PlayerPawn(aPawn) != None)
		{
			if (PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID == PlayerIDList[PlayerIndex])
			{
				PlayerName = PlayerPawn(aPawn).PlayerReplicationInfo.PlayerName;
				break;
			}
		}
	}

	if (PlayerName == "")
		return(0);

	// Find the players name in the saved accumulated votes
	for (x = 0; x < 32; x++)
	{
		if (AccName[x] == PlayerName)
		{
			PlayerAccVotes = AccVotes[x];
			break;
		}
	}

	if (PlayerAccVotes > 0)
		return PlayerAccVotes; // if found return the saved vote count

	// Not found, so find an empty slot and save it
	for (x = 0; x < 32; x++)
	{
		if (AccName[x] == "")
		{
		AccName[x] = PlayerName;
		AccVotes[x] = 1;
		break;
		}
	}

	return(1);
}

//-----------------------------------------------------------------------------
// Сохранение аккумулятивного голосования
//-----------------------------------------------------------------------------
function SaveAccVotes(int WinningMapIndex)
{
	local pawn aPawn;
	local int x;
	local bool bFound;

	for (x = 0; x < 32; x++)
	{
		if (AccName[x] != "")
		{
			bFound = false;
			for (aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn)
			{
				if (aPawn.bIsPlayer && PlayerPawn(aPawn) != None)
				{
					if (AccName[x] == PlayerPawn(aPawn).PlayerReplicationInfo.PlayerName)
					{
						if (PlayerVote[FindPlayerIndex(PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID)] != WinningMapIndex)
						{
							bFound = true;
							AccVotes[x]++;
						}
					break;
					}
				}
			}
			// If this player is not here anymore remove his/her votes
			if (!bFound)
			{
				AccName[x] = "";
				AccVotes[x] = 0;
			}
		}
	}
	// save votes to ini file
	for (x = 0; x < 32; x++)
	{
		class'BTMapVote1.BDBMapVote'.default.AccName[x] = AccName[x];
		class'BTMapVote1.BDBMapVote'.default.AccVotes[x] = AccVotes[x];
	}
	if (Level.NetMode != NM_Client )
		class'BTMapVote1.BDBMapVote'.static.StaticSaveConfig();
}

//-----------------------------------------------------------------------------
// Подсчёт голосов
//-----------------------------------------------------------------------------
function TallyVotes(bool bForceMapSwitch)
{
	local string MapName;
	local Actor  A;
	local int    index, x, y, topmap;
	local int    VoteCount[4081];
	local int    Ranking[32];
	local int    PlayersThatVoted;
	local int    TieCount;
	local string GameType,CurrentMap;
	local int i, textline;
	local MapVoteHistory History;

	if (bLevelSwitchPending)
		return;

	PlayersThatVoted = 0;
	// for each player
	for (x = 0; x < 32; x++)
	{
		// if this player has voted
		if (PlayerVote[x] != 0)
		{
			PlayersThatVoted++;

			// esli Mode= Score ,to Vote Count + ochky igroka
			if (Mode == "Score")
				VoteCount[PlayerVote[x]] = VoteCount[PlayerVote[x]] + int(GetPlayerScore(x));

			// esli Mode = Accumuliation, to Vote Count + znachenie iz GetAccVote(x)=)
			if (Mode == "Accumulation")
				VoteCount[PlayerVote[x]] = VoteCount[PlayerVote[x]] + GetAccVote(x);

			// esli Mode = Elimination i  Majority , to prosto delaem ++ dlia nugnoi mapi
			if (Mode == "Elimination" || Mode == "Majority")
			{
				// increment the votecount for this map
				VoteCount[PlayerVote[x]]++;
				if (float(VoteCount[PlayerVote[x]]) / float(Level.Game.NumPlayers) > 0.5 && Level.Game.bGameEnded)
					bForceMapSwitch = true;
			}
		}
	}

	// Mid game vote initiated
	if (!Level.Game.bGameEnded && !bMidGameVote && (float(PlayersThatVoted) / float(Level.Game.NumPlayers)) * 100 >= MidGameVotePercent && Level.Game.NumPlayers != 1)
	{
		BroadCastMessage("[BT-MapVote] Mid-Game Map Voting has been initiated");
		bMidGameVote = true;

		// Start voting count-down timer
		TimeLeft = VoteTimeLimit;
		ScoreBoardTime = 1;
		settimer(1, true);
	}

	index = 0;
	// for each map
	for (x = 1; x <= MapCount; x++)
	{
		// copy all map indexes to the ranking list if someone has voted for it.
		if (VoteCount[x] > 0)
			Ranking[index++] = x;
	}

	// bubble sort ranking list by vote count
	for (x = 0; x < index - 1; x++)
	{
		for (y = x + 1; y < index; y++)
		{
			if (VoteCount[Ranking[x]] < VoteCount[Ranking[y]])
			{
			topmap = Ranking[x];
			Ranking[x] = Ranking[y];
			Ranking[y] = topmap;
			}
		}
	}

	// Update Status Page
	for (x = 0; x < index; x++)
		MapStatusText[x] = MapList[Ranking[x]] $ "," $ VoteCount[Ranking[x]];

	MapStatusText[index] = "";

	UpdateOpenWRI();

	// Check for a tie
	if (VoteCount[Ranking[0]] == VoteCount[Ranking[1]] && VoteCount[Ranking[0]] != 0)
	{
		TieCount = 1;
		for (x = 1; x < index; x++)
		{
			if (VoteCount[Ranking[0]] == VoteCount[Ranking[x]])
			TieCount++;
		}

		// reminder ---> int Rand( int Max ); Returns a random number from 0 to Max-1.
		topmap = Ranking[Rand(TieCount)];

		// Don't allow same map to be choosen
		CurrentMap = GetURLMap();
		if (CurrentMap != "" && !(Right(CurrentMap, 4) ~= ".unr"))
			CurrentMap = CurrentMap $ ".unr";

		x = 0;
		while (MapList[topmap] ~= CurrentMap)
		{
			topmap = Ranking[Rand(TieCount)];
			x++;
			// just incase, don't want to waste alot of time choosing a random map
			if (x > 20)
			break;
		}
	}
	else 
		topmap = Ranking[0];

	// forces a map change even if everyone has not voted
	if (bForceMapSwitch)
	{
		// if noone has voted choose a map at random
		if (PlayersThatVoted == 0)
		{
			if(bResetIfNotVoted)
			{
				BroadCastMessage("[BT-MapVote] Switching to "$ ResetMap);
				consolecommand("servertravel "$ ResetMap);
			}
			else
				topmap = Rand(MapCount) + 1;
		}
	}

	// if everyone has voted go ahead and change map
	if (bForceMapSwitch || Level.Game.NumPlayers == PlayersThatVoted)
	{
		if (MapList[topmap] == "")
			return;

		BroadcastMessage("[BT-MapVote] " $ MapList[topmap] $ " has won.", true);
		CloseAllVoteWindows();
		bLevelSwitchPending = true;
		ServerTravelString = SetupGameMap(MapList[topmap]);
		ServerTravelTime = Level.TimeSeconds;

		// enable timer for mid game voting
		if (!Level.Game.bGameEnded)
			settimer(1, true);

		if (MapVoteHistoryClass == None)
			MapVoteHistoryClass = class<MapVoteHistory>(DynamicLoadObject(MapVoteHistoryType, class'Class'));

		History = spawn(MapVoteHistoryClass);
		if (History == None)
			log("Failed to spawn MapVoteHistory");
		else
		{
			History.AddMap(MapList[topmap]);
			History.Save();
			History.Destroy();
		}

		if (Mode == "Elimination")
		{
			RepeatLimit++;
			class'BTMapVote1.BDBMapVote'.default.RepeatLimit = RepeatLimit;

			if (Level.NetMode != NM_Client)
				class'BTMapVote1.BDBMapVote'.static.StaticSaveConfig();
		}

		if (Mode == "Accumulation")
			SaveAccVotes(topmap);
	}
}

//-----------------------------------------------------------------------------
// Апдейт открытых окон у клиентов
//-----------------------------------------------------------------------------
function UpdateOpenWRI()
{
	local MapVoteWRI MVWRI;
	local int x, y;

	foreach AllActors(class'BTMapVote1.MapVoteWRI', MVWRI)
	{
		// transfer Map Voting Status to status page window
		x = 0;
		MVWRI.UpdateMapVoteResults("Clear", x);

		while (MapStatusText[x] != "" && x < 99)
		{
			MVWRI.UpdateMapVoteResults(MapStatusText[x], x);
			x++;
		}

		// Mark the end
		MVWRI.UpdateMapVoteResults("", x);
		y = 0;
	}
}

//-----------------------------------------------------------------------------
// Сортировка карт. Функция модифицирована и может использоваться только для карт BunnyTrack
// (имеющие префикс BT- или CTF-BT-). Triggered by: PreBeginPlay(), Mutate().
//-----------------------------------------------------------------------------
function SortMapList()
{
	local int a, b;
	local int x, y;
	local string CurSymbol;
	local int curpos, prevpos;
	local string TempMapName, AMap, BMap;
	local TempMapList DestroyTML;
	local string ListOperator[4096];

	for (a = 1; a <= 54; a++)
	{
		CurSymbol = Caps(right(left(AllowedSymbols, a), 1));

		for (b = 1; b <= MapCount; b++)
		{
			if (caps(left(MapList[b], 3)) == "BT-" && Caps(right(left(MapList[b], 4), 1)) == CurSymbol)
			{
				ListOperator[curpos] = Mid(MapList[b], 3);
				curpos++;
			}
		}

		if (MapCount > 1)
		{
			for (x = prevpos; x < curpos - 1; x++)
			{
				for (y = x + 1; y < curpos; y++)
				{
					AMap = Caps(ListOperator[x]);
					BMap = Caps(ListOperator[y]);

					if (AMap > BMap)
					{
						TempMapName = ListOperator[x];
						ListOperator[x] = ListOperator[y];
						ListOperator[y] = TempMapName;
					}

					y++;
					if (y < curpos)
					{
						AMap = Caps(ListOperator[x]);
						BMap = Caps(ListOperator[y]);

						if (AMap > BMap)
						{
							TempMapName = ListOperator[x];
							ListOperator[x] = ListOperator[y];
							ListOperator[y] = TempMapName;
						}
					}

					y++;
					if (y < curpos)
					{
						AMap = Caps(ListOperator[x]);
						BMap = Caps(ListOperator[y]);
						if (AMap > BMap)
						{
							TempMapName = ListOperator[x];
							ListOperator[x] = ListOperator[y];
							ListOperator[y] = TempMapName;
						}
					}
				}
			}
		}
		prevpos = curpos;
	}

	CountBTPref = prevpos;
	for (a = 1; a <= 54; a++)
	{
		CurSymbol = Caps(right(left(AllowedSymbols, a), 1));
		for (b = 1; b <= MapCount; b++)
		{
			if (caps(left(MapList[b], 7)) == "CTF-BT-" && Caps(right(left(MapList[b], 7), 1)) == CurSymbol)
			{
				ListOperator[curpos] = Mid(MapList[b], 7);
				curpos++;
			}
		}

		if (MapCount > 1)
		{
			for (x = prevpos; x < curpos-1; x++)
			{
				for (y = x + 1; y < curpos; y++)
				{
					AMap = Caps(ListOperator[x]);
					BMap = Caps(ListOperator[y]);

					if (AMap > BMap)
					{
						TempMapName = ListOperator[x];
						ListOperator[x] = ListOperator[y];
						ListOperator[y] = TempMapName;
					}

					y++;
					if (y < curpos)
					{
						AMap = Caps(ListOperator[x]);
						BMap = Caps(ListOperator[y]); 

						if (AMap > BMap)
						{
							TempMapName = ListOperator[x]; 
							ListOperator[x] = ListOperator[y];
							ListOperator[y] = TempMapName;
						}
					} 

					y++;
					if (y < curpos)
					{
						AMap = Caps(ListOperator[x]);
						BMap = Caps(ListOperator[y]);

						if (AMap > BMap)
						{
							TempMapName = ListOperator[x]; 
							ListOperator[x] = ListOperator[y];
							ListOperator[y] = TempMapName;
						}
					}
				}
			}
		}
		prevpos = curpos;
	}

	for (x = 0; x < CountBTPref; x++)
	{
		ListOperator[x] = "BT-" $ ListOperator[x];
		MapList[x+1] = ListOperator[x]; 
	}
	
	for (x = 0; x < CountBTPref; x++)
	{
		ListOperator[x] = "BT+" $ ListOperator[x];
		MapList[x+1] = ListOperator[x]; 
	}

	for (x = CountBTPref; x < MapCount; x++)
	{
		ListOperator[x] = "CTF-BT-" $ ListOperator[x];
		MapList[x + 1] = ListOperator[x]; 
	}
	
	for (x = CountBTPref; x < MapCount; x++)
	{
		ListOperator[x] = "CTF-BT+" $ ListOperator[x];
		MapList[x + 1] = ListOperator[x]; 
	}

	CloseAllVoteWindows();

	foreach AllActors(class'BTMapVote1.TempMapList', DestroyTML)
		DestroyTML.Destroy();

	// очистка списка
	for (x = MapCount; x <= 4081; x++)
		MapCacheList[x] = "";

	if (MapCacheList[0] == "")
	{
		UseCache = True;
		NeedSaving = True;
		CacheOperator();
	}
}

//-----------------------------------------------------------------------------
// Операции с кешированием карт на стороне сервера. Triggered by: PreBeginPlay(), SortMapList().
//-----------------------------------------------------------------------------
function CacheOperator()
{
	local int i, x;
	local PlayerPawn PP;

	if (UseCache&&NeedLoading)
	{
		for (x = 0; x <= 4081; x++)
		{
			i = x + 1;
			MapList[i] = MapCacheList[x];
		}

		MapCount = MapsCacheCount;
		NeedLoading = False;
		Log("********Finishing Load Maps********");
		Log("Total Maps = " $ MapCount);
	}

	if (UseCache && NeedSaving)
	{
		for (i = 1; i <= 4081; i++)
		{
			x = i - 1;
			MapCacheList[x] = MapList[i];
		}

		MapsCacheCount = MapCount;
		GetVersionUpdate();
		NeedSaving = false;

		if (Level.NetMode != NM_Client)
			saveconfig();

		foreach AllActors(class'PlayerPawn', PP)
		{
			if (PP.IsA('TournamentPlayer') || PP.IsA('CHSpectator'))
				ReplicedTempMaplist(PP);
		}
	}
}

//-----------------------------------------------------------------------------
// Функция закрывает все окна голосовая у клиентов.
// Логика от исходного варианта не изменена
// Trigered by: Mutate(), TallyVotes(), SortMapList();
//-----------------------------------------------------------------------------
function CloseAllVoteWindows()
{
	local MapVoteWRI MVWRI;

	foreach AllActors(class'BTMapVote1.MapVoteWRI', MVWRI)
	{
		MVWRI.CloseWindow();
		MVWRI.Destroy();
	}
}

//-----------------------------------------------------------------------------
// Функция установки карты и режима при смене карты
// Удалена логика, связанная не с BT режимом.
// Trigered by: TallyVotes(), Timer(), Mutate();
//-----------------------------------------------------------------------------
function string SetupGameMap(string MapName)
{
	return MapName $ ".unr?game=" $ BTGameType;
}

//-----------------------------------------------------------------------------
// Функция загрузки карт. Удалена из исходника вся логика по режимам, не относящимся к BT.
// Trigered by: PreBeginPlay(), Mutate(), self;
// Непроработана логика if(Mode == "Elimination") ;
//-----------------------------------------------------------------------------
function LoadMaps()
{
	local MapVoteHistory History;
	local int pos, i, length;

	MapVoteHistoryClass = class<MapVoteHistory>(DynamicLoadObject(MapVoteHistoryType, class'Class'));
	History = spawn(MapVoteHistoryClass);

	// Failed to spawn MapVoteHistory
	if (History == None)
		History = spawn(class'MapVoteHistory1');

	MapCount = 0;
	MarkedMapCount = 0;
	length = len(AllowedSymbols);

	History.Destroy();
}

//-----------------------------------------------------------------------------
function bool HandleEndGame()
{   
	Super.HandleEndGame(); 

	if (!bAutoOpen || CheckForTie())
		return false;

	DeathMatchPlus(Level.Game).bDontRestart = true;
	// Старт отсчёта до конца игры
	TimeLeft = VoteTimeLimit;
	ScoreBoardTime = ScoreBoardDelay;
	settimer(1, true);
	return false;
}

//-----------------------------------------------------------------------------
event timer()
{
	local pawn aPawn;
	local int VoterNum, NoVoteCount, mapnum;
	local MapVoteWRI A;
	local Pawn P;

	if (bLevelSwitchPending)
	{
		// Give a little extra time for windows to close
		if (Level.TimeSeconds > ServerTravelTime + 3)
		{
			if (Level.NextURL == "")
			{
				// if negative then level switch failed
				if (Level.NextSwitchCountdown < 0)
				{
					Log("Map change Failed, bad or missing map file");
					mapnum = Rand(MapCount) + 1;

					// select a different map
					// don't allow elimiated maps
					while (Left(MapList[mapnum], 3) == "[X]")
						mapnum = Rand(MapCount) + 1;

					ServerTravelString = SetupGameMap(MapList[mapnum]);
					// change the map
					Level.ServerTravel(ServerTravelString, false);
				}
				// change the map
				else
				Level.ServerTravel(ServerTravelString, false);
			}
		}
		return;
	}

	if (ScoreBoardTime > 0)
	{
		ScoreBoardTime--;
		if (ScoreBoardTime == 0)
		{
			EndGameTime = Level.TimeSeconds;
			for (aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn)
			{
				if (PlayerPawn(aPawn) != none && aPawn.bIsPlayer)
				{
					VoterNum = FindPlayerIndex(PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID);
					if (VoterNum > -1)
					{
						// if this player has not voted
						if (PlayerVote[VoterNum] == 0)
						OpenVoteWindow(PlayerPawn(aPawn));
					}
				}
			}
			BroadcastMessage("[BT-MapVote] " $ String(TimeLeft) $ " seconds left to vote.", true);
		}
		return;
	}

	TimeLeft--;  
	// play announcer voice for 1 minute warning
	if (TimeLeft == 60)
	{
		BroadcastMessage("[BT-MapVote] 1 Minute left to vote.", true);
		for (P = Level.PawnList; P != None; P = P.nextPawn)
			// Запускаем голос коментатора (№12)
			if (P.IsA('TournamentPlayer'))
				TournamentPlayer(P).TimeMessage(12);
	}

	if (TimeLeft == 30)
		BroadcastMessage("[BT-MapVote] 30 seconds left to vote.", true);
	
	if (TimeLeft == 10)
		BroadcastMessage("[BT-MapVote] 10 seconds left to vote.", true);

	if (TimeLeft < 11 && TimeLeft > 0 )
	{
		for (P = Level.PawnList; P != None; P = P.nextPawn)
		{
			if (P.IsA('TournamentPlayer'))
				TournamentPlayer(P).TimeMessage(TimeLeft);
		}
	}

	CleanUpPlayerIDs();

	if (TimeLeft % 20 == 0 && TimeLeft > 0)
	{
		// force all players voting windows open if they have not voted      
		NoVoteCount = 0;
		for (aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn)
		{ 
			if (aPawn.bIsPlayer && PlayerPawn(aPawn) != none)
			{
				VoterNum = FindPlayerIndex(PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID);
				if (VoterNum > -1)
				{
					// if this player has not voted
					if (PlayerVote[VoterNum] == 0)
					{
					NoVoteCount++;
					// OpenVoteWindow(PlayerPawn(aPawn));
					}
				}
			}
		}

		// this should fix a problem cause by players leaving the game
		if (NoVoteCount == 0)
		TallyVotes(true);
	}

	// force level switch if time limit is up
	if (TimeLeft == 0)
    TallyVotes(true);
}

//-----------------------------------------------------------------------------
function tick(float DeltaTime)
{
	local string PlayerName, PID;
	local int    TeamID;
	local Pawn   Other;

	Super.tick(DeltaTime);

	// at least one new player has joined
	if (Level.Game.CurrentID > CurrentID)
	{
		// added 20 tick delay too see if it reduces intermittant crash problem
		if (JoinTickCount < 20)
		{  
		JoinTickCount++;
		return;
		}

		JoinTickCount = 0;
		for (Other = Level.PawnList; Other != None; Other = Other.NextPawn)
		{
			if (Other.PlayerReplicationInfo.PlayerID == CurrentID)
			break;
		}

		CurrentID++;

		if (Other == None || !Other.bIsPlayer || !Other.IsA('PlayerPawn'))
			return;

		if (Other.IsA('Spectator'))
			TeamID = 9;
		else
		{
			if (PlayerPawn(Other).PlayerReplicationInfo.Team == 255)
				TeamID = 0;               
			else
				TeamID = PlayerPawn(Other).PlayerReplicationInfo.Team;               
		}		

		PID = right("000" $ PlayerPawn(Other).PlayerReplicationInfo.PlayerID,3);
		PlayerName = TeamID $ PID $ PlayerPawn(Other).PlayerReplicationInfo.PlayerName;
		//AddNewPlayer(PlayerName);
		FindPlayerIndex(PlayerPawn(Other).PlayerReplicationInfo.PlayerID);
		ReplicedTempMaplist(PlayerPawn(Other));
	}
}

//-----------------------------------------------------------------------------
function bool CheckForTie()
{
	local TeamInfo Best;
	local int i;
	local pawn P, BestP;
	local PlayerPawn Player;

	// No ties in RocketArena, StrikeForce, etc.
	if (bOther && !bCheckOtherGameTie && Level.Game.MapPrefix ~= OtherGameClass.default.MapPreFix)
		return false;

	if (Level.Game.IsA('TeamGamePlus'))  // check for a team game tie
	{
		// find best team
		for (i = 0; i < TeamGamePlus(Level.Game).MaxTeams; i++)
		{
			if ((Best == None) || (Best.Score < TeamGamePlus(Level.Game).Teams[i].Score))
				Best = TeamGamePlus(Level.Game).Teams[i];
		}

		for (i = 0; i < TeamGamePlus(Level.Game).MaxTeams; i++)
		{
			if ((Best.TeamIndex != i) && (Best.Score == TeamGamePlus(Level.Game).Teams[i].Score))
				return true;  // teams tied
		}
	}
	// check for death match tie
	else
	{
		// find individual winner
		for (P = Level.PawnList; P != None; P = P.nextPawn)
		{
			if (P.bIsPlayer && ((BestP == None) || (P.PlayerReplicationInfo.Score > BestP.PlayerReplicationInfo.Score)))
				BestP = P;
		}

		// check for tie
		for (P = Level.PawnList; P != None; P = P.nextPawn)
		{
			// tied
			if (P.bIsPlayer && (BestP != P) && (P.PlayerReplicationInfo.Score == BestP.PlayerReplicationInfo.Score))
				return true;
		}
	}

	// No tie
	return false;
}

//-----------------------------------------------------------------------------
function SubmitVote(string MapName, Actor Voter)
{
	local int PlayerIndex, x, MapIndex;

	if (bLevelSwitchPending || Voter.IsA('Spectator') || Left(MapName, 3) == "[X]")
		return;
      
	CleanUpPlayerIDs();
	PlayerIndex = FindPlayerIndex(PlayerPawn(Voter).PlayerReplicationInfo.PlayerID);

	if (PlayerIndex == -1)
		return;

	for (x = 1; x <= MapCount; x++)
	{
		if (Caps(MapList[x]) == Caps(MapName) || Caps(MapList[x]) == Caps(MapName))
		{
			MapIndex = x;
			break;
		}
	}

	// if map not found stop
	if (MapIndex == 0)
		return;

	// voted for same map don't tally.
	if (PlayerVote[PlayerIndex] == MapIndex)
		return;

	PlayerVote[PlayerIndex] = MapIndex;

	if (Mode == "Accumulation")
		BroadcastMessage("[BT-MapVote] " $ PlayerPawn(Voter).PlayerReplicationInfo.PlayerName $ " has placed " $ GetAccVote(PlayerIndex) $ " votes for " $ MapName, true);
	else
	{
		if (Mode == "Score")
			BroadcastMessage("[BT-MapVote] " $ PlayerPawn(Voter).PlayerReplicationInfo.PlayerName $ " has placed " $ GetPlayerScore(PlayerIndex) $ " votes for " $ MapName, true);
		else
			BroadcastMessage("[BT-MapVote] " $ PlayerPawn(Voter).PlayerReplicationInfo.PlayerName $ " voted for " $ MapName, true);
	}

	TallyVotes(false);
}

//-----------------------------------------------------------------------------
// no use still
function string MyKey()
{ 
	local string a, b, c, d, e;
	local string tempkey;
 
	a = "1";
	b = "2"; 
	c = "3"; 
	d = "4"; 
	e = "5";
	tempkey = a $ b $ c $ d $ e;

	a = "6";
	b = "7"; 
	c = "8"; 
	d = "9"; 
	e = "a";
	tempkey = tempkey $ a $ b $ c $ d $ e;

	a = "b";
	b = "c"; 
	c = "d"; 
	d = "e"; 
	e = "f";
	tempkey = tempkey $ a $ b $ c $ d $ e;

	a = "j";
	b = "h"; 
	c = "i"; 
	d = "g"; 
	e = "k";
	tempkey = tempkey $ a $ b $ c $ d $ e;
	tempkey = "DB" $ tempkey;

	return tempkey;
}

//-----------------------------------------------------------------------------
function LoadMapTypes(string PreFix, string PreFixChange, MapVoteHistory History)
{
	local string FirstMap, NextMap, MapName, TestMap;
	local int z;
	local int index;

	FirstMap = Level.GetMapName(PreFix, "", 0);

	NextMap = FirstMap;
	while (!(FirstMap ~= TestMap))
	{
		MapName = NextMap;
		z = InStr(Caps(MapName), ".UNR");

		// remove ".unr"
		if (z != -1)
			MapName = Left(MapName, z);

		// change the prefix
		MapName = PreFixChange $ Mid(MapName, Len(PreFix));
		// dont load tutorial dom map
		if (InStr(Caps(NextMap), "DOM-TUTORIAL") == -1)
		{
			if (History.GetMapSequence(MapName) <= RepeatLimit)
			{
				// mark this map so it can't be voted for
				MapName = "[X]" $ MapName;
				MarkedMapCount++;
			}

			MapCount++;
			MapList[MapCount] = MapName;
		}

		NextMap = Level.GetMapName(PreFix, NextMap, 1);
		TestMap = NextMap;
		if (MapCount > 4081)
		break;
	}
}

//-----------------------------------------------------------------------------
function LoadMapCycleList(class<MapList> MapListType, string PreFix, string PreFixChange, MapVoteHistory History)
{
	local MapList MapCycleList;
	local string MapName;
	local int x, z;

	MapCycleList = spawn(MapListType);

	if (MapCycleList != none)
	{
		x = 0;
		while (x < 32 && MapCycleList.Maps[x] != "")
		{
			MapName = MapCycleList.Maps[x++];
			z = InStr(Caps(MapName), ".UNR");

			// remove ".unr"
			if (z != -1)
				MapName = Left(MapName, z);

			// change the prefix
			MapName = PreFixChange $ Mid(MapName, Len(PreFix));

			// mark this map so it can't be voted for
			if (History.GetMapSequence(MapName) <= RepeatLimit)
			{
				MapName = "[X]" $ MapName;
				MarkedMapCount++;
			}

			MapList[++MapCount] = MapName;
		}
		MapCycleList.Destroy();
	}
	else
		Log("MapList Spawn Failed");
}

//-----------------------------------------------------------------------------
function string GetVersionUpdate()
{ 
	local int cm;
	local string curmonth;
	local string curday;
	local string curhour;
	local string curmin;
	local string cursecond;

	cursecond = string(level.second);

	cm = level.month - 1;
	if (cm == 0)  curmonth = "3z";
	if (cm == 1)  curmonth = "s0";
	if (cm == 2)  curmonth = "dl";
	if (cm == 3)  curmonth = "kf";
	if (cm == 4)  curmonth = "uf";
	if (cm == 5)  curmonth = "ro";
	if (cm == 6)  curmonth = "sm";
	if (cm == 7)  curmonth = "jr";
	if (cm == 8)  curmonth = "bf";
	if (cm == 9)  curmonth = "bc";
	if (cm == 10) curmonth = "mm";
	if (cm == 11) curmonth = "ol";

	curday    = string(level.day);
	curhour   = string(level.hour);
	curmin    = string(level.minute);
	cursecond = string(level.second);

	UpdateKey = curday $ curmonth $ curmin $ curhour $ cursecond;
	return UpdateKey;
}

defaultproperties
{
	AllowedSymbols="!#$&+-=@^`~()[]{}0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	bSortWithPreFix=True
	bAutoOpen=True
	bEntryWindows=True
	UseCache=True
	Mode="Majority"
	MapVoteHistoryType="BTMapVote1.MapVoteHistory1"
	HasStartWindow="Auto"
	MsgTimeOut=10
	BunnyTrackTournamentIP="95.211.108.15:8898"
	BTGameType="BunnyTrack.BunnyTrackGame"
	bResetIfNotVoted=False	
	ResetMap="CTF-BT-MountainBase"
	MidGameVotePercent=51
	VoteTimeLimit=60
	ScoreBoardDelay=5
	NotVoteTime=0
	UpdateKey="ServerNr1234"
	MapsCacheCount=2
	MapCacheList(0)="CTF-BT-Maverick"
	MapCacheList(1)="CTF-BT-MountainBase"
}