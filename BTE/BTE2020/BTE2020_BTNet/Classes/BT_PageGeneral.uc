//=============================================================================
// BT_PageGeneral made by OwYeaW
//=============================================================================
class BT_PageGeneral expands UWindowPageWindow;
//-----------------------------------------------------------------------------
var		BT_WRI						BTWRI;
var		ClientData					Config;
var		BTEClientData				BTEC;
//-----------------------------------------------------------------------------
var		bool						bInitialized;
var		Color						Basecolor;
//-----------------------------------------------------------------------------
//	Objects
//-----------------------------------------------------------------------------
var		UWindowCheckbox				AntiBoostCheck;
var		UWindowCheckbox				GhostsCheck;
var		UWindowCheckbox				BrightSkinsCheck;
var		UWindowCheckbox				ShowCollisionsCheck;
var		UWindowCheckbox				SpeedMeterCheck;
var		UWindowCheckbox				MuteAnnouncerAndHUDMessagesCheck;
var		UWindowCheckbox				BehindviewCrosshairCheck;
var		UWindowLabelControl			CrosshairScaleLabel;
var		BT_SliderControl			CrosshairScaleSlider;
//-----------------------------------------------------------------------------
var		UWindowLabelControl			Number1Label;
var		UWindowLabelControl			Number2Label;
var		UWindowLabelControl			Number3Label;
var		UWindowLabelControl			Number4Label;
var		UWindowLabelControl			Number5Label;
var		UWindowLabelControl			Number6Label;
var		UWindowLabelControl			Number7Label;
var		UWindowLabelControl			Number8Label;
//-----------------------------------------------------------------------------
var float ControlOffset, ControlOffsetSpace;
//-----------------------------------------------------------------------------
function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

//	1	==========================================
	Number1Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number1Label.SetText("1.");
	Number1Label.SetFont(F_Normal);
	Number1Label.SetTextColor(Basecolor);

	//	AntiBoost
	AntiBoostCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	AntiBoostCheck.SetText("Use AntiBoost");
	AntiBoostCheck.SetTextColor(Basecolor);
	AntiBoostCheck.SetFont(F_Normal);
	AntiBoostCheck.Align = TA_Left;

//	2	==========================================
	ControlOffset += ControlOffsetSpace;
//	2	==========================================
	Number2Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number2Label.SetText("2.");
	Number2Label.SetFont(F_Normal);
	Number2Label.SetTextColor(Basecolor);

	//	Ghosts
	GhostsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	GhostsCheck.SetText("Transparent Players");
	GhostsCheck.SetTextColor(Basecolor);
	GhostsCheck.SetFont(F_Normal);
	GhostsCheck.Align = TA_Left;

//	3	==========================================
	ControlOffset += ControlOffsetSpace;
//	3	==========================================
	Number3Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number3Label.SetText("3.");
	Number3Label.SetFont(F_Normal);
	Number3Label.SetTextColor(Basecolor);

	//	Show BrightSkins
	BrightSkinsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	BrightSkinsCheck.SetText("BrightSkins");
	BrightSkinsCheck.SetTextColor(Basecolor);
	BrightSkinsCheck.SetFont(F_Normal);
	BrightSkinsCheck.Align = TA_Left;

//	4	==========================================
	ControlOffset += ControlOffsetSpace;
//	4	==========================================
	Number4Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number4Label.SetText("4.");
	Number4Label.SetFont(F_Normal);
	Number4Label.SetTextColor(Basecolor);

	//	ShowCollisions
	ShowCollisionsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	ShowCollisionsCheck.SetText("Show Collisions");
	ShowCollisionsCheck.SetTextColor(Basecolor);
	ShowCollisionsCheck.SetFont(F_Normal);
	ShowCollisionsCheck.Align = TA_Left;

//	5	==========================================
	ControlOffset += ControlOffsetSpace;
//	5	==========================================
	Number5Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number5Label.SetText("5.");
	Number5Label.SetFont(F_Normal);
	Number5Label.SetTextColor(Basecolor);

	//	SpeedMeter
	SpeedMeterCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	SpeedMeterCheck.SetText("Show Speed Meter");
	SpeedMeterCheck.SetTextColor(Basecolor);
	SpeedMeterCheck.SetFont(F_Normal);
	SpeedMeterCheck.Align = TA_Left;

//	6	==========================================
	ControlOffset += ControlOffsetSpace;
//	6	==========================================
	Number6Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number6Label.SetText("6.");
	Number6Label.SetFont(F_Normal);
	Number6Label.SetTextColor(Basecolor);

	//	MuteAnnouncerAndHUDMessages
	MuteAnnouncerAndHUDMessagesCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	MuteAnnouncerAndHUDMessagesCheck.SetText("Mute Announcer and HUD Messages");
	MuteAnnouncerAndHUDMessagesCheck.SetTextColor(Basecolor);
	MuteAnnouncerAndHUDMessagesCheck.SetFont(F_Normal);
	MuteAnnouncerAndHUDMessagesCheck.Align = TA_Left;

//	7	==========================================
	ControlOffset += ControlOffsetSpace;
//	7	==========================================
	Number7Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number7Label.SetText("7.");
	Number7Label.SetFont(F_Normal);
	Number7Label.SetTextColor(Basecolor);

	//	BehindviewCrosshair
	BehindviewCrosshairCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	BehindviewCrosshairCheck.SetText("Use Behindview Crosshair");
	BehindviewCrosshairCheck.SetTextColor(Basecolor);
	BehindviewCrosshairCheck.SetFont(F_Normal);
	BehindviewCrosshairCheck.Align = TA_Left;

//	8	==========================================
	ControlOffset += ControlOffsetSpace;
//	8	==========================================
	Number8Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number8Label.SetText("8.");
	Number8Label.SetFont(F_Normal);
	Number8Label.SetTextColor(Basecolor);

	//	CrosshairScaleLabel
	CrosshairScaleLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos, ControlOffset+2, CenterWidth, 1));
	CrosshairScaleLabel.SetText("Crosshair");
	CrosshairScaleLabel.SetFont(F_Normal);
	CrosshairScaleLabel.SetTextColor(Basecolor);

	//	CrosshairScaleSlider
	CrosshairScaleSlider = BT_SliderControl(CreateControl(class'BT_SliderControl', CenterPos, ControlOffset+2, CenterWidth, 1));
	CrosshairScaleSlider.SetRange(0, 10, 0);
	CrosshairScaleSlider.SetTextColor(Basecolor);
	CrosshairScaleSlider.SetFont(F_Normal);
	CrosshairScaleSlider.Align = TA_Right;
}

function LoadSettings()
{
	local float S;

	bInitialized = false;

	AntiBoostCheck.bChecked = Config.bAntiBoost;
	GhostsCheck.bChecked = BTEC.Ghosts;
	BrightSkinsCheck.bChecked = BTEC.BrightSkins;
	ShowCollisionsCheck.bChecked = BTEC.ShowCollisions;
	SpeedMeterCheck.bChecked = BTEC.ShowSpeedMeter;
	MuteAnnouncerAndHUDMessagesCheck.bChecked = BTEC.MuteAnnouncerAndHUDMessages;
	BehindviewCrosshairCheck.bChecked = BTEC.BehindviewCrosshair;

	CrosshairScaleSlider.SetValue(BTEC.CrosshairScale);
	S = CrosshairScaleSlider.Value * 100;
	CrosshairScaleSlider.SetText("[" $ int(S) $ "%]");

	bInitialized = true;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	
	if(bInitialized)
	{
		switch(E)
		{
			case DE_Change:
				switch(C)
				{
					case AntiBoostCheck:
						AntiBoostChanged();
					break;

					case GhostsCheck:
						GhostsChanged();
					break;

					case BrightSkinsCheck:
						BrightSkinsChanged();
					break;

					case ShowCollisionsCheck:
						ShowCollisionsChanged();
					break;

					case SpeedMeterCheck:
						SpeedMeterChanged();
					break;

					case MuteAnnouncerAndHUDMessagesCheck:
						MuteAnnouncerAndHUDMessagesChanged();
					break;
					
					case BehindviewCrosshairCheck:
						BehindviewCrosshairChanged();
					break;

					case CrosshairScaleSlider:
						CrosshairScaleChanged();
					break;
				}
			break;
		}
	}
}

function AntiBoostChanged()
{
	BTWRI.AntiBoost(Config, AntiBoostCheck.bChecked);
}

function GhostsChanged()
{
	local TournamentPlayer TP;

	foreach GetLevel().AllActors(class'TournamentPlayer', TP)
	{
		TP.Style = STY_Normal;
		if (TP.Weapon != None)
			TP.Weapon.Style = STY_Normal;
	}
	BTEC.SwitchBool("Ghosts");
}

function BrightSkinsChanged()
{
	local Pawn xPawn, P;
	local BT_PRI BTPRI;

	if(!BrightSkinsCheck.bChecked)
	{
		foreach GetLevel().AllActors(class'BT_PRI', BTPRI)
		{
			P = Pawn(BTPRI.Owner);

			P.bUnlit = false;
			P.static.SetMultiSkin(P, BTPRI.DefaultSkin, BTPRI.DefaultFace, P.PlayerReplicationInfo.Team);

			if(BTPRI.DefaultSkin == "FCommandoSkins.aphe") // aphex skins need some special treatment, gj epic
			{
				if(BTPRI.DefaultFace == "FCommandoSkins.Indina")
					P.MultiSkins[3] = Texture(DynamicLoadObject("FCommandoSkins.aphe4Indina", class'Texture'));
				else if(BTPRI.DefaultFace == "FCommandoSkins.Portia")
					P.MultiSkins[3] = Texture(DynamicLoadObject("FCommandoSkins.aphe4Portia", class'Texture'));
			}
			if(P.Weapon != None)
			{
				P.Weapon.bUnlit = false;
				P.Weapon.MultiSkins[0] = P.Weapon.default.MultiSkins[0];
				P.Weapon.MultiSkins[1] = P.Weapon.default.MultiSkins[1];
				P.Weapon.MultiSkins[2] = P.Weapon.default.MultiSkins[2];
				P.Weapon.MultiSkins[3] = P.Weapon.default.MultiSkins[3];
				P.Weapon.MultiSkins[4] = P.Weapon.default.MultiSkins[4];
				P.Weapon.MultiSkins[5] = P.Weapon.default.MultiSkins[5];
				P.Weapon.MultiSkins[6] = P.Weapon.default.MultiSkins[6];
				P.Weapon.MultiSkins[7] = P.Weapon.default.MultiSkins[7];
			}
		}
	}

	BTEC.SwitchBool("BrightSkins");
}

function ShowCollisionsChanged()
{
	local BT_CollisionActor CA;

	BTEC.SwitchBool("ShowCollisions");

	if(!ShowCollisionsCheck.bChecked)
		Foreach GetLevel().AllActors(class'BT_CollisionActor', CA)
			if(!CA.IsA('BT_CollisionPawn'))
				CA.Destroy();
}

function SpeedMeterChanged()
{
	BTEC.SwitchBool("ShowSpeedMeter");
}

function MuteAnnouncerAndHUDMessagesChanged()
{
	BTEC.SwitchBool("MuteAnnouncerAndHUDMessages");
}

function BehindviewCrosshairChanged()
{
	BTEC.SwitchBool("BehindviewCrosshair");
}

function CrosshairScaleChanged()
{
	local float S;

	BTEC.FloatSetting("CrosshairScale", CrosshairScaleSlider.Value);

	S = CrosshairScaleSlider.Value * 100;
	CrosshairScaleSlider.SetText("[" $ int(S) $ "%]");
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	Super.Paint(C, MouseX, MouseY);
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BT_GreyBackground');
}

defaultproperties
{
	ControlOffset=8
	ControlOffsetSpace=22
	Basecolor=(R=255,G=255,B=255)
}