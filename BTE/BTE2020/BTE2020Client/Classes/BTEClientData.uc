//=============================================================================
// BTEClientData made by OwYeaW
//=============================================================================
class BTEClientData expands Info config(BT_Enhancements);
//=============================================================================
#exec texture IMPORT NAME=BT_BS_0	FILE=Textures\BT_BS_0.PCX
#exec texture IMPORT NAME=BT_BS_1	FILE=Textures\BT_BS_1.PCX
#exec texture IMPORT NAME=BT_BS_2	FILE=Textures\BT_BS_2.PCX
#exec texture IMPORT NAME=BT_BS_3	FILE=Textures\BT_BS_3.PCX
#exec texture IMPORT NAME=BT_BS_4	FILE=Textures\BT_BS_4.PCX
//=============================================================================
// Config Variables
//=============================================================================
var config bool Ghosts;
var config bool BrightSkins;
var config bool ShowCollisions;
var config bool ShowSpeedMeter;
var config bool MuteAnnouncerAndHUDMessages;
var config bool BehindViewCrosshair;
var config float CrosshairScale;

var config bool GhostSpectator;
var config bool UseTeleporters;
var config bool ShowPlayerCollisions;
var config bool WallHack;
var config bool MuteTaunts;
var config bool FollowViewRotation;
var config int SpectatorSpeed;
var config int BehindViewDistance;

var config bool CustomTimer;
var config bool NeverOpened;
var config int LocationX;
var config int LocationY;
var config float TimerScale;
var config byte Red;
var config byte Green;
var config byte Blue;

var config int WinX;
var config int WinY;
//=============================================================================
// Server Variables
//=============================================================================
var bool ServerUseTeleporters;
var bool ServerFollowViewRotation;
var bool ServerMuteTaunts;
var bool ServerGhostSpectator;
var int ServerSpectatorSpeed;
var int ServerBehindViewDistance;
//=============================================================================
// Replication and Tick
//=============================================================================
replication
{
	reliable if (Role < ROLE_Authority)
		SetServerVars;

	reliable if(Role == ROLE_Authority)
		GetClientVars;
}

function Tick(float DeltaTime)
{
	if(Owner == None)
		Destroy();
}
//=============================================================================
// Initialize
//=============================================================================
event Spawned()
{
	GetClientVars();
}
simulated function GetClientVars()
{
	SetServerVars(GhostSpectator, SpectatorSpeed, BehindViewDistance, MuteTaunts, UseTeleporters, FollowViewRotation);
}
function SetServerVars(bool GS, int SS, int BD, bool MT, bool UT, bool FV)
{
	ServerGhostSpectator = GS;
	ServerSpectatorSpeed = SS;
	ServerBehindViewDistance = BD;
	ServerMuteTaunts = MT;
	ServerUseTeleporters = UT;
	ServerFollowViewRotation = FV;
	PlayerPawn(Owner).Grab();
}
//=============================================================================
// Settings Stuff
//=============================================================================
simulated function SwitchBool(string BoolName)
{
	switch(BoolName)
	{
		case "Ghosts": Ghosts = !Ghosts; break;
		case "BrightSkins": BrightSkins = !BrightSkins; break;
		case "ShowCollisions": ShowCollisions = !ShowCollisions; break;
		case "ShowSpeedMeter": ShowSpeedMeter = !ShowSpeedMeter; break;
		case "MuteAnnouncerAndHUDMessages": MuteAnnouncerAndHUDMessages = !MuteAnnouncerAndHUDMessages; break;
		case "BehindViewCrosshair": BehindViewCrosshair = !BehindViewCrosshair; break;
		case "GhostSpectator": GhostSpectator = !GhostSpectator; break;
		case "UseTeleporters": UseTeleporters = !UseTeleporters; break;
		case "ShowPlayerCollisions": ShowPlayerCollisions = !ShowPlayerCollisions; break;
		case "WallHack": WallHack = !WallHack; break;
		case "MuteTaunts": MuteTaunts = !MuteTaunts; break;
		case "FollowViewRotation": FollowViewRotation = !FollowViewRotation; break;
		case "CustomTimer": CustomTimer = !CustomTimer; break;
	}
	SetServerVars(GhostSpectator, SpectatorSpeed, BehindViewDistance, MuteTaunts, UseTeleporters, FollowViewRotation);
	SaveConfig();
}
simulated function FloatSetting(string Setting, float Number)
{
	switch(Setting)
	{
		case "CrosshairScale": CrosshairScale = Number; break;
		case "TimerScale": TimerScale = Number; break;
		case "Red": Red = Number; break;
		case "Green": Green = Number; break;
		case "Blue": Blue = Number; break;
		case "X": LocationX = Number; break;
		case "Y": LocationY = Number; break;
	}
	SaveConfig();
}
simulated function IntSetting(string Setting, int Number)
{
	switch(Setting)
	{
		case "SpectatorSpeed": SpectatorSpeed = Number; break;
		case "BehindViewDistance": BehindViewDistance = Number; break;
	}
	SetServerVars(GhostSpectator, SpectatorSpeed, BehindViewDistance, MuteTaunts, UseTeleporters, FollowViewRotation);
	SaveConfig();
}
simulated function WinSetting(string Setting, int Number)
{
	switch(Setting)
	{
		case "X": WinX = Number; break;
		case "Y": WinY = Number; break;
	}
	SaveConfig();
}
//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
	Ghosts=false
	BrightSkins=false
	ShowCollisions=false
	ShowSpeedMeter=false
	MuteAnnouncerAndHUDMessages=false
	BehindViewCrosshair=false
	CrosshairScale=1
	GhostSpectator=false
	ShowPlayerCollisions=false
	WallHack=false
	MuteTaunts=false
	FollowViewRotation=false
	BehindViewDistance=180
	SpectatorSpeed=300
	CustomTimer=false
	LocationX=0
	LocationY=0
	TimerScale=1
	Red=127
	Green=127
	Blue=0
	WinX=-1
	WinY=-1
	NeverOpened=True
}