class LiveFeedHUDItem expands UMenuModMenuItem;

var pawn theCheck;
var levelinfo lvl;
var Ticker myTick;

function setup()
{
	super.setup();
	lvl = menuitem.owner.getentrylevel();
}

function execute()
{
	menuitem.bchecked =! menuitem.bchecked;
	menuitem.owner.GetPlayerOwner().ClientMessage(Caps(menuitem.owner.GetPlayerOwner()));
	if(menuitem.bchecked)
	{
		if(InStr(Caps(menuitem.owner.GetPlayerOwner()), "ENTRY.") == -1 && InStr(Caps(menuitem.owner.GetPlayerOwner()), "UT-LOGO-MAP.") == -1)
			menuitem.owner.GetPlayerOwner().ConsoleCommand("RECONNECT");

		myTick = lvl.Spawn(class'Ticker');
		myTick.HUDItem = Self;
	}
	else
	{
		if(InStr(Caps(menuitem.owner.GetPlayerOwner()), "ENTRY.") == -1 && InStr(Caps(menuitem.owner.GetPlayerOwner()), "UT-LOGO-MAP.") == -1)
			menuitem.owner.GetPlayerOwner().ConsoleCommand("RECONNECT");

		foreach lvl.allactors(class'Ticker', myTick)
		{
			myTick.HUDItem = None;
			myTick.Destroy();
		}
	}
}

function Ticking( float Delta )
{
	if(menuitem.owner.GetPlayerOwner() != None && menuitem.owner.GetPlayerOwner() != theCheck)
	{
		if(InStr(Caps(menuitem.owner.GetPlayerOwner()), "ENTRY.") == -1 && InStr(Caps(menuitem.owner.GetPlayerOwner()), "UT-LOGO-MAP.") == -1)
			menuitem.owner.GetPlayerOwner().myHUD = menuitem.owner.GetPlayerOwner().Spawn(Class'LiveFeedCTFHUD', menuitem.owner.GetPlayerOwner());

		theCheck = menuitem.owner.GetPlayerOwner();
	}
}