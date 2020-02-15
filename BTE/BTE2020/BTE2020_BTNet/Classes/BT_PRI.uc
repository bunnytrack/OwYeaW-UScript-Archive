//=============================================================================
// BT_PRI made by OwYeaW
//=============================================================================
class BT_PRI expands ReplicationInfo;

var int PlayerID, Netspeed;
var string PersonalBest, DefaultSkin, DefaultFace;
var ClientData Config;

var int	ArmorAmount, ChestAmount, ThighAmount, BootCharges;
var bool bShieldbelt, bChestArmor, bThighArmor, bJumpBoots;

var bool NetSpeedLimiter, KickPlayer, Broadcast, AutoCorrectNetspeed;
var int CorrectNetspeed, MinimumNetSpeed, MaximumNetSpeed;
//=============================================================================
// Replicating armor + boots from server to clients
//=============================================================================
replication
{
	reliable if(Role < ROLE_Authority)
		ServerSkinStuff;

	reliable if(Role == ROLE_Authority)
		NetSpeed, PersonalBest, PlayerID, ArmorAmount, ChestAmount, ThighAmount, bShieldbelt, bChestArmor, bThighArmor, bJumpBoots, BootCharges, ClientSkinStuff, DefaultSkin, DefaultFace, CorrectClient;
}
event Spawned()
{
	if(Role == ROLE_Authority)
		Enable('Tick');

	ClientSkinStuff();
}
simulated function ClientSkinStuff()
{
	local string Skin, Face;

	Skin = PlayerPawn(Owner).GetDefaultURL("Skin");
	Face = PlayerPawn(Owner).GetDefaultURL("Face");

	ServerSkinStuff(Skin, Face);
}
function ServerSkinStuff(string gotSkin, string gotFace)
{
	DefaultSkin = gotSkin;
	DefaultFace = gotFace;
}
//=============================================================================
// Tick - checks armor and boots in player's inventory + netspeed check
//=============================================================================
function Tick(float d)
{
	Local inventory Inv;
	local int i;

	if(PlayerPawn(Owner) == None)
		Destroy();
	else
	{
		BootCharges = 0;
		ArmorAmount = 0;
		ThighAmount = 0;
		ChestAmount = 0;
		bJumpBoots = false;
		bShieldbelt = false;
		bThighArmor = false;
		bChestArmor = false;

		for(Inv = PlayerPawn(Owner).Inventory; Inv != None; Inv = Inv.Inventory)
		{
			if(Inv.bIsAnArmor)
			{
				if( Inv.IsA('UT_Shieldbelt') )
					bShieldbelt = true;
				else if( Inv.IsA('Thighpads') )
				{
					ThighAmount += Inv.Charge;
					bThighArmor = true;
				}
				else
				{
					bChestArmor = true;
					ChestAmount += Inv.Charge;
				}
				ArmorAmount += Inv.Charge;
			}
			else if( Inv.IsA('UT_JumpBoots') )
			{
				bJumpBoots = true;
				BootCharges = Inv.Charge;
			}
			else
			{
				i++;
				if(i > 100)
					break; // can occasionally get temporary loops in netplay
			}
		}

		NetSpeed = PlayerPawn(Owner).Player.CurrentNetSpeed;
		if(NetSpeedLimiter)
			if(NetSpeed > MaximumNetSpeed || NetSpeed < MinimumNetSpeed)
				TakeAction(NetSpeed);

		if(Config != None)
		{
			if(PersonalBest != Config.BestTimeStr)
				PersonalBest = Config.BestTimeStr;
		}
		else
			Config = FindConfig(PlayerPawn(Owner));
	}
}
//=============================================================================
// Find the matching Config
//=============================================================================
function ClientData FindConfig(PlayerPawn PP)
{
	local ClientData cfg;

	foreach AllActors(class'ClientData', cfg)
		if(PP == cfg.Owner)
			return cfg;
	return None;
}
//=============================================================================
// Anti Netspeed cheat Functions
//=============================================================================
function TakeAction(int NetSpeed)
{
	PlayerPawn(Owner).ClientMessage("Netspeed values should be between " $ MinimumNetSpeed $ " and " $ MaximumNetSpeed);
	if(AutoCorrectNetSpeed)
	{
		CorrectClient(CorrectNetspeed);
		PlayerPawn(Owner).ClientMessage("Your netspeed was " $ NetSpeed $ " and has been reset to " $ CorrectNetspeed);
	}
	else
		PlayerPawn(Owner).ClientMessage("Your netspeed is " $ NetSpeed);

	if(KickPlayer)
		PlayerPawn(Owner).Destroy();
	else
		PlayerPawn(Owner).Suicide();

	if(Broadcast)
	{
		if(KickPlayer)
			BroadcastMessage(PlayerPawn(Owner).PlayerReplicationInfo.PlayerName $ " tried to use " $ NetSpeed $ " netspeed and got kicked from the server", true, 'CriticalEvent');
		else if(AutoCorrectNetSpeed)
			BroadcastMessage(PlayerPawn(Owner).PlayerReplicationInfo.PlayerName $ " tried to use " $ NetSpeed $ " netspeed", true, 'CriticalEvent');
	}

	Disable('Tick');
	SetTimer(0.3, false);
}
simulated function CorrectClient(int NetSpeed)
{
	PlayerPawn(Owner).ConsoleCommand("NETSPEED " $ NetSpeed);
}
function Timer()
{
	Enable('Tick');
}
//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=9.000000
}