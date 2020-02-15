//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class MapVoteClientWindow expands UWindowPageWindow;

#exec obj load 					FILE=Textures\BTmv.utx				PACKAGE=BTMapVote1

var 	MapVoteListBox 			MapListBox;
var 	PlayerVoteListBox 		PlayerListBox;
var 	MapStatusListBox 		MapStatus;

var 	UWindowSmallButton 		VoteButton;
var 	UWindowSmallButton 		RandomButton;
var 	UWindowSmallButton 		FindMap;
var 	UWindowSmallButton		PrevMap;
var 	UWindowSmallButton 		SendButton;
var 	UWindowSmallButton 		CloseButton;

var 	UWindowEditControl 		txtFind;
var 	UWindowEditControl 		txtMessage;

var 	UMenuLabelControl 		lblMapCount;
var 	UmenuLabelControl 		lblCurrentMap;
var 	UmenuLabelControl 		lblFoundMaps;

var		bool					bGoldTheme;	
var 	int 					CountItems;
var 	float 					LastVoteTime;
var 	float 					SelectionTime;
var 	string 					CurrentMap,ResultFind;
var 	string 					OtherPreFix,MapPreFixOverRide,PreFixSwap;
//-----------------------------------------------------------------------------
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

	if (Root.LookAndFeelClass != "UMenu.UMenuBlueLookAndFeel")
		bGoldTheme = True;

	// SHIZZLE 								BT-GOD™								X		Y		Width	Height

	// MaplistBox
	MapListBox = MapVoteListBox(CreateControl(class'MapVoteListBox',			10,		40,		252,	646));
	MapListBox.Items.Clear();

	// Vote Button
	VoteButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton',	64,		696,	200,	20));
	VoteButton.DownSound = sound 'Botpack.Click';
	VoteButton.Text= "Vote";
	VoteButton.bDisabled = false;

	// Random button
	RandomButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton',	8,		696,	50,		20));
	RandomButton.DownSound = sound 'Botpack.Click';
	RandomButton.Text= "Random";
	RandomButton.bDisabled = false;

	// MapStatuslistBox
	MapStatus = MapStatusListBox(CreateControl(class'MapStatusListBox',			541,	500,	267,	186));
	MapStatus.bAcceptsFocus = False;
	MapStatus.Items.Clear();

	// PlayerListBox
	PlayerListBox = PlayerVoteListBox(CreateControl(class'PlayerVoteListBox',	808,	500,	122,	186));
	PlayerListBox.Items.Clear();  

	// MapCount
	lblMapCount = UMenuLabelControl(CreateControl(class'UMenuLabelControl',		539,	481,	250,	10));
	lblMapCount.SetText("");
	lblMapCount.SetFont(F_Normal);
	if (bGoldTheme)
		lblMapCount.SetTextColor(TextColor);
	else
		lblMapCount.SetTextColor(TextColor2);

	// Number of found maps
	lblfoundmaps = UMenuLabelControl(CreateControl(class'UMenuLabelControl',	709,	481,	585,	10));
	lblfoundmaps.SetText("Maps Found:");
	lblfoundmaps.SetFont(F_Normal);
	if (bGoldTheme)
		lblfoundmaps.SetTextColor(TextColor);
	else
		lblfoundmaps.SetTextColor(TextColor2);

	// Box/line for writing speech/chat messages
	txtMessage = UWindowEditControl(CreateControl(class'UWindowEditControl', 	284, 	696,	510, 	25));
	txtMessage.SetText("");
	txtMessage.SetNumericOnly(false);
	txtMessage.SetHistory(true);
	//txtMessage.SetMaxLength(1337);

	// Button to send the speech message
	SendButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 	806, 	696, 	60, 	25));
	SendButton.DownSound = sound 'Botpack.Click';
	SendButton.Text= "Say";
	SendButton.bDisabled = false;

	// Close Button
	CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 	872, 	696, 	60, 	20));
	CloseButton.DownSound = sound 'Botpack.Click';
	CloseButton.Text= "Close";
	CloseButton.bDisabled = false;

	// txtFind
	txtFind = UWindowEditControl(CreateControl(class'UWindowEditControl',		284,	460,	510,	25));
	txtFind.SetNumericOnly(false);
	txtFind.SetText("");

	// FindMap
	FindMap = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		872,	460,	60,		10));
	FindMap.DownSound = sound 'Botpack.Click';
	FindMap.Text="Find Next";
	FindMap.bDisabled = false; 

	// PrevMap
	PrevMap = UWindowSmallButton(CreateControl(class'UWindowSmallButton',		806,	460,	60,		10));
	PrevMap.DownSound = sound 'Botpack.Click';
	PrevMap.Text="Find Prev";
	PrevMap.bDisabled = false; 
}

function Notify(UWindowDialogControl C, byte E)
{
	local int mapnum;

	Super.Notify(C,E);

	switch(E)
	{
		case DE_Change:
			switch(C)
			{
				case txtFind:
					CountItems = 1;
					if(len(txtFind.GetValue()) >= 2)
						MapListBox.Find(txtFind.GetValue()); 
				break;
			}
		break;

		case DE_DoubleClick:
			switch(C)
			{
				case MapListBox:
					if(GetPlayerOwner().Level.TimeSeconds > LastVoteTime - 1) // prevent spamming 5 (now on 1 by BT-GOD)
					{
						if(Left(UMenuMapVoteList(MapListBox.SelectedItem).MapName,3) != "[X]" || GetPlayerOwner().PlayerReplicationInfo.bAdmin)
						{
							GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE MAP "$UMenuMapVoteList(MapListBox.SelectedItem).MapName);
							LastVoteTime = GetPlayerOwner().Level.TimeSeconds;
						}
					}
					SelectionTime = GetPlayerOwner().Level.TimeSeconds; // delays the selection to prevent laggy scolling due to screenshot loading
				break;

				case MapStatus:
					MapListBox.SelectMap(MapStatusListItem(MapStatus.SelectedItem).MapName);
					if(GetPlayerOwner().Level.TimeSeconds > LastVoteTime - 1) // prevent spamming 5 (now on 1 by BT-GOD)
					{
						if(Left(UMenuMapVoteList(MapListBox.SelectedItem).MapName,3) != "[X]" || GetPlayerOwner().PlayerReplicationInfo.bAdmin)
						{
							GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE MAP "$UMenuMapVoteList(MapListBox.SelectedItem).MapName);
							LastVoteTime = GetPlayerOwner().Level.TimeSeconds;
						}
					}
					SelectionTime = GetPlayerOwner().Level.TimeSeconds;
				break;
			}
		break;

		case DE_Click:
			switch(C)
			{
				case CloseButton:
					ParentWindow.ParentWindow.Close();
				break;
				
				case SendButton:
					if(txtMessage.GetValue() != "")
					{
						GetPlayerOwner().ConsoleCommand("SAY "$ txtMessage.GetValue());
						txtMessage.SetValue("");
					}
				break;

				case FindMap:
					CountItems ++;
					if(CountItems > MapListBox.CountFindItems) CountItems = 1;  
						MapListBox.NextMap(CountItems);
				break;

				case PrevMap:
					CountItems--;
					if(CountItems < 1) CountItems = MapListBox.CountFindItems;
						MapListBox.NextMap(CountItems);
				break;

				case VoteButton:
					if(GetPlayerOwner().Level.TimeSeconds > LastVoteTime - 1) // prevent spamming 5 (now on 1 by BT-GOD)
					{
						if(Left(UMenuMapVoteList(MapListBox.SelectedItem).MapName,3) != "[X]" || GetPlayerOwner().PlayerReplicationInfo.bAdmin)
						{
							if(UMenuMapVoteList(MapListBox.SelectedItem).MapName != "")
								GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE MAP "$UMenuMapVoteList(MapListBox.SelectedItem).MapName);
							LastVoteTime = GetPlayerOwner().Level.TimeSeconds;
						}
					}
				break;

				case RandomButton:
					mapnum = Rand(MapListBox.Items.Count() + 1);
					if (mapnum == 0) { mapnum = 1; }
						MapListBox.SetMapByIndex(mapnum);
				break;

				case MapStatus:
					MapListBox.SelectMap(MapStatusListItem(MapStatus.SelectedItem).MapName);
					SelectionTime = GetPlayerOwner().Level.TimeSeconds;
				break;

				case MapListBox:
					SelectionTime = GetPlayerOwner().Level.TimeSeconds; // delays the selection to prevent laggy scolling due to screenshot loading
				break;
			}
		break;

		case DE_EnterPressed:
			switch (C) 
			{
				case txtMessage:
					if(txtMessage.GetValue() != "")
					{
						GetPlayerOwner().ConsoleCommand("SAY "$ txtMessage.GetValue());
						txtMessage.SetValue("");
						txtMessage.FocusOtherWindow(SendButton);
					}
				break;

				case txtFind:
					//if(ResultFind != "0")
					//	Self.ActiveWindow = MaplistBox;
					//else
						MapListBox.DoubleClickItem(MapListBox.SelectedItem);
				break;
			}
		break;

		case 14: //DE_WheelUpPressed: //EinputKey.IK_Up:
			switch (C) 
			{
				case txtFind:
					if(ResultFind != "0")
					{
						CountItems--;
						if(CountItems < 1) CountItems = MapListBox.CountFindItems;
						MapListBox.NextMap(CountItems);
					}
				break;
			}
		break;

		case 15: //DE_WheelDownPressed: //EinputKey.IK_Down:
			switch (C) 
			{
				case txtFind:
					if(ResultFind != "0")
					{
						CountItems ++;
						if(CountItems > MapListBox.CountFindItems) CountItems = 1;  
							MapListBox.NextMap(CountItems);  
					}
				break;
			}
		break;
/*
		case txtFind:
			if(Key == PP.EInputKey.IK_Right)
			{
				if(ResultFind != "0")
				{
					CountItems ++;
					if(CountItems > MapListBox.CountFindItems) CountItems = 1;
						MapListBox.NextMap(CountItems); 
				}
			}

			if(Key == PP.EInputKey.IK_Left)
			{
				if(ResultFind != "0")
				{
					CountItems--;
					if(CountItems < 1) CountItems = MapListBox.CountFindItems;
						MapListBox.NextMap(CountItems);
				}
			}
		break;
*/
	}
}

function tick(float DeltaTime)
{
	if(MapListBox.SelectedItem != None)
		CurrentMap = UMenuMapVoteList(MapListBox.SelectedItem).MapName; 
	else
		CurrentMap  = "No map selected";   

	super.tick(DeltaTime);
}

function Paint(Canvas C, float MouseX, float MouseY)
{
    local int i,p1,p2,pos;
    local string TempText,TextLine;
    local float X, Y, W, H;

    Super.Paint(C,MouseX,MouseY);

    DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');

	if (bGoldTheme)
	{
		// Draw BTMaplistLogo
		DrawStretchedTexture(C, 8,		8,		256,	32,		Texture'BTMaplistOrange');
		// Draw UT Logo
		DrawStretchedTexture(C, 275, 	92, 	655, 	246, 	Texture'UTorange');
		// Draw BT Logo
		DrawStretchedTexture(C, 273, 	432, 	256, 	256, 	Texture'BTorange');
		// BT MAPVOTE Logo etc
		DrawStretchedTexture(C, 273, 	696, 	64, 	16, 	Texture'TRIDENT1orange');
		DrawStretchedTexture(C, 465, 	696, 	64, 	16, 	Texture'TRIDENT2orange');
		DrawStretchedTexture(C, 337, 	696, 	128, 	16, 	Texture'MAPVOTEorange');
		DrawStretchedTexture(C, 273, 	688, 	2, 		15, 	Texture'BorderOrange'); // LEFT
		DrawStretchedTexture(C, 527, 	688, 	2, 		15, 	Texture'BorderOrange'); // RIGHT
		// BORDERS MAPLIST BOX
		DrawStretchedTexture(C, 8, 		8, 		2, 		680, 	Texture'BorderOrange'); // LEFT
		DrawStretchedTexture(C, 262, 	8, 		2, 		680, 	Texture'BorderOrange'); // RIGHT
		DrawStretchedTexture(C, 10, 	8, 		252,	2, 		Texture'BorderOrange'); // UP
		DrawStretchedTexture(C, 10, 	686, 	252, 	2, 		Texture'BorderOrange'); // DOWN
		// BORDERS UT LOGO BOX
		DrawStretchedTexture(C, 273, 	12, 	4, 		406, 	Texture'BorderOrange'); // LEFT
		DrawStretchedTexture(C, 928, 	12, 	4, 		406, 	Texture'BorderOrange'); // RIGHT
		DrawStretchedTexture(C, 273, 	8, 		659,	4, 		Texture'BorderOrange'); // UP
		DrawStretchedTexture(C, 273, 	418, 	659, 	4, 		Texture'BorderOrange'); // DOWN	
		// BORDERS VOTESTATUS + PLAYERLIST BOX
		DrawStretchedTexture(C, 539, 	498, 	2, 		190, 	Texture'BorderOrange'); // LEFT
		DrawStretchedTexture(C, 930, 	498, 	2, 		190, 	Texture'BorderOrange'); // RIGHT
		DrawStretchedTexture(C, 541, 	498, 	389,	2, 		Texture'BorderOrange'); // UP
		DrawStretchedTexture(C, 541, 	686, 	389, 	2, 		Texture'BorderOrange'); // DOWN
	}
	else
	{
		// Draw BTMaplistLogo
		DrawStretchedTexture(C, 8,		8,		256,	32,		Texture'BTMaplistBlue');
		// Draw UT Logo
		DrawStretchedTexture(C, 275, 	92, 	655, 	246, 	Texture'UTblue');
		// Draw BT Logo
		DrawStretchedTexture(C, 273, 	432, 	256, 	256, 	Texture'BTblue');
		// BT MAPVOTE Logo etc
		DrawStretchedTexture(C, 273, 	696, 	64, 	16, 	Texture'TRIDENT1blue');
		DrawStretchedTexture(C, 465, 	696, 	64, 	16, 	Texture'TRIDENT2blue');
		DrawStretchedTexture(C, 337, 	696, 	128, 	16, 	Texture'MAPVOTEblue');
		DrawStretchedTexture(C, 273, 	688, 	2, 		15, 	Texture'BorderBlue'); // LEFT
		DrawStretchedTexture(C, 527, 	688, 	2, 		15, 	Texture'BorderBlue'); // RIGHT
		// BORDERS MAPLIST BOX
		DrawStretchedTexture(C, 8, 		8, 		2, 		680, 	Texture'BorderBlue'); // LEFT
		DrawStretchedTexture(C, 262, 	8, 		2, 		680, 	Texture'BorderBlue'); // RIGHT
		DrawStretchedTexture(C, 10, 	8, 		252,	2, 		Texture'BorderBlue'); // UP
		DrawStretchedTexture(C, 10, 	686, 	252, 	2, 		Texture'BorderBlue'); // DOWN
		// BORDERS UT LOGO BOX
		DrawStretchedTexture(C, 273, 	12, 	4, 		406, 	Texture'BorderBlue'); // LEFT
		DrawStretchedTexture(C, 928, 	12, 	4, 		406, 	Texture'BorderBlue'); // RIGHT
		DrawStretchedTexture(C, 273, 	8, 		659,	4, 		Texture'BorderBlue'); // UP
		DrawStretchedTexture(C, 273, 	418, 	659, 	4, 		Texture'BorderBlue'); // DOWN
		// BORDERS VOTESTATUS + PLAYERLIST BOX
		DrawStretchedTexture(C, 539, 	498, 	2, 		190, 	Texture'BorderBlue'); // LEFT
		DrawStretchedTexture(C, 930, 	498, 	2, 		190, 	Texture'BorderBlue'); // RIGHT
		DrawStretchedTexture(C, 541, 	498, 	389,	2, 		Texture'BorderBlue'); // UP
		DrawStretchedTexture(C, 541, 	686, 	389, 	2, 		Texture'BorderBlue'); // DOWN
	}

    C.Font = Root.Fonts[F_Large];

	if (bGoldTheme)
	{
		if (CurrentMap != "")
		{
			if (CurrentMap=="")
			{ 
				C.DrawColor.R = 255;
				C.DrawColor.G = 115;
				C.DrawColor.B = 0;
			}
			else
			{
			   C.DrawColor.R = 255;
			   C.DrawColor.G = 115;
			   C.DrawColor.B = 0;
			}

			TextSize(C, CurrentMap, W, H);
			ClipText(C, 539, 428, CurrentMap);
		}

		C.Font = Root.Fonts[F_Normal];

		if (MapListBox.CountFindItems == 0)
		{
			ResultFind ="0";
			C.DrawColor.R = 255;
			C.DrawColor.G = 115;
			C.DrawColor.B = 0;
		}
		else if (len(txtFind.GetValue()) < 2)
		{
			ResultFind ="0";
			C.DrawColor.R = 255;
			C.DrawColor.G = 115;
			C.DrawColor.B = 0;
		}

		else if (MapListBox.CountFindItems > 0)
		{
			ResultFind = CountItems$"/"$string(MapListBox.CountFindItems);
			C.DrawColor.R = 255;
			C.DrawColor.G = 115;
			C.DrawColor.B = 0;
		}

		TextSize(C, ResultFind, W, H);
		ClipText(C, 775, 481, ResultFind);

		// Draw Status text
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
		C.Font = Root.Fonts[F_Normal];
	}
	else
	{
		if (CurrentMap != "")
		{
			if (CurrentMap=="")
			{ 
				C.DrawColor.R = 0;
				C.DrawColor.G = 140;
				C.DrawColor.B = 255;
			}
			else
			{
			   C.DrawColor.R = 0;
			   C.DrawColor.G = 140;
			   C.DrawColor.B = 255;
			}

			TextSize (C, CurrentMap, W, H);
			ClipText(C, 539, 428, CurrentMap);
		}

		C.Font = Root.Fonts[F_Normal];

		if (MapListBox.CountFindItems == 0)
		{
			ResultFind ="0";
			C.DrawColor.R = 0;
			C.DrawColor.G = 140;
			C.DrawColor.B = 255;
		}
		else if (len(txtFind.GetValue()) < 2)
		{
			ResultFind ="0";
			C.DrawColor.R = 0;
			C.DrawColor.G = 140;
			C.DrawColor.B = 255;
		}

		else if (MapListBox.CountFindItems > 0)
		{
			ResultFind = CountItems$"/"$string(MapListBox.CountFindItems);
			C.DrawColor.R = 0;
			C.DrawColor.G = 140;
			C.DrawColor.B = 255;
		}

		TextSize(C, ResultFind, W, H);
		ClipText(C, 775, 481, ResultFind);

		// Draw Status text
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
		C.Font = Root.Fonts[F_Normal];
	}
}

function KeyDown( int Key, float X, float Y )
{
	local PlayerPawn PP;

	PP = GetPlayerOwner();

	// ARROW RIGHT -> findnext
	if (Key == PP.EInputKey.IK_Right)
	{
		if(ResultFind != "0")
		{
			CountItems ++;
			if(CountItems > MapListBox.CountFindItems) CountItems = 1;  
				MapListBox.NextMap(CountItems); 
		}
	}

	// ARROW LEFT -> findprev
	if (Key == PP.EInputKey.IK_Left)
	{
		if(ResultFind != "0")
		{
			CountItems--;
			if(CountItems < 1) CountItems = MapListBox.CountFindItems;
				MapListBox.NextMap(CountItems);
		}
	}

	// ENTER -> Vote Map
	if (Key == PP.EInputKey.IK_Enter)
		MapListBox.DoubleClickItem(MapListBox.SelectedItem);

	// SHIFT -> type search text
	if (Key == PP.EInputKey.IK_Shift)
	{
		Self.ActiveWindow = txtFind;
	}

	// CTRL -> type search text
	if (Key == PP.EInputKey.IK_Ctrl)
	{
		Self.ActiveWindow = txtFind;
	}

	// TAB -> type msg text
	if (Key == PP.EInputKey.IK_Tab)
	{
		Self.ActiveWindow = txtMessage;
	}

//	// T -> type msg text
//	if(Key == PP.EInputKey.IK_T)
//	{
//		Self.ActiveWindow = txtMessage;
//	}

	if ((Key == PP.EInputKey.IK_A) || (Key == PP.EInputKey.IK_B) || (Key == PP.EInputKey.IK_C) || (Key == PP.EInputKey.IK_D) || (Key == PP.EInputKey.IK_E) || (Key == PP.EInputKey.IK_F) || (Key == PP.EInputKey.IK_G) || (Key == PP.EInputKey.IK_H) || (Key == PP.EInputKey.IK_I) || (Key == PP.EInputKey.IK_J) || (Key == PP.EInputKey.IK_K) || (Key == PP.EInputKey.IK_L) || (Key == PP.EInputKey.IK_M) || (Key == PP.EInputKey.IK_N) || (Key == PP.EInputKey.IK_O) || (Key == PP.EInputKey.IK_P) || (Key == PP.EInputKey.IK_Q) || (Key == PP.EInputKey.IK_R) || (Key == PP.EInputKey.IK_S) || (Key == PP.EInputKey.IK_T) || (Key == PP.EInputKey.IK_U) || (Key == PP.EInputKey.IK_V) || (Key == PP.EInputKey.IK_W) || (Key == PP.EInputKey.IK_X) || (Key == PP.EInputKey.IK_Y) || (Key == PP.EInputKey.IK_Z) || (Key == PP.EInputKey.IK_Space))
	{
		Self.ActiveWindow = txtFind;
	}

    ParentWindow.KeyDown(Key,X,Y);
}

function Close(optional bool bByParent)
{
    local int w, Mode;
    Super.Close(bByParent);
}