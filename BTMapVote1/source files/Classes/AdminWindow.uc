//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class AdminWindow expands UWindowPageWindow;

var 	UWindowCheckBox   		cbLoadBT;         	// Bunny Track
var 	UWindowCheckBox   		cbLoadCTF;        	// Capture The Flag
var 	UWindowCheckBox   		cbLoadFromCache;  	// использовать кеширование списка карт
var 	UWindowCheckBox   		cbLoadOther;      	// Other Custom Game Type
var 	UWindowCheckBox   		cbAutoDetect;     	// Automatically sets the game type
var 	UWindowCheckBox   		cbCheckOtherGameTie;
var 	UWindowSmallButton 		RemoteSaveButton;
var 	UWindowSmallButton 		ReloadMapsButton;
var 	UWindowSmallButton 		CloseButton;
var		UWindowEditControl 		txtOtherClass;
var 	UWindowEditControl 		txtMapPreFixOverRide;
var 	UWindowHSliderControl 	sldVoteTimeLimit;
var 	UMenuLabelControl 		lblVoteTimeLimit;
var 	UWindowEditControl 		txtRepeatLimit;
var 	UWindowEditControl 		txtMinMapCount;
var 	UWindowHSliderControl 	sldMidGameVotePercent;
var 	UWindowComboControl 	cboMode;

var 	UWindowEditControl 		txtServerInfoURL;
var 	UWindowEditControl 		txtMapInfoURL;
var 	UWindowComboControl 	cboMapVoteHistoryType;
var 	UWindowComboControl 	cboHasStartWindow;

var 	UMenuLabelControl 		lblMidGameVotePercent;
var 	UMenuLabelControl 		lblGameTypeSection;
var 	UMenuLabelControl 		lblMiscSection;
var 	UMenuLabelControl 		lblOtherClass;
var 	UMenuLabelControl 		lblLimitsLabel;
var 	UMenuLabelControl 		lblMapPreFixOverRide;
var 	UMenuLabelControl 		lblRepeatLimit;
var 	UMenuLabelControl 		lblMinMapCount;
var 	UMenuLabelControl 		lblAdvancedSection;
var 	UMenuLabelControl 		lblServerInfoURL;
var 	UMenuLabelControl 		lblMapInfoURL;
var 	UMenuLabelControl 		lblBTGODMapvote;

var 	UWindowCheckBox   		cbUseMapList;
var 	UWindowCheckBox   		cbAutoOpen;
var 	UWindowCheckBox   		cbEntryWindows;
var 	UWindowHSliderControl 	sldScoreBoardDelay;
var 	UMenuLabelControl 		lblScoreBoardDelay;

var 	UWindowEditControl 		txtPreFixSwap;
var 	UWindowCheckBox    		cbSortWithPreFix;

var		bool					bGoldTheme;

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

	// SHIZZLE 										BT-GODЩ										X		Y		Width	Height

	lblGameTypeSection = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 				549, 	438, 	90, 	20));
	lblGameTypeSection.SetText("Game Type:");
	if (bGoldTheme)
		lblGameTypeSection.SetTextColor(TextColor);
	else
		lblGameTypeSection.SetTextColor(TextColor2);

	cbLoadBT = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 							549, 	458, 	60, 	20));
	cbLoadBT.SetText("BT");
	cbLoadBT.SetFont(F_Normal);
	cbLoadBT.Align = TA_Left;
	cbLoadBT.SetSize(80, 1);
	if (bGoldTheme)
		cbLoadBT.SetTextColor(TextColor);
	else
		cbLoadBT.SetTextColor(TextColor2);

	cbLoadCTF = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 							549, 	478, 	60, 	20));
	cbLoadCTF.SetText("CTF");
	cbLoadCTF.SetFont(F_Normal);
	cbLoadCTF.Align = TA_Left;
	cbLoadCTF.SetSize(80, 1);
	if (bGoldTheme)
		cbLoadCTF.SetTextColor(TextColor);
	else
		cbLoadCTF.SetTextColor(TextColor2);

	cbAutoDetect = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 						549, 	498, 	60, 	20));
	cbAutoDetect.SetText("Auto Detect");
	cbAutoDetect.SetFont(F_Normal);
	cbAutoDetect.Align = TA_Left;
	cbAutoDetect.SetSize(80, 1);
	cbAutoDetect.bAcceptsFocus = False;
	if (bGoldTheme)
		cbAutoDetect.SetTextColor(TextColor);
	else
		cbAutoDetect.SetTextColor(TextColor2);

	cbLoadOther = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 						549, 	518, 	80, 	20));
	cbLoadOther.SetText("Other (MODs)");
	cbLoadOther.SetFont(F_Normal);
	cbLoadOther.Align = TA_Left;
	cbLoadOther.SetSize(80, 1);
	if (bGoldTheme)
		cbLoadOther.SetTextColor(TextColor);
	else
		cbLoadOther.SetTextColor(TextColor2);

	lblOtherClass = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 					549, 	538, 	150, 	20));
	lblOtherClass.SetText("Other Game Package.GameClass ");
	if (bGoldTheme)
		lblOtherClass.SetTextColor(TextColor);
	else
		lblOtherClass.SetTextColor(TextColor2);

	txtOtherClass = UWindowEditControl(CreateControl(class'UWindowEditControl', 				549, 	553, 	150, 	20));
	txtOtherClass.SetNumericOnly(false);
	txtOtherClass.EditBoxWidth = 150;

//-----------------------------------------------------------------------------
	
	sldVoteTimeLimit = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 		549, 	582, 	170, 	20));
	sldVoteTimeLimit.bAcceptsFocus = False;
	sldVoteTimeLimit.MinValue = 20;
	sldVoteTimeLimit.MaxValue = 180;
	sldVoteTimeLimit.Step = 10;
	sldVoteTimeLimit.SetText("Voting Time Limit");
	sldVoteTimeLimit.SetSize(230, 1);
	if (bGoldTheme)
		sldVoteTimeLimit.SetTextColor(TextColor);
	else
		sldVoteTimeLimit.SetTextColor(TextColor2);

	lblVoteTimeLimit = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 				786, 	582, 	40, 	20));
	lblVoteTimeLimit.SetText(String(int(sldVoteTimeLimit.Value)) $ " seconds");
	if (bGoldTheme)
		lblVoteTimeLimit.SetTextColor(TextColor);
	else
		lblVoteTimeLimit.SetTextColor(TextColor2);

	sldScoreBoardDelay = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 		549, 	602, 	180, 	20));
	sldScoreBoardDelay.MinValue = 1;
	sldScoreBoardDelay.MaxValue = 30;
	sldScoreBoardDelay.Step = 1;
	sldScoreBoardDelay.SetText("ScoreBoard Delay");
	sldScoreBoardDelay.SetSize(230, 1);
	if (bGoldTheme)
		sldScoreBoardDelay.SetTextColor(TextColor);
	else
		sldScoreBoardDelay.SetTextColor(TextColor2);

	lblScoreBoardDelay = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 				786, 	602, 	40, 	20));
	lblScoreBoardDelay.SetText(String(int(sldScoreBoardDelay.Value)) $ " seconds");
	if (bGoldTheme)
		lblScoreBoardDelay.SetTextColor(TextColor);
	else
		lblScoreBoardDelay.SetTextColor(TextColor2);

	sldMidGameVotePercent = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 	549, 	622, 	185, 	20));
	sldMidGameVotePercent.MinValue = 1;
	sldMidGameVotePercent.MaxValue = 100;
	sldMidGameVotePercent.Step = 1;
	sldMidGameVotePercent.SetText("Mid-Game Vote Requirement");
	sldMidGameVotePercent.SetSize(230, 1);
	if (bGoldTheme)
		sldMidGameVotePercent.SetTextColor(TextColor);
	else
		sldMidGameVotePercent.SetTextColor(TextColor2);

	lblMidGameVotePercent = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 			786, 	622, 	40, 	20));
	lblMidGameVotePercent.SetText(String(int(sldMidGameVotePercent.Value)) $ " %");
	if (bGoldTheme)
		lblMidGameVotePercent.SetTextColor(TextColor);
	else
		lblMidGameVotePercent.SetTextColor(TextColor2);

//-----------------------------------------------------------------------------	

	txtRepeatLimit = UWindowEditControl(CreateControl(class'UWindowEditControl', 				549, 	646, 	95, 	20));
	txtRepeatLimit.SetNumericOnly(true);
	txtRepeatLimit.SetText("Don't Show Last");
	txtRepeatLimit.EditBoxWidth = 20;
	if (bGoldTheme)
		txtRepeatLimit.SetTextColor(TextColor);
	else
		txtRepeatLimit.SetTextColor(TextColor2);

	lblRepeatLimit = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 					649, 	648, 	60, 	20));
	lblRepeatLimit.SetText("maps Played");
	if (bGoldTheme)
		lblRepeatLimit.SetTextColor(TextColor);
	else
		lblRepeatLimit.SetTextColor(TextColor2);

	cbAutoOpen = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 							549, 	668, 	300, 	20));
	cbAutoOpen.SetText("Open Voting Window at Game End");
	cbAutoOpen.SetFont(F_Normal);
	cbAutoOpen.Align = TA_Right;
	cbAutoOpen.SetSize(175, 1);
	if (bGoldTheme)
		cbAutoOpen.SetTextColor(TextColor);
	else
		cbAutoOpen.SetTextColor(TextColor2);

//-----------------------------------------------------------------------------

  	// lblBTGODMapvote
	lblBTGODMapvote = UMenuLabelControl(CreateControl(class'UMenuLabelControl',					361,	698,	250,	20));
	lblBTGODMapvote.SetText("BT-GOD MapVote");
	if (bGoldTheme)
		lblBTGODMapvote.SetTextColor(TextColor);
	else
		lblBTGODMapvote.SetTextColor(TextColor2);

	RemoteSaveButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 				539, 	696, 	193, 	20));
	RemoteSaveButton.Text= "Save";
	RemoteSaveButton.DownSound = sound 'Botpack.Click';
	RemoteSaveButton.bDisabled = false;	

	CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 					739,	696,	193,	20));
	CloseButton.DownSound = sound 'Botpack.Click';
	CloseButton.Text= "Close";
	CloseButton.bDisabled = false;
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
					ParentWindow.ParentWindow.ParentWindow.Close();
				break;

				case RemoteSaveButton:
					GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote bBT "                $ string(cbLoadBT.bChecked));
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote bCTF "               $ string(cbLoadCTF.bChecked));
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote bOther "             $ string(cbLoadOther.bChecked));
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote OtherClass "         $ txtOtherClass.GetValue());
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote VoteTimeLimit "      $ string(int(sldVoteTimeLimit.Value)));
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote bUseMapList "        $ string(cbUseMapList.bChecked));
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote bAutoOpen "          $ string(cbAutoOpen.bChecked));
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote ScoreBoardDelay "    $ string(int(sldScoreBoardDelay.Value)));
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote bAutoDetect "        $ string(cbAutoDetect.bChecked));
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote bCheckOtherGameTie " $ string(cbCheckOtherGameTie.bChecked));
           			//GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote RepeatLimit "        $ txtRepeatLimit.GetValue());
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote MapVoteHistoryType " $ cboMapVoteHistoryType.GetValue());
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote MidGameVotePercent " $ string(int(sldMidGameVotePercent.Value)));
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote MapPreFixOverRide "  $ txtMapPreFixOverRide.GetValue());
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote PreFixSwap "         $ txtPreFixSwap.GetValue());
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote bSortWithPreFix "    $ string(cbSortWithPreFix.bChecked));
           			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote UseCache "           $ string(cbLoadFromCache.bChecked));
				break;

				case ReloadMapsButton:
					GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE RELOADMAPS");
					ParentWindow.ParentWindow.ParentWindow.Close();
				break;

				case cbLoadBT:
					if (cbLoadBT.bChecked)
						cbAutoDetect.bChecked = false;
				break;

				case cbLoadCTF:
					if (cbLoadCTF.bChecked)
						cbAutoDetect.bChecked = false;
				break;

				case cbLoadOther:
					if (cbLoadOther.bChecked)
						cbAutoDetect.bChecked = false;
				break;

				case cbAutoDetect:
					if(cbAutoDetect.bChecked)
					{
						cbLoadBT.bChecked = false;
						cbLoadCTF.bChecked = false;
						cbLoadOther.bChecked = false;
					}
				break;
			}
		break;

		case DE_Change:
			switch(C)
			{
				case sldVoteTimeLimit:
					lblVoteTimeLimit.SetText(String(int(sldVoteTimeLimit.Value)) $ " sec");
				break;

				case sldScoreBoardDelay:
					lblScoreBoardDelay.SetText(String(int(sldScoreBoardDelay.Value)) $ " sec");
				break;

				case sldMidGameVotePercent:
					lblMidGameVotePercent.SetText(String(int(sldMidGameVotePercent.Value)) $ " %");
				break;
			}
		break;
	}
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	Super.Paint(C, MouseX, MouseY);

	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');

	if (bGoldTheme)
	{
		// Draw UT Logo
		DrawStretchedTexture(C, 275, 	92, 	655, 	246, 	Texture'UTorange');
		// Draw BT Logo
		DrawStretchedTexture(C, 273, 	432, 	256, 	256, 	Texture'BTorange');
		// Draw Thunder
		DrawStretchedTexture(C, 56, 	35, 	160, 	700, 	Texture'ThunderOrange');
		//BORDERS UT LOGO BOX
		DrawStretchedTexture(C, 273, 	8, 		2, 		414, 	Texture'BorderOrange'); // LEFT
		DrawStretchedTexture(C, 930, 	8, 		2, 		414, 	Texture'BorderOrange'); // RIGHT
		DrawStretchedTexture(C, 275, 	8, 		655,	2, 		Texture'BorderOrange'); // UP
		DrawStretchedTexture(C, 275, 	420, 	655, 	2, 		Texture'BorderOrange'); // DOWN
		//ADMIN SHIZZLE
		DrawStretchedTexture(C, 539, 	432,  	391,  	2, 		Texture'BorderOrange'); //1st line
		DrawStretchedTexture(C, 539, 	575, 	391, 	2, 		Texture'BorderOrange');	//2nd line
		DrawStretchedTexture(C, 539, 	639, 	391, 	2, 		Texture'BorderOrange'); //3rd line
		DrawStretchedTexture(C, 539, 	686, 	391, 	2, 		Texture'BorderOrange'); //4th line
		DrawStretchedTexture(C, 930, 	432, 	2, 		256, 	Texture'BorderOrange'); //right line
		DrawStretchedTexture(C, 539, 	432, 	2, 		256, 	Texture'BorderOrange');	//left line
	}
	else
	{
		// Draw UT Logo
		DrawStretchedTexture(C, 275, 	92, 	655, 	246, 	Texture'UTblue');
		// Draw BT Logo
		DrawStretchedTexture(C, 273, 	432, 	256, 	256, 	Texture'BTblue');
		// Draw Thunder
		DrawStretchedTexture(C, 56, 	35, 	160, 	700, 	Texture'ThunderBlue');
		//BORDERS UT LOGO BOX
		DrawStretchedTexture(C, 273, 	8, 		2, 		414, 	Texture'BorderBlue'); // LEFT
		DrawStretchedTexture(C, 930, 	8, 		2, 		414, 	Texture'BorderBlue'); // RIGHT
		DrawStretchedTexture(C, 275, 	8, 		655,	2, 		Texture'BorderBlue'); // UP
		DrawStretchedTexture(C, 275, 	420, 	655, 	2, 		Texture'BorderBlue'); // DOWN
		//ADMIN SHIZZLE
		DrawStretchedTexture(C, 539, 	432,  	391, 	2, 		Texture'BorderBlue'); //1st line
		DrawStretchedTexture(C, 539, 	575, 	391, 	2, 		Texture'BorderBlue'); //2nd line
		DrawStretchedTexture(C, 539, 	639, 	391, 	2, 		Texture'BorderBlue'); //3rd line
		DrawStretchedTexture(C, 539, 	686, 	391, 	2, 		Texture'BorderBlue'); //4th line
		DrawStretchedTexture(C, 930, 	432, 	2, 		256, 	Texture'BorderBlue'); //right line
		DrawStretchedTexture(C, 539, 	432, 	2, 		256, 	Texture'BorderBlue'); //left line
	}
}