//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MatchVote made by OwYeaW				  		  BT-GOD™
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

var 	UWindowSmallButton 		LinkButton1Button;
var 	UWindowSmallButton 		LinkButton2Button;
var 	UWindowSmallButton 		LinkButton3Button;
var 	UWindowSmallButton 		LinkButton4Button;
var 	UWindowSmallButton 		LinkButton5Button;

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

var		string					LinkButton1;
var		string					LinkButton1Name;
var		string					LinkButton2;
var		string					LinkButton2Name;
var		string					LinkButton3;
var		string					LinkButton3Name;
var		string					LinkButton4;
var		string					LinkButton4Name;
var		string					LinkButton5;
var		string					LinkButton5Name;

var		color					BlackColor;
var		color					OrangeColor;
var		color					BlueColor;
var		color					ThemeColor;
//-----------------------------------------------------------------------------
function Created()
{
	Super.Created();

	if (Root.LookAndFeelClass == "UMenu.UMenuBlueLookAndFeel")
	{
		bGoldTheme = false;
		ThemeColor = BlueColor;
	}
	else
	{
		bGoldTheme = true;
		ThemeColor = OrangeColor;
	}

	// SHIZZLE 									BT-GOD™							X		Y		Width	Height

	//	BUNNYTRACK TOURNAMENT BUTTON
	BTTButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 	539, 	696, 	193, 	20));
	BTTButton.DownSound = sound 'Botpack.Click';
	BTTButton.Text= "BunnyTrack Tournament Server";
	BTTButton.bDisabled = false;

	//	Close Button
	CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 	739, 	696, 	193, 	20));
	CloseButton.DownSound = sound 'Botpack.Click';
	CloseButton.Text= "Close";
	CloseButton.bDisabled = false;

	//	HOTKEY SUICIDE TEXT
	lblMenuKeySUI = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 	539, 	428,	250, 	20));
	lblMenuKeySUI.SetText("Suicide:");
	lblMenuKeySUI.SetFont(F_Large);
	lblMenuKeySUI.SetTextColor(ThemeColor);

	//	HOTKEY SUICIDE BUTTON
	cmdMenuKeySUI = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 	882, 	432, 	50, 	1));
	cmdMenuKeySUI.bAcceptsFocus = False;
	cmdMenuKeySUI.bIgnoreLDoubleClick = True;
	cmdMenuKeySUI.bIgnoreMDoubleClick = True;
	cmdMenuKeySUI.bIgnoreRDoubleClick = True;

	//	HOTKEY WALKJUMP TEXT
	lblMenuKeyWJ = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 	539, 	458, 	250, 	20));
	lblMenuKeyWJ.SetText("Walk Jump:");
	lblMenuKeyWJ.SetFont(F_Large);
	lblMenuKeyWJ.SetTextColor(ThemeColor);

	//	HOTKEY WALKJUMP BUTTON
	cmdMenuKeyWJ	= UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 882, 	462, 	50, 	1));
	cmdMenuKeyWJ.bAcceptsFocus = False;
	cmdMenuKeyWJ.bIgnoreLDoubleClick = True;
	cmdMenuKeyWJ.bIgnoreMDoubleClick = True;
	cmdMenuKeyWJ.bIgnoreRDoubleClick = True;

	//	HOTKEY SET CHECKPOINT TEXT
	lblMenuKeyCP = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 	539, 	488, 	250, 	20));
	lblMenuKeyCP.SetText("Set Checkpoint:");
	lblMenuKeyCP.SetFont(F_Large);
	lblMenuKeyCP.SetTextColor(ThemeColor);

	//	HOTKEY CHECKPOINT BUTTON
	cmdMenuKeyCP = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 	882, 	492, 	50, 	1));
	cmdMenuKeyCP.bAcceptsFocus = False;
	cmdMenuKeyCP.bIgnoreLDoubleClick = True;
	cmdMenuKeyCP.bIgnoreMDoubleClick = True;
	cmdMenuKeyCP.bIgnoreRDoubleClick = True;

	//	HOTKEY SET NO CHECKPOINT TEXT
	lblMenuKeyNOCP = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 	539, 	518, 	250, 	20));
	lblMenuKeyNOCP.SetText("Remove Checkpoint:");
	lblMenuKeyNOCP.SetFont(F_Large);
	lblMenuKeyNOCP.SetTextColor(ThemeColor);

	//	HOTKEY NO CHECKPOINT BUTTON
	cmdMenuKeyNOCP = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 	882, 	522, 	50, 	1));
	cmdMenuKeyNOCP.bAcceptsFocus = False;
	cmdMenuKeyNOCP.bIgnoreLDoubleClick = True;
	cmdMenuKeyNOCP.bIgnoreMDoubleClick = True;
	cmdMenuKeyNOCP.bIgnoreRDoubleClick = True;

	//	HOTKEY MAPVOTE TEXT
	lblMenuKey = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 		539, 	548, 	250, 	20));
	lblMenuKey.SetText("Open Mapvote:");
	lblMenuKey.SetFont(F_Large);
	lblMenuKey.SetTextColor(ThemeColor);

	//	HOTKEY MAPVOTE BUTTON
	cmdMenuKey = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 		882, 	552, 	50, 	1));
	cmdMenuKey.bAcceptsFocus = False;
	cmdMenuKey.bIgnoreLDoubleClick = True;
	cmdMenuKey.bIgnoreMDoubleClick = True;
	cmdMenuKey.bIgnoreRDoubleClick = True;

	//	BOOST TEXT
	lblMenuKeyBoost = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 539, 	578, 	250, 	20));
	lblMenuKeyBoost.SetText("Boost:");
	lblMenuKeyBoost.SetFont(F_Large);
	lblMenuKeyBoost.SetTextColor(ThemeColor);

	//	BOOST BUTTON ON
	BoostOn = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		826,	582,	50,		10));
	BoostOn.DownSound = sound 'Botpack.Click';
	BoostOn.Text="ON";
	BoostOn.bDisabled = false; 

	//	BOOST BUTTON OFF
	BoostOff = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		882,	582,	50,		10));
	BoostOff.DownSound = sound 'Botpack.Click';
	BoostOff.Text="OFF";
	BoostOff.bDisabled = false; 

	//	GHOST TEXT
	lblMenuKeyGhost = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 539, 	608, 	250, 	20));
	lblMenuKeyGhost.SetText("Ghost:");
	lblMenuKeyGhost.SetFont(F_Large);
	lblMenuKeyGhost.SetTextColor(ThemeColor);

	//	GHOST BUTTON ON
	GhostOn = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		826,	612,	50,		10));
	GhostOn.DownSound = sound 'Botpack.Click';
	GhostOn.Text="ON";
	GhostOn.bDisabled = false; 

	//	GHOST BUTTON OFF
	GhostOff = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		882,	612,	50,		10));
	GhostOff.DownSound = sound 'Botpack.Click';
	GhostOff.Text="OFF";
	GhostOff.bDisabled = false; 

	//	Spec/Play TEXT
	lblMenuKey = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 		539, 	638, 	250, 	20));
	lblMenuKey.SetText("Change to:");
	lblMenuKey.SetFont(F_Large);
	lblMenuKey.SetTextColor(ThemeColor);

	//	HOTKEY SPEC BUTTON
	SpecButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton',	826,	642,	50,		10));
	SpecButton.DownSound = sound 'Botpack.Click';
	SpecButton.Text="Spec";
	SpecButton.bDisabled = false; 	

	//	HOTKEY PLAY BUTTON
	PlayButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton',	882,	642,	50,		10));
	PlayButton.DownSound = sound 'Botpack.Click';
	PlayButton.Text="Play";
	PlayButton.bDisabled = false; 

	//	TEAMCOLOR TEXT
	lblMenuKeyTeam = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 	539, 	668, 	250, 	20));
	lblMenuKeyTeam.SetText("Change to:");
	lblMenuKeyTeam.SetFont(F_Large);
	lblMenuKeyTeam.SetTextColor(ThemeColor);

	//	TEAMCOLOR BUTTON RED
	TeamRed = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		826,	672,	50,		10));
	TeamRed.DownSound = sound 'Botpack.Click';
	TeamRed.Text="Red";
	TeamRed.bDisabled = false;

	//	TEAMCOLOR BUTTON BLUE
	TeamBlue = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		882,	672,	50,		10));
	TeamBlue.DownSound = sound 'Botpack.Click';
	TeamBlue.Text="Blue";
	TeamBlue.bDisabled = false;

	//	LinkButton1Button
	LinkButton1Button = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		283,	16,		123,	10));
	LinkButton1Button.DownSound = sound 'Botpack.Click';
	LinkButton1Button.Text="";
	LinkButton1Button.bDisabled = false;

	//	LinkButton2Button
	LinkButton2Button = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		412,	16,		123,	10));
	LinkButton2Button.DownSound = sound 'Botpack.Click';
	LinkButton2Button.Text="";
	LinkButton2Button.bDisabled = false;

	//	LinkButton3Button
	LinkButton3Button = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		541,	16,		123,	10));
	LinkButton3Button.DownSound = sound 'Botpack.Click';
	LinkButton3Button.Text="";
	LinkButton3Button.bDisabled = false;

	//	LinkButton4Button
	LinkButton4Button = UWindowSmallButton(CreateControl(class'UWindowSmallButton',			670,	16,		123,	10));
	LinkButton4Button.DownSound = sound 'Botpack.Click';
	LinkButton4Button.Text="";
	LinkButton4Button.bDisabled = false;

	//	LinkButton5Button
	LinkButton5Button = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		799,	16,		123,	10));
	LinkButton5Button.DownSound = sound 'Botpack.Click';
	LinkButton5Button.Text="";
	LinkButton5Button.bDisabled = false;

	SetAcceptsFocus();
	LoadExistingKeys();
}

function KeyDown(int Key, float X, float Y)
{
	if(bPolling)
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

				case LinkButton1Button:
					GetPlayerOwner().ConsoleCommand("Start " $ LinkButton1);
				break;

				case LinkButton2Button:
					GetPlayerOwner().ConsoleCommand("Start " $ LinkButton2);
				break;

				case LinkButton3Button:
					GetPlayerOwner().ConsoleCommand("Start " $ LinkButton3);
				break;

				case LinkButton4Button:
					GetPlayerOwner().ConsoleCommand("Start " $ LinkButton4);
				break;

				case LinkButton5Button:
					GetPlayerOwner().ConsoleCommand("Start " $ LinkButton5);
				break;
			}
        break;
    }
}

function Paint(Canvas C, float MouseX, float MouseY)
{
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
		// Draw Instructions
		//DrawStretchedTexture(C, 420, 	8,		512, 	128,	Texture'INSTRorange');
		// Draw BT Logo
		DrawStretchedTexture(C, 273, 	432, 	256, 	256, 	Texture'BTorange');
		//BORDERS UT LOGO BOX
		DrawStretchedTexture(C, 273, 	12, 	4, 		406, 	Texture'BorderOrange'); // LEFT
		DrawStretchedTexture(C, 928, 	12, 	4, 		406, 	Texture'BorderOrange'); // RIGHT
		DrawStretchedTexture(C, 273, 	8, 		659,	4, 		Texture'BorderOrange'); // UP
		DrawStretchedTexture(C, 273, 	418, 	659, 	4, 		Texture'BorderOrange'); // DOWN
		//	BT MATCHVOTE Logo
		DrawStretchedTexture(C, 273, 	696, 	64, 	16, 	Texture'TRIDENT1orange');
		DrawStretchedTexture(C, 465, 	696, 	64, 	16, 	Texture'TRIDENT2orange');
		DrawStretchedTexture(C, 337, 	696, 	128, 	16, 	Texture'MATCHVOTEorange');
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
		// Draw Instructions
		//DrawStretchedTexture(C, 420,	8,		512, 	128,	Texture'INSTRblue');
		// Draw BT Logo
		DrawStretchedTexture(C, 273,	432,	256,	256,	Texture'BTblue');
		//BORDERS UT LOGO BOX
		DrawStretchedTexture(C, 273, 	12, 	4, 		406, 	Texture'BorderBlue'); // LEFT
		DrawStretchedTexture(C, 928, 	12, 	4, 		406, 	Texture'BorderBlue'); // RIGHT
		DrawStretchedTexture(C, 273, 	8, 		659,	4, 		Texture'BorderBlue'); // UP
		DrawStretchedTexture(C, 273, 	418, 	659, 	4, 		Texture'BorderBlue'); // DOWN
		//	BT MATCHVOTE Logo
		DrawStretchedTexture(C, 273, 	696, 	64, 	16, 	Texture'TRIDENT1blue');
		DrawStretchedTexture(C, 465, 	696, 	64, 	16, 	Texture'TRIDENT2blue');
		DrawStretchedTexture(C, 337, 	696, 	128, 	16, 	Texture'MATCHVOTEblue');
		DrawStretchedTexture(C, 273, 	688, 	2, 		15, 	Texture'BorderBlue'); // LEFT
		DrawStretchedTexture(C, 527, 	688, 	2, 		15, 	Texture'BorderBlue'); // RIGHT
	}
}

function Close(optional bool bByParent)
{
	local int w, Mode;
	Super.Close(bByParent);
}

defaultproperties
{
	OrangeColor=(R=255,G=115)
    BlueColor=(B=255,G=140)
}