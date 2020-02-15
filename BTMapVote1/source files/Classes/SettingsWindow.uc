//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class SettingsWindow expands UWindowPageWindow;

var 	UWindowSmallButton 		CloseButton;
var 	UWindowSmallButton 		BTTButton;
var 	UWindowSmallButton 		BoostOn;
var 	UWindowSmallButton 		BoostOff;
var 	UWindowSmallButton 		GhostOn;
var 	UWindowSmallButton 		GhostOff;
var 	UWindowSmallButton 		SpecButton;
var 	UWindowSmallButton 		PlayButton;
var 	UWindowSmallButton 		TeamRed;
var 	UWindowSmallButton 		TeamBlue;

var 	UMenuRaisedButton 		cmdMenuKeySUI;
var 	UMenuRaisedButton 		cmdMenuKeyWJ;
var 	UMenuRaisedButton 		cmdMenuKeyCP;
var 	UMenuRaisedButton 		cmdMenuKeyNOCP;
var 	UMenuRaisedButton 		cmdMenuKey;
var 	UMenuRaisedButton 		SelectedButton;

var 	UMenuLabelControl		lblMenuKeySUI;
var 	UMenuLabelControl		lblMenuKeyWJ;
var 	UMenuLabelControl 		lblMenuKeyCP;
var 	UMenuLabelControl 		lblMenuKeyNOCP;
var 	UMenuLabelControl 		lblMenuKey;
var 	UMenuLabelControl 		lblMenuKeyBoost;
var 	UMenuLabelControl 		lblMenuKeyGhost;
var 	UMenuLabelControl 		lblMenuKeyTeam;

var		bool					bGoldTheme;
var 	bool 					bPolling;
var 	int 					CountItems;
var 	float 					LastVoteTime;
var 	float 					SelectionTime;

var 	string	 				BTServerIP;
var 	string 					OldHotKey;
var 	string 					OldHotKey2;
var 	string 					OldHotKey3;
var 	string 					OldHotKey4;
var 	string 					OldHotKey5;
var 	string 					RealKeyName[255];

function Created()
{
	local color TextColor,TextColor2;
	TextColor.R = 255;
	TextColor.G = 115;
	TextColor.B = 0;

	TextColor2.R = 0;
	TextColor2.G = 140;
	TextColor2.B = 255;

	Super.Created();

	if (Root.LookAndFeelClass != "UMenu.UMenuBlueLookAndFeel" )
		bGoldTheme = True;

	// SHIZZLE 									BT-GOD™							X		Y		Width	Height

	// BUNNYTRACK TOURNAMENT BUTTON
	BTTButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 	539, 	696, 	193, 	20));
	BTTButton.DownSound = sound 'Botpack.Click';
	BTTButton.Text= "BunnyTrack Tournament";
	BTTButton.bDisabled = false;

	// Close Button
	CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 	739, 	696, 	193, 	20));
	CloseButton.DownSound = sound 'Botpack.Click';
	CloseButton.Text= "Close";
	CloseButton.bDisabled = false;

	// HOTKEY SUICIDE TEXT
	lblMenuKeySUI = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 	539, 	428,	250, 	20));
	lblMenuKeySUI.SetText("Suicide:");
	lblMenuKeySUI.SetFont(F_Large);
	if (bGoldTheme)
		lblMenuKeySUI.SetTextColor(TextColor);
	else
		lblMenuKeySUI.SetTextColor(TextColor2);

	// HOTKEY SUICIDE BUTTON
	cmdMenuKeySUI = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 	882, 	432, 	50, 	1));
	cmdMenuKeySUI.bAcceptsFocus = False;
	cmdMenuKeySUI.bIgnoreLDoubleClick = True;
	cmdMenuKeySUI.bIgnoreMDoubleClick = True;
	cmdMenuKeySUI.bIgnoreRDoubleClick = True;

	// HOTKEY WALKJUMP TEXT
	lblMenuKeyWJ = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 	539, 	458, 	250, 	20));
	lblMenuKeyWJ.SetText("Walk Jump:");
	lblMenuKeyWJ.SetFont(F_Large);
	if (bGoldTheme)
		lblMenuKeyWJ.SetTextColor(TextColor);
	else
		lblMenuKeyWJ.SetTextColor(TextColor2);

	// HOTKEY WALKJUMP BUTTON
	cmdMenuKeyWJ	= UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 882, 	462, 	50, 	1));
	cmdMenuKeyWJ.bAcceptsFocus = False;
	cmdMenuKeyWJ.bIgnoreLDoubleClick = True;
	cmdMenuKeyWJ.bIgnoreMDoubleClick = True;
	cmdMenuKeyWJ.bIgnoreRDoubleClick = True;

	// HOTKEY SET CHECKPOINT TEXT
	lblMenuKeyCP = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 	539, 	488, 	250, 	20));
	lblMenuKeyCP.SetText("Set Checkpoint:");
	lblMenuKeyCP.SetFont(F_Large);
	if (bGoldTheme)
		lblMenuKeyCP.SetTextColor(TextColor);
	else
		lblMenuKeyCP.SetTextColor(TextColor2);

	// HOTKEY CHECKPOINT BUTTON
	cmdMenuKeyCP = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 	882, 	492, 	50, 	1));
	cmdMenuKeyCP.bAcceptsFocus = False;
	cmdMenuKeyCP.bIgnoreLDoubleClick = True;
	cmdMenuKeyCP.bIgnoreMDoubleClick = True;
	cmdMenuKeyCP.bIgnoreRDoubleClick = True;

	// HOTKEY SET NO CHECKPOINT TEXT
	lblMenuKeyNOCP = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 	539, 	518, 	250, 	20));
	lblMenuKeyNOCP.SetText("Remove Checkpoint:");
	lblMenuKeyNOCP.SetFont(F_Large);
	if (bGoldTheme)
		lblMenuKeyNOCP.SetTextColor(TextColor);
	else
		lblMenuKeyNOCP.SetTextColor(TextColor2);

	// HOTKEY NO CHECKPOINT BUTTON
	cmdMenuKeyNOCP = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 	882, 	522, 	50, 	1));
	cmdMenuKeyNOCP.bAcceptsFocus = False;
	cmdMenuKeyNOCP.bIgnoreLDoubleClick = True;
	cmdMenuKeyNOCP.bIgnoreMDoubleClick = True;
	cmdMenuKeyNOCP.bIgnoreRDoubleClick = True;

	// HOTKEY MAPVOTE TEXT
	lblMenuKey = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 		539, 	548, 	250, 	20));
	lblMenuKey.SetText("Open MapVote:");
	lblMenuKey.SetFont(F_Large);
	if (bGoldTheme)
		lblMenuKey.SetTextColor(TextColor);
	else
		lblMenuKey.SetTextColor(TextColor2);

	// HOTKEY MAPVOTE BUTTON
	cmdMenuKey = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 		882, 	552, 	50, 	1));
	cmdMenuKey.bAcceptsFocus = False;
	cmdMenuKey.bIgnoreLDoubleClick = True;
	cmdMenuKey.bIgnoreMDoubleClick = True;
	cmdMenuKey.bIgnoreRDoubleClick = True;

	// BOOST TEXT
	lblMenuKeyBoost = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 539, 	578, 	250, 	20));
	lblMenuKeyBoost.SetText("Boost:");
	lblMenuKeyBoost.SetFont(F_Large);
	if (bGoldTheme)
		lblMenuKeyBoost.SetTextColor(TextColor);
	else
		lblMenuKeyBoost.SetTextColor(TextColor2);

	// BOOST BUTTON ON
	BoostOn = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		826,	582,	50,		10));
	BoostOn.DownSound = sound 'Botpack.Click';
	BoostOn.Text="ON";
	BoostOn.bDisabled = false; 

	// BOOST BUTTON OFF
	BoostOff = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		882,	582,	50,		10));
	BoostOff.DownSound = sound 'Botpack.Click';
	BoostOff.Text="OFF";
	BoostOff.bDisabled = false; 

	// GHOST TEXT
	lblMenuKeyGhost = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 539, 	608, 	250, 	20));
	lblMenuKeyGhost.SetText("Ghost:");
	lblMenuKeyGhost.SetFont(F_Large);
	if (bGoldTheme)
		lblMenuKeyGhost.SetTextColor(TextColor);
	else
		lblMenuKeyGhost.SetTextColor(TextColor2);

	// GHOST BUTTON ON
	GhostOn = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		826,	612,	50,		10));
	GhostOn.DownSound = sound 'Botpack.Click';
	GhostOn.Text="ON";
	GhostOn.bDisabled = false; 

	// GHOST BUTTON OFF
	GhostOff = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		882,	612,	50,		10));
	GhostOff.DownSound = sound 'Botpack.Click';
	GhostOff.Text="OFF";
	GhostOff.bDisabled = false; 

	// Spec/Play TEXT
	lblMenuKey = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 		539, 	638, 	250, 	20));
	lblMenuKey.SetText("Change to:");
	lblMenuKey.SetFont(F_Large);
	if (bGoldTheme)
		lblMenuKey.SetTextColor(TextColor);
	else
		lblMenuKey.SetTextColor(TextColor2);

	// HOTKEY SPEC BUTTON
	SpecButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton',	826,	642,	50,		10));
	SpecButton.DownSound = sound 'Botpack.Click';
	SpecButton.Text="Spec";
	SpecButton.bDisabled = false; 	

	// HOTKEY PLAY BUTTON
	PlayButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton',	882,	642,	50,		10));
	PlayButton.DownSound = sound 'Botpack.Click';
	PlayButton.Text="Play";
	PlayButton.bDisabled = false; 

	// TEAMCOLOR TEXT
	lblMenuKeyTeam = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 	539, 	668, 	250, 	20));
	lblMenuKeyTeam.SetText("Change to:");
	lblMenuKeyTeam.SetFont(F_Large);
	if (bGoldTheme)
		lblMenuKeyTeam.SetTextColor(TextColor);
	else
		lblMenuKeyTeam.SetTextColor(TextColor2);

	// TEAMCOLOR BUTTON RED
	TeamRed = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		826,	672,	50,		10));
	TeamRed.DownSound = sound 'Botpack.Click';
	TeamRed.Text="Red";
	TeamRed.bDisabled = false; 
	
	// TEAMCOLOR BUTTON BLUE
	TeamBlue = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		882,	672,	50,		10));
	TeamBlue.DownSound = sound 'Botpack.Click';
	TeamBlue.Text="Blue";
	TeamBlue.bDisabled = false; 

	SetAcceptsFocus();
	LoadExistingKeys();
}

function KeyDown(int Key, float X, float Y)
{
	if (bPolling)
	{
		ProcessMenuKey(Key, RealKeyName[Key]);
		bPolling = False;
		SelectedButton.bDisabled = False;
	}
}

function ProcessMenuKey(int KeyNo, string KeyName)
{
//													// function keys                         // number keys
	if ((KeyName == "") || (KeyName == "Escape") || ((KeyNo >= 0x70 ) && (KeyNo <= 0x79)) || ((KeyNo >= 0x30 ) && (KeyNo <= 0x39)))
		return;

	if (cmdMenuKey.bDisabled)
		SetKey(KeyNo, KeyName);
	if (cmdMenuKeyCP.bDisabled)
		SetKey2(KeyNo, KeyName);
	if (cmdMenuKeyNOCP.bDisabled)
		SetKey3(KeyNo, KeyName);
	if (cmdMenuKeySUI.bDisabled)
		SetKey4(KeyNo, KeyName);
	if (cmdMenuKeyWJ.bDisabled)
		SetKey5(KeyNo, KeyName);
}

function SetKey(int KeyNo, string KeyName)
{
	GetPlayerOwner().ConsoleCommand("SET Input " $ KeyName $ " mutate bdbmapvote votemenu");
	SelectedButton.SetText(KeyName);

	// clear the old key binding
	if (OldHotKey != "")
		GetPlayerOwner().ConsoleCommand("SET Input " $ OldHotKey);
}

function SetKey2(int KeyNo, string KeyName)
{
	GetPlayerOwner().ConsoleCommand("SET Input " $ KeyName $ " mutate checkpoint");
	SelectedButton.SetText(KeyName);

	// clear the old key binding
	if (OldHotKey2 != "")
		GetPlayerOwner().ConsoleCommand("SET Input " $ OldHotKey2);
}

function SetKey3(int KeyNo, string KeyName)
{
	GetPlayerOwner().ConsoleCommand("SET Input " $ KeyName $ " mutate nocheckpoint");
	SelectedButton.SetText(KeyName);

	// clear the old key binding
	if (OldHotKey3 != "")
		GetPlayerOwner().ConsoleCommand("SET Input " $ OldHotKey3);
}

function SetKey4(int KeyNo, string KeyName)
{
	GetPlayerOwner().ConsoleCommand("SET Input " $ KeyName $ " suicide");
	SelectedButton.SetText(KeyName);

	// clear the old key binding
	if (OldHotKey4 != "")
		GetPlayerOwner().ConsoleCommand("SET Input " $ OldHotKey4);
}

function SetKey5(int KeyNo, string KeyName)
{
	GetPlayerOwner().ConsoleCommand("SET Input " $ KeyName $ " walking|jump");
	SelectedButton.SetText(KeyName);

	// clear the old key binding
	if (OldHotKey5 != "")
		GetPlayerOwner().ConsoleCommand("SET Input " $ OldHotKey5);
}

function LoadExistingKeys()
{
	local int I;
	local string KeyName;
	local string Alias;

	for (I = 0; I < 255; I++)
	{
		KeyName = GetPlayerOwner().ConsoleCommand("KEYNAME " $ i);
		RealKeyName[i] = KeyName;

		if (KeyName != "")
		{
			Alias = GetPlayerOwner().ConsoleCommand("KEYBINDING " $ KeyName);
			if (Caps(Alias) == "MUTATE BDBMAPVOTE VOTEMENU")
			{
				cmdMenuKey.SetText(KeyName);
				OldHotKey = KeyName;
			}
			if (Caps(Alias) == "MUTATE CHECKPOINT")
			{
				cmdMenuKeyCP.SetText(KeyName);
				OldHotKey2 = KeyName;
			}
			if (Caps(Alias) == "MUTATE NOCHECKPOINT")
			{
				cmdMenuKeyNOCP.SetText(KeyName);
				OldHotKey3 = KeyName;
			}
			if (Caps(Alias) == "SUICIDE")
			{
				cmdMenuKeySUI.SetText(KeyName);
				OldHotKey4 = KeyName;
			}
			if (Caps(Alias) == "WALKING|JUMP")
			{
				cmdMenuKeyWJ.SetText(KeyName);
				OldHotKey5 = KeyName;
			}
		}
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	super.Notify(C, E);

	switch(E)
	{	
		case DE_Click:
		    switch(C)
            {	
				case CloseButton:
					ParentWindow.ParentWindow.Close();
				break;

				case BTTButton:
					ParentWindow.ParentWindow.Close();
					GetPlayerOwner().UpdateURL("OverrideClass", "Botpack.CHSpectator", True);
					GetPlayerOwner().ConsoleCommand("OPEN "$BTServerIP);
				break;

				case TeamRed:
					GetPlayerOwner().ChangeTeam(0);
				break;

				case TeamBlue:
					GetPlayerOwner().ChangeTeam(1);
				break;

				case SpecButton:
					ParentWindow.ParentWindow.Close();
					GetPlayerOwner().UpdateURL("OverrideClass", "Botpack.CHSpectator", True);
					GetPlayerOwner().ConsoleCommand("RECONNECT");
				break;

				case PlayButton:
					ParentWindow.ParentWindow.Close();
					GetPlayerOwner().UpdateURL("OverrideClass", "", True);
					GetPlayerOwner().ConsoleCommand("RECONNECT");
				break;

				case BoostOn:
					GetPlayerOwner().ConsoleCommand("MUTATE BOOST");
				break;

				case BoostOff:
					GetPlayerOwner().ConsoleCommand("MUTATE NOBOOST");
				break;

				case GhostOn:
					GetPlayerOwner().ConsoleCommand("MUTATE GHOST");
				break;

				case GhostOff:
					GetPlayerOwner().ConsoleCommand("MUTATE NOGHOST");
				break;

				case cmdMenuKey:
					if (UMenuRaisedButton(C) != None)
					{    
						SelectedButton = UMenuRaisedButton(C);
						if (SelectedButton != None)
						{  
							bPolling = True;
							SelectedButton.bDisabled = True;
						}
					}
				break;

				case cmdMenuKeySUI:
					if (UMenuRaisedButton(C) != None)
					{    
						SelectedButton = UMenuRaisedButton(C);
						if (SelectedButton != None)
						{  
							bPolling = True;
							SelectedButton.bDisabled = True;
						}
					}
				break;

				case cmdMenuKeyWJ:
					if (UMenuRaisedButton(C) != None)
					{    
						SelectedButton = UMenuRaisedButton(C);
						if (SelectedButton != None)
						{  
							bPolling = True;
							SelectedButton.bDisabled = True;
						}
					}
				break;

				case cmdMenuKeyCP:
					if (UMenuRaisedButton(C) != None)
					{    
						SelectedButton = UMenuRaisedButton(C);
						if (SelectedButton != None)
						{  
							bPolling = True;
							SelectedButton.bDisabled = True;
						}
					}
				break;

				case cmdMenuKeyNOCP:
					if (UMenuRaisedButton(C) != None)
					{    
						SelectedButton = UMenuRaisedButton(C);
						if (SelectedButton != None)
						{  
							bPolling = True;
							SelectedButton.bDisabled = True;
						}
					}
				break;
			}
        break;
    }
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local int i,p1,p2,pos;
    local string TempText,TextLine;
    local float X, Y, W, H;

    Super.Paint(C,MouseX,MouseY);

    DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');

	if(bGoldTheme)
	{
		// Draw Thunder
		DrawStretchedTexture(C, 56, 	35, 	160, 	700, 	Texture'ThunderOrange');
		// Draw BTSettingsLogo
		DrawStretchedTexture(C, 8,		8,		256,	32,		Texture'BTSettingsOrange');
		// Draw UT Logo
		DrawStretchedTexture(C, 275, 	92, 	655, 	246, 	Texture'UTorange');
		// Draw BT Logo
		DrawStretchedTexture(C, 273, 	432, 	256, 	256, 	Texture'BTorange');
		// BORDERS UT LOGO BOX
		DrawStretchedTexture(C, 273, 	12, 	4, 		406, 	Texture'BorderOrange'); // LEFT
		DrawStretchedTexture(C, 928, 	12, 	4, 		406, 	Texture'BorderOrange'); // RIGHT
		DrawStretchedTexture(C, 273, 	8, 		659,	4, 		Texture'BorderOrange'); // UP
		DrawStretchedTexture(C, 273, 	418, 	659, 	4, 		Texture'BorderOrange'); // DOWN
		// BT MAPVOTE Logo
		DrawStretchedTexture(C, 273, 	696, 	64, 	16, 	Texture'TRIDENT1orange');
		DrawStretchedTexture(C, 465, 	696, 	64, 	16, 	Texture'TRIDENT2orange');
		DrawStretchedTexture(C, 337, 	696, 	128, 	16, 	Texture'MAPVOTEorange');
		DrawStretchedTexture(C, 273, 	688, 	2, 		15, 	Texture'BorderOrange'); // LEFT
		DrawStretchedTexture(C, 527, 	688, 	2, 		15, 	Texture'BorderOrange'); // RIGHT
	}
	else
	{
		// Draw Thunder
		DrawStretchedTexture(C, 56,		35,		160,	700,	Texture'ThunderBlue');
		// Draw BTSettingsLogo
		DrawStretchedTexture(C, 8,		8,		256,	32,		Texture'BTSettingsBlue');
		// Draw UT Logo
		DrawStretchedTexture(C, 275,	92, 	655, 	246,	Texture'UTblue');
		// Draw BT Logo
		DrawStretchedTexture(C, 273,	432,	256,	256,	Texture'BTblue');
		// BORDERS UT LOGO BOX
		DrawStretchedTexture(C, 273, 	12, 	4, 		406, 	Texture'BorderBlue'); // LEFT
		DrawStretchedTexture(C, 928, 	12, 	4, 		406, 	Texture'BorderBlue'); // RIGHT
		DrawStretchedTexture(C, 273, 	8, 		659,	4, 		Texture'BorderBlue'); // UP
		DrawStretchedTexture(C, 273, 	418, 	659, 	4, 		Texture'BorderBlue'); // DOWN
		// BT MAPVOTE Logo
		DrawStretchedTexture(C, 273, 	696, 	64, 	16, 	Texture'TRIDENT1blue');
		DrawStretchedTexture(C, 465, 	696, 	64, 	16, 	Texture'TRIDENT2blue');
		DrawStretchedTexture(C, 337, 	696, 	128, 	16, 	Texture'MAPVOTEblue');
		DrawStretchedTexture(C, 273, 	688, 	2, 		15, 	Texture'BorderBlue'); // LEFT
		DrawStretchedTexture(C, 527, 	688, 	2, 		15, 	Texture'BorderBlue'); // RIGHT
	}
}

function Close(optional bool bByParent)
{
	local int w, Mode;
	Super.Close(bByParent);
}