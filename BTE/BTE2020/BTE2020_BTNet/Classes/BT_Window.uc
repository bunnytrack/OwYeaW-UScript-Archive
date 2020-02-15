//=============================================================================
// BT_Window made by OwYeaW
//=============================================================================
class BT_Window expands UWindowFramedWindow;
//-----------------------------------------------------------------------------
var		UWindowSmallCloseButton		CloseButton;
var		BT_TabWindow				TabWindow;
//-----------------------------------------------------------------------------
function Created()
{
//	LookAndFeel = Root.GetLookAndFeel("UWindow.UWindowWin95LookAndFeel");
	GetPlayerOwner().PlaySound(Sound'UMenu.WindowOpen', SLOT_Interact);

	ClientArea = CreateWindow(ClientClass, 4, 16, WinWidth - 8, WinHeight - 20, OwnerWindow);
	TabWindow = BT_TabWindow(ClientArea);
	CloseBox = UWindowFrameCloseBox(CreateWindow(Class'UWindowFrameCloseBox', WinWidth-20, WinHeight-20, 11, 10));
	CloseBox.DownSound = Sound'Botpack.Click';

	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

function Close(optional bool bByParent)
{
	if(TabWindow.GeneralPage.BTEC != None)
	{
		if(WinLeft != TabWindow.GeneralPage.BTEC.WinX)
			TabWindow.GeneralPage.BTEC.WinSetting("X", WinLeft);
		if(WinTop != TabWindow.GeneralPage.BTEC.WinY)
			TabWindow.GeneralPage.BTEC.WinSetting("Y", WinTop);
	}
	Super.Close(bByParent);
	WindowConsole(GetPlayerOwner().Player.Console).CloseUWindow();
}

defaultproperties
{
    ClientClass=Class'BT_TabWindow'
    WindowTitle="BunnyTrack Settings"
    bStatusBar=False
    bLeaveOnscreen=True
	bSizable=False
}