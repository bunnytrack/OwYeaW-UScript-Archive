class BTMapRotator expands Mutator config(BTPlusPlusTournament);

var config int CheckTimeMinutes;

var BTPPGameReplicationInfo GRI;
var int MapClock;
var bool Initialized;

function PostBeginPlay()
{
	if (!Initialized)
	{
		Initialized = !Initialized;
		SetTimer(60.0,True);	// 60 seconds
	}
	Super.PostBeginPlay();
}

function Timer()
{
	local PlayerPawn PP;

	foreach AllActors (Class'PlayerPawn',PP)
	{
		if ((PP != None) && (PP.bIsPlayer))
		{
			MapClock = 0;
			Break;
		}
	}
	MapClock++;

	if (MapClock > CheckTimeMinutes)
		MapEndCode();
}

function MapEndCode() // end the map in a way thats configured
{
	if (Left(string(Level), InStr(string(Level), ".")) == GRI.ResetMap
	&& !DeathMatchPlus(Level.Game).bTournament
	&& DeathMatchPlus(Level.Game).MaxPlayers == GRI.ResetMapMaxPlayers
	&& CTFGame(Level.Game).GoalTeamScore == 0
	&& CTFGame(Level.Game).TimeLimit == 0)
		SetTimer(0.0,False);
	else
	{
		DeathMatchPlus(Level.Game).bTournament = false;
		DeathMatchPlus(Level.Game).MaxPlayers = GRI.ResetMapMaxPlayers;
		CTFGame(Level.Game).GoalTeamScore = 0;
		CTFGame(Level.Game).TimeLimit = 0;
		Level.ServerTravel(GRI.ResetMap, false);
	}
}