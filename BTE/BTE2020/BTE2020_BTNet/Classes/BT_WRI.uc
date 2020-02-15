//=============================================================================
// BT_WRI made by OwYeaW
//=============================================================================
class BT_WRI expands WRI;
//-----------------------------------------------------------------------------
var		ClientData		Config;
var		BTEClientData	BTEC;
//-----------------------------------------------------------------------------
replication
{
	reliable if(Role == ROLE_Authority)
		BTEC;

	reliable if(Role < ROLE_Authority)
		AntiBoost;
}

simulated function bool SetupWindow()
{
	local ClientData cfg;

	foreach Level.AllActors(class'ClientData', cfg)
	{
		if(cfg.Owner == Owner)
		{
			Config = cfg;
			break;
		}
	}

	if(Super.SetupWindow())
		SetTimer(0.01, false);
	else
		log("Super.SetupWindow() = false");
	
	if(TheWindow != None)
	{
		if(BTEC != None)
		{
			if(BTEC.NeverOpened)
				BTEC.NeverOpened = False;

			if(BTEC.WinX != -1 || BTEC.WinY != -1)
			{
				TheWindow.WinLeft = BTEC.WinX;
				TheWindow.WinTop = BTEC.WinY;
			}
		}
	}
}

simulated event Timer()
{
	BT_Window(TheWindow).TabWindow.GeneralPage.BTWRI = Self;
	BT_Window(TheWindow).TabWindow.GeneralPage.BTEC = BTEC;
	BT_Window(TheWindow).TabWindow.GeneralPage.Config = Config;
	BT_Window(TheWindow).TabWindow.GeneralPage.LoadSettings();

	BT_Window(TheWindow).TabWindow.SpectatorPage.BTEC = BTEC;
	BT_Window(TheWindow).TabWindow.SpectatorPage.LoadSettings();

	BT_Window(TheWindow).TabWindow.TimerPage.BTEC = BTEC;
	BT_Window(TheWindow).TabWindow.TimerPage.LoadSettings();
}

simulated function AntiBoost(ClientData cfg, bool bValue)
{
	cfg.SetAntiBoost(bValue);
}

defaultproperties
{
    WindowClass=Class'BT_Window'
    WinLeft=50
    WinTop=30
    WinWidth=400
    WinHeight=250
}