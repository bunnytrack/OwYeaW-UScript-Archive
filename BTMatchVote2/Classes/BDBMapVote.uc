//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MatchVote made by OwYeaW						BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class BDBMapVote expands Mutator config(BTMatchVote);

var		config string			BunnyTrackTournamentIP;		// BunnyTrack Tournament Server IP
var 	config string 			UpdateKey;					// Ключ апдейта карт, позволяет синхронизировать кеши клиента и сервера;
var 	config bool 			bAutoOpen;					// Автооткрытие в конце игры окна голосования
var 	config bool 			bResetIfNotVoted;

var 	config int 				MapsCacheCount;				// количество карт в кеше
var 	config int 				VoteTimeLimit;
var 	config int 				ScoreBoardDelay;
var 	config int 				MidGameVotePercent;			// процент проголосовавших, при котором срабатывает автоматический запуск мапвоты
var 	config int 				NotVoteTime;				// время после старта сервера, при котором нельзя ещё голосовать;

var		config string			LinkButton1;
var		config string			LinkButton1Name;
var		config string			LinkButton2;
var		config string			LinkButton2Name;
var		config string			LinkButton3;
var		config string			LinkButton3Name;
var		config string			LinkButton4;
var		config string			LinkButton4Name;
var		config string			LinkButton5;
var		config string			LinkButton5Name;
var		config string 			ResetMap;
var		config int 				ResetMapMaxPlayers;

var		bool					bInitialized;
var		bool					bMidGameVote;
var 	bool					NeedSaving;
var 	bool					NeedLoading;

var 	int						CurrentID;
var 	int						JoinTickCount;
var 	int						MapCount;
var 	int						PlayerIDList[32];			// список ид игроков
var 	int						PlayerVote[32];				// индекс проголосованных карт
var 	string					MapList[4096];
var 	string					MapStatusText[100];

var 	config string 			AccName[32];				// use for Accumulation mode
var 	config int				AccVotes[32];				// use for Accumulation mode
var 	config string 			MapCacheList[4096];		// список карт в кеше

var 	int 					TimeLeft;
var 	int 					ScoreBoardTime;
var 	int 					ServerTravelTime;
var 	TempMapList 			TML;
var 	bool 					bLevelSwitchPending;
var 	string 					ServerTravelString;
var 	int 					MarkedMapCount;				// total number of maps that have not been elimitated.
var 	int 					CurrentPlayerCount;
var		float					ResetTime;
var		bool					bSwitchResetMap;
var		bool					bGameEndStuff;

//-----------------------------------------------------------------------------
function PreBeginPlay()
{
	local int x, z;

	if (!bInitialized)
	{
		for (x = 0; x < 32; x++)
			PlayerIDList[x] = -1;

		NeedLoading = True;
		CacheOperator();
		bInitialized = true;
	}
	Super.PreBeginPlay();
}

//-----------------------------------------------------------------------------
function Mutate(string MutateString, PlayerPawn Sender)
{
	local string MapName;

	Super.Mutate(MutateString, Sender);

	// MUTATE BDBMAPVOTE VOTEMENU
	if (left(Caps(MutateString), 10) == "BDBMAPVOTE")
	{
		if (Mid(Caps(MutateString), 11, 8) == "VOTEMENU")
		{
			// make sure they cant vote before other players have joined server
			if (Level.TimeSeconds > NotVoteTime || Level.Netmode == NM_Standalone)
			{
				CleanUpPlayerIDs();
				OpenVoteWindow(Sender);
				if (Sender.bAdmin)
					Sender.ClientMessage("[BT-MatchVote] You are admin and can force a map switch");
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

				BroadcastMessage("[BT-MatchVote] The Server Admin has forced a map switch to " $ MapName, true);
				ServerTravelString = SetupGameMap(MapName);
				CloseAllVoteWindows();
				Level.ServerTravel(ServerTravelString, false);
			}
			else
				SubmitVote(MapName,Sender);
		}
	}
}

//-----------------------------------------------------------------------------
function OpenVoteWindow(PlayerPawn Sender)
{
	local MapVoteWRI MVWRI;
	local int x, playercount, y;
	local pawn p;
	local MapVoteWRI A;
	local int TeamID;
	local string PID;
	local bool LetsGo;

	if (bLevelSwitchPending)
		return;

	foreach AllActors(class'BTMatchVote2.MapVoteWRI', A) // check all existing WRIs
	{
		if (Sender == A.Owner)
			return;
	}

	foreach AllActors(class'BTMatchVote2.TempMapList', TML)
	{
		if (TML.Owner==Sender && TML.TransferDone)
			LetsGo = True;
	}

	if (LetsGo)
	{
		MVWRI = Spawn(class'BTMatchVote2.MapVoteWRI', Sender, , Sender.Location);

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
				// example: 1004BDB	=	Team 1, PlayerID 4, PlayerName BDB
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
		Sender.ClientMessage("[BT-MatchVote] Downloading Maplist...");
}

//-----------------------------------------------------------------------------
function ReplicedTempMaplist(PlayerPawn Sender)
{
	local TempMapList A;
	local int i;

	if (bLevelSwitchPending)
		return;

	foreach AllActors(class'BTMatchVote2.TempMapList', A)
	{
		if (Sender == A.Owner) 
			return;
	}

	TML = Spawn(class'BTMatchVote2.TempMapList', Sender, , Sender.Location);
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
		if (i < 256)				TML.TempList1[i]			= MapList[i];
		if (i >= 256 && i < 511)	TML.TempList2[i - 255]		= MapList[i];
		if (i >= 511 && i < 766)	TML.TempList3[i - 510]		= MapList[i];
		if (i >= 766 && i < 1021)	TML.TempList4[i - 765]		= MapList[i];
		if (i >= 1021 && i < 1276)	TML.TempList5[i - 1020]		= MapList[i];
		if (i >= 1276 && i < 1531)	TML.TempList6[i - 1275]		= MapList[i];
		if (i >= 1531 && i < 1786)	TML.TempList7[i - 1530]		= MapList[i];
		if (i >= 1786 && i < 2041)	TML.TempList8[i - 1785]		= MapList[i];
		if (i >= 2041 && i < 2296)	TML.TempList9[i - 2040]		= MapList[i];
		if (i >= 2296 && i < 2551)	TML.TempList10[i - 2295]	= MapList[i];
		if (i >= 2551 && i < 2806)	TML.TempList11[i - 2550]	= MapList[i];
		if (i >= 2806 && i < 3061)	TML.TempList12[i - 2805]	= MapList[i];
		if (i >= 3061 && i < 3316)	TML.TempList13[i - 3060]	= MapList[i];
		if (i >= 3316 && i < 3571)	TML.TempList14[i - 3315]	= MapList[i];
		if (i >= 3571 && i < 3826)	TML.TempList15[i - 3570]	= MapList[i];
		if (i >= 3826)				TML.TempList16[i - 3825]	= MapList[i];
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

	// check all existing WRIs
	foreach AllActors(class'BTMatchVote2.MapVoteWRI', MVWRI)
		MVWRI.AddNewPlayer(NewPlayerName);
}

//-----------------------------------------------------------------------------
// removes a players name from all open Voting windows
function RemovePlayerName(string OldPlayerName)
{
	local MapVoteWRI MVWRI;

	// check all existing WRIs
	foreach AllActors(class'BTMatchVote2.MapVoteWRI', MVWRI)
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
// Подсчёт голосов
//-----------------------------------------------------------------------------
function TallyVotes(bool bForceMapSwitch)
{
	local int				index, x, y, topmap;
	local int				VoteCount[4081];
	local int				Ranking[32];
	local int				PlayersThatVoted;
	local int				TieCount;
	local string			CurrentMap;

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

			// increment the votecount for this map
			VoteCount[PlayerVote[x]]++;
			if (float(VoteCount[PlayerVote[x]]) / float(Level.Game.NumPlayers) > 0.5 && Level.Game.bGameEnded)
				bForceMapSwitch = true;
		}
	}

	// Mid game vote initiated
	if (!Level.Game.bGameEnded && !bMidGameVote && (float(PlayersThatVoted) / float(Level.Game.NumPlayers)) * 100 >= MidGameVotePercent && PlayersThatVoted != Level.Game.NumPlayers)
	{
		BroadCastMessage("[BT-MatchVote] Mid-Game Map Voting has been initiated");
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
				BroadCastMessage("[BT-MatchVote] Switching to "$ ResetMap);
				ResetSettings();
				bSwitchResetMap = true;
				ResetTime = Level.TimeSeconds + 3;
			}
			else
				topmap = Rand(MapCount) + 1;
		}
	}

	// if everyone has voted go ahead and change map
	if ( (bForceMapSwitch || Level.Game.NumPlayers == PlayersThatVoted) && !bSwitchResetMap )
	{
		if (MapList[topmap] == "")
			return;

		BroadcastMessage("[BT-MatchVote] " $ MapList[topmap] $ " has won", true);
		CloseAllVoteWindows();
		bLevelSwitchPending = true;
		ServerTravelString = SetupGameMap(MapList[topmap]);
		ServerTravelTime = Level.TimeSeconds;

		// enable timer for mid game voting
		if (!Level.Game.bGameEnded)
			settimer(1, true);
	}
}

function ResetSettings()
{
	DeathMatchPlus(Level.Game).bTournament = false;
	DeathMatchPlus(Level.Game).MaxPlayers = ResetMapMaxPlayers;
	CTFGame(Level.Game).GoalTeamScore = 0;
	CTFGame(Level.Game).TimeLimit = 0;
}

//-----------------------------------------------------------------------------
// Апдейт открытых окон у клиентов
//-----------------------------------------------------------------------------
function UpdateOpenWRI()
{
	local MapVoteWRI MVWRI;
	local int x, y;

	foreach AllActors(class'BTMatchVote2.MapVoteWRI', MVWRI)
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
// Операции с кешированием карт на стороне сервера. Triggered by: PreBeginPlay(), SortMapList().
//-----------------------------------------------------------------------------
function CacheOperator()
{
	local int i, x;
	local PlayerPawn PP;

	if (NeedLoading)
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

	if (NeedSaving)
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
			if (PP.IsA('TournamentPlayer') || PP.IsA('CHSpectator'))
				ReplicedTempMaplist(PP);
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

	foreach AllActors(class'BTMatchVote2.MapVoteWRI', MVWRI)
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
	return MapName $ ".unr";
}

//-----------------------------------------------------------------------------
event Timer()
{
	local pawn aPawn;
	local int VoterNum, NoVoteCount, mapnum;

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
			for (aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn)
			{
				if (PlayerPawn(aPawn) != none && aPawn.bIsPlayer && (!PlayerPawn(aPawn).PlayerReplicationInfo.bIsSpectator || PlayerPawn(aPawn).PlayerReplicationInfo.bWaitingPlayer))
				{
					VoterNum = FindPlayerIndex(PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID);
					if (VoterNum > -1)
					{
						// if this player has not voted
						if (PlayerVote[VoterNum] == 0)
							if (bAutoOpen)
								OpenVoteWindow(PlayerPawn(aPawn));
					}
				}
			}
			BroadcastMessagePlayersOnly("[BT-MatchVote] " $ String(TimeLeft) $ " seconds left to vote", true);
		}
		return;
	}

	TimeLeft--;
	if (TimeLeft == 180)
		BroadcastMessagePlayersOnly("[BT-MatchVote] 3 Minutes left to vote", true);
	if (TimeLeft == 120)
		BroadcastMessagePlayersOnly("[BT-MatchVote] 2 Minutes left to vote", true);
	if (TimeLeft == 60)
		BroadcastMessagePlayersOnly("[BT-MatchVote] 1 Minute left to vote", true);
	if (TimeLeft == 30)
		BroadcastMessagePlayersOnly("[BT-MatchVote] 30 seconds left to vote", true);
	if (TimeLeft == 10)
		BroadcastMessagePlayersOnly("[BT-MatchVote] 10 seconds left to vote", true);
	if (TimeLeft == 5)
		BroadcastMessagePlayersOnly("[BT-MatchVote] 5 seconds left to vote", true);
	if (TimeLeft == 4)
		BroadcastMessagePlayersOnly("[BT-MatchVote] 4 seconds left to vote", true);
	if (TimeLeft == 3)
		BroadcastMessagePlayersOnly("[BT-MatchVote] 3 seconds left to vote", true);
	if (TimeLeft == 2)
		BroadcastMessagePlayersOnly("[BT-MatchVote] 2 seconds left to vote", true);
	if (TimeLeft == 1)
		BroadcastMessagePlayersOnly("[BT-MatchVote] 1 seconds left to vote", true);

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
						NoVoteCount++;
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
	local string	PlayerName, PID;
	local int		TeamID;
	local Pawn		Other;

	Super.tick(DeltaTime);

	if (bSwitchResetMap)
		if (ResetTime <= Level.TimeSeconds)
			Level.ServerTravel(ResetMap, false);

	if (Level.Game.bGameEnded && !bGameEndStuff)
	{
		bGameEndStuff = true;
		TimeLeft = VoteTimeLimit;
		ScoreBoardTime = ScoreBoardDelay;
		settimer(1, true);
	}

	if ( Level.Game.NumPlayers > CurrentPlayerCount )
	{
		CurrentPlayerCount = Level.Game.NumPlayers;
	}
	if ( Level.Game.NumPlayers < CurrentPlayerCount )
	{
		CurrentPlayerCount = Level.Game.NumPlayers;
		CleanUpPlayerIDs();
		if ( Level.Game.NumPlayers > 0 )
		{
			TallyVotes(False);
			UpdateOpenWRI();
		}
	}

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

	// No ties in RocketArena, StrikeForce, etc.
	if (Level.Game.bGameEnded)
		return false;

	if (Level.Game.IsA('TeamGamePlus'))	// check for a team game tie
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
				return true;	// teams tied
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
	else
	{
		for (x = 1; x <= MapCount; x++)
		{
			if (Caps(MapList[x]) == Caps(MapName) || Caps(MapList[x]) == Caps(MapName))
			{
				MapIndex = x;
				break;
			}
		}
	}

	// if map not found stop
	if (MapIndex == 0)
		return;

	// voted for same map don't tally.
	if (PlayerVote[PlayerIndex] == MapIndex)
		return;

	PlayerVote[PlayerIndex] = MapIndex;

	BroadcastMessage("[BT-MatchVote] " $ PlayerPawn(Voter).PlayerReplicationInfo.PlayerName $ " voted for " $ MapName, true);

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
	if (cm == 0)	curmonth = "3z";
	if (cm == 1)	curmonth = "s0";
	if (cm == 2)	curmonth = "dl";
	if (cm == 3)	curmonth = "kf";
	if (cm == 4)	curmonth = "uf";
	if (cm == 5)	curmonth = "ro";
	if (cm == 6)	curmonth = "sm";
	if (cm == 7)	curmonth = "jr";
	if (cm == 8)	curmonth = "bf";
	if (cm == 9)	curmonth = "bc";
	if (cm == 10)	curmonth = "mm";
	if (cm == 11)	curmonth = "ol";

	curday		= string(level.day);
	curhour		= string(level.hour);
	curmin		= string(level.minute);
	cursecond	= string(level.second);

	UpdateKey = curday $ curmonth $ curmin $ curhour $ cursecond;
	return UpdateKey;
}

event BroadcastMessagePlayersOnly( coerce string Msg, optional bool bBeep, optional name Type )
{
	local Pawn P;

	if (Type == '')
		Type = 'Event';

	if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
		for( P=Level.PawnList; P!=None; P=P.nextPawn )
			if((P.bIsPlayer || P.IsA('MessagingSpectator')) && !PlayerPawn(P).PlayerReplicationInfo.bIsSpectator)
			{
				if ( (Level.Game != None) && (Level.Game.MessageMutator != None) )
				{
					if ( Level.Game.MessageMutator.MutatorBroadcastMessage(Self, P, Msg, bBeep, Type) )
						P.ClientMessage( Msg, Type, bBeep );
				} else
					P.ClientMessage( Msg, Type, bBeep );
			}
}

defaultproperties
{
	UpdateKey="11kf22334"
	MapsCacheCount=313
	bAutoOpen=True
	VoteTimeLimit=80
	ScoreBoardDelay=20
	MidGameVotePercent=51
	NotVoteTime=0
	bResetIfNotVoted=True
	ResetMap=""
	BunnyTrackTournamentIP="95.211.108.15:8898"
	LinkButton1="http://www.btstats.ut99.tk"
	LinkButton1Name="BT Stats"
	LinkButton2="http://discord.gg/uS5ZNrc"
	LinkButton2Name="PUG Discord"
	LinkButton3="http://I4Games.eu"
	LinkButton3Name="I4Games"
	LinkButton4="http://BunnyTrack.net"
	LinkButton4Name="BunnyTrack.net"
	LinkButton5="http://www.btstats.ut99.tk/?p=help"
	LinkButton5Name="Help"
}