//=============================================================================
// BT_EnhancementsMutator made by OwYeaW
//=============================================================================
class BT_EnhancementsMutator expands Mutator config(BTE);

var config bool bLoadWithoutBTPP, bAlwaysShowLogo, NetSpeedLimiter, KickPlayer, Broadcast, AutoCorrectNetSpeed;
var config int HUDBunnyType, CorrectNetSpeed, MinimumNetSpeed, MaximumNetSpeed;

var int Counter;
var int	CurrentID;

struct PlayerInfo
{
	var PlayerPawn PP;
	var BT_PRI BTPRI;
	var BTEClientData BTEC;
};
var PlayerInfo PI[32];

struct SpecInfo
{
	var	PlayerPawn PP;
	var BTEClientData BTEC;
};
var PlayerInfo SI[32];

replication
{
	reliable if(Role == ROLE_Authority)
		bAlwaysShowLogo, HUDBunnyType;
}
function PreBeginPlay()
{
	if(Role == ROLE_Authority)
		Enable('Tick');

	Super.PreBeginPlay();
}
//=============================================================================
// BTE Initialization
//=============================================================================
function Tick(float DeltaTime)
{
	local BTPPHUDNotify N;

	if(bLoadWithoutBTPP)
	{
		Level.Game.HUDType = class'BT_HUD';	//	Setting the BT_HUD anyways because it contains useful features
//////////////////////////////////////////////	You can make HUDs containing the features for each specific GameMode if you like (CTF_HUD, DM_HUD, etc.)
//		Level.Game.ScoreBoardType = XXXX;		Not using the BT_ScoreBoard without BTPP
		Level.Game.BaseMutator.AddMutator(self);
		Level.Game.RegisterMessageMutator(Self);
		if(int(ConsoleCommand("GET IPDRV.TCPNETDRIVER RELEVANTTIMEOUT")) < 1200)
			ConsoleCommand("SET IPDRV.TCPNETDRIVER RELEVANTTIMEOUT 1200");

		log("+------------------------------+");
		log("| * BunnyTrack  Enhancements * |");
		log("|                              |");
		log("|             Made             |");
		log("|              By              |");
		log("|            OwYeaW            |");
		log("|                              |");
		log("+------------------------------+");
		log("|         Without BT++         |");
		log("+------------------------------+");
		log("| *     BTE Initialized      * |");
		log("+------------------------------+");
		GotoState('Enabled');
	}
	else
	{
		Counter++;
		if(Counter < 10)
		{
			foreach AllActors(class'BTPPHUDNotify', N)
			{
				if(N.Destroy())
				{
					Level.Game.HUDType = class'BT_HUD';
					Level.Game.ScoreBoardType = class'BT_ScoreBoard';
					Level.Game.BaseMutator.AddMutator(self);
					Level.Game.RegisterMessageMutator(Self);
					if(int(ConsoleCommand("GET IPDRV.TCPNETDRIVER RELEVANTTIMEOUT")) < 1200)
						ConsoleCommand("SET IPDRV.TCPNETDRIVER RELEVANTTIMEOUT 1200");

					log("+------------------------------+");
					log("| * BunnyTrack  Enhancements * |");
					log("|                              |");
					log("|             Made             |");
					log("|              By              |");
					log("|            OwYeaW            |");
					log("|                              |");
					log("+------------------------------+");
					log("| *     BTE Initialized      * |");
					log("+------------------------------+");
					GotoState('Enabled');
				}
			}
		}
		else
		{
			log("+------------------------------+");
			log("| * BunnyTrack  Enhancements * |");
			log("|                              |");
			log("|             Made             |");
			log("|              By              |");
			log("|            OwYeaW            |");
			log("|                              |");
			log("+------------------------------+");
			log("| > Incorrect or Missing BT++  |");
			log("|   - BTPPHUDNotify not found  |");
			log("+------------------------------+");
			log("| *  Initialization Failed   * |");
			log("| *       BTE Removed        * |");
			log("+------------------------------+");
			Destroy();
		}
	}
}
//=============================================================================
// BTE Initialized -> Check for new players
//=============================================================================
state Enabled
{
	function tick(float DeltaTime)
	{
		CheckForNewPlayer();
		Super.tick(DeltaTime);
	}

	function BeginState()
	{
		Spawn(class'BT_CollisionData');
		SaveConfig();
	}
}
function CheckForNewPlayer()
{
	local Pawn P;

	if(Level.Game.CurrentID > CurrentID)
	{
		for(P = Level.PawnList; P != None; P = P.NextPawn)
			if(P.PlayerReplicationInfo.PlayerID == CurrentID)
				break;
		CurrentID++;

		if(PlayerPawn(P) != None && P.bIsPlayer)
		{
			if(P.PlayerReplicationInfo.bIsSpectator && !P.PlayerReplicationInfo.bWaitingPlayer)
				InitNewSpec(PlayerPawn(P));
			else
				InitNewPlayer(PlayerPawn(P));
		}
	}
}
//=============================================================================
// Initialize Spectator
//=============================================================================
function InitNewSpec(PlayerPawn PP)
{
	local int i;

	i = FindFreeSISlot();

	SI[i].PP				= PP;
	SI[i].BTEC				= Spawn(class'BTEClientData', PP);
	BT_Spectator(PP).BTEC	= SI[i].BTEC;
	Spawn(class'ClientData', PP);
}
function int FindFreeSISlot()
{
	local int i;

	for(i = 0; i < 32; i++)
	{
		if(SI[i].PP == None)
			return i;
		else if(SI[i].PP.Player == None)
			return i;
	}
}
//=============================================================================
// Initialize Player
//=============================================================================
function InitNewPlayer(PlayerPawn PP)
{
	local int i;

	i = FindFreePISlot();

	PI[i].PP						= PP;
	PI[i].BTEC						= Spawn(class'BTEClientData', PP);
	PI[i].BTPRI						= Spawn(class'BT_PRI', PP);
	PI[i].BTPRI.PlayerID			= PP.PlayerReplicationInfo.PlayerID;

	PI[i].BTPRI.NetSpeedLimiter 	= NetSpeedLimiter;
	PI[i].BTPRI.KickPlayer			= KickPlayer;
	PI[i].BTPRI.Broadcast			= Broadcast;
	PI[i].BTPRI.AutoCorrectNetSpeed = AutoCorrectNetSpeed;
	PI[i].BTPRI.CorrectNetSpeed		= CorrectNetSpeed;
	PI[i].BTPRI.MinimumNetSpeed		= MinimumNetSpeed;
	PI[i].BTPRI.MaximumNetSpeed		= MaximumNetSpeed;
}
function int FindFreePISlot()
{
	local int i;

	for(i = 0; i < 32; i++)
	{
		if(PI[i].PP == None)
			return i;
		else if(PI[i].PP.Player == None)
			return i;
	}
}
//=============================================================================
// Mutate Console Commands
//=============================================================================
function Mutate(string MutateString, PlayerPawn Sender)
{
	Super.Mutate(MutateString, Sender);

	switch(MutateString)
	{
		case "BTE":
			OpenSettingsWindow(Sender);
		break;

		case "RESETVIEW":
			Sender.ViewTarget = None;
			Sender.bBehindview = false;
		break;

		case "BEHINDVIEWTOGGLE":
			Sender.bBehindView = !Sender.bBehindView;
		break;
	}
}
//====================================
// Say Commands
//====================================
function bool MutatorTeamMessage(Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
	if(Sender == Receiver && PlayerPawn(Sender) != None)
		if(S ~= "!BTE" || S ~= "!BT")
			OpenSettingsWindow(PlayerPawn(Sender));

	if(NextMessageMutator != None)
		return NextMessageMutator.MutatorTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
	else
		return true;
}
//====================================
// OpenSettingsWindow
//====================================
function OpenSettingsWindow(PlayerPawn Sender)
{
	local BT_WRI BTWRI;
	local BT_WRI A;

	foreach AllActors(class'BT_WRI', A)
		if(Sender == A.Owner)
			return;

	BTWRI = Spawn(class'BT_WRI', Sender, , Sender.Location);

	if( Sender.IsA('TournamentPlayer') )
		BTWRI.BTEC = PI[FindPlayer(Sender)].BTEC;
	else if( Sender.IsA('BT_Spectator') )
		BTWRI.BTEC = SI[FindSpec(Sender)].BTEC;

	if(BTWRI == None)
	{
		Log("#### -- PostLogin :: Fail:: Could not spawn WRI");
		return;
	}
}
//====================================
// ModifyLogin - Replace the normal spectator class with BT_Specator class
//====================================
function ModifyLogin(out class<playerpawn> SpawnClass, out string Portal, out string Options)
{
	if(SpawnClass == class'CHSpectator')
		SpawnClass = class'BT_Spectator';

	if(NextMutator != None)
		NextMutator.ModifyLogin(SpawnClass, Portal, Options);
}
//====================================
// FindPlayer - Find a PlayerPawn in the PlayerInfo struct
//====================================
function int FindPlayer(PlayerPawn PP)
{
	local int i;

	for(i = 0; i < 32; i++)
		if(PI[i].PP == PP)
			return i;

	return -1;
}
//====================================
// FindSpec - Find a PlayerPawn in the SpecInfo struct
//====================================
function int FindSpec(PlayerPawn PP)
{
	local int i;

	for(i = 0; i < 32; i++)
		if(SI[i].PP == PP)
			return i;

	return -1;
}
//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
	bLoadWithoutBTPP=false
	bAlwaysShowLogo=true
	HUDBunnyType=0
    NetSpeedLimiter=true
    Broadcast=false
	KickPlayer=false
    AutoCorrectNetspeed=true
    CorrectNetspeed=20000
    MinimumNetSpeed=10000
    MaximumNetSpeed=25000
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=9.000000
}