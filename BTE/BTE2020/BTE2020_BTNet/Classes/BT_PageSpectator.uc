//=============================================================================
// BT_PageSpectator made by OwYeaW
//=============================================================================
class BT_PageSpectator expands UWindowPageWindow;
//-----------------------------------------------------------------------------
var		BTEClientData				BTEC;
//-----------------------------------------------------------------------------
var		bool						bInitialized;
var		Color						Basecolor;
//-----------------------------------------------------------------------------
//	Objects
//-----------------------------------------------------------------------------
var		UWindowCheckbox				GhostSpectatorCheck;
var		UWindowCheckbox				UseTeleportersCheck;
var		UWindowCheckbox				PlayerCollisionsCheck;
var		UWindowCheckbox				WallHackCheck;
var		UWindowCheckbox				MuteTauntsCheck;
var		UWindowCheckbox				FollowViewRotationCheck;
var		UWindowLabelControl			BehindviewDistanceLabel;
var		BT_SliderControl			BehindviewDistanceSlider;
var		UWindowLabelControl			SpectatorSpeedLabel;
var		BT_SliderControl			SpectatorSpeedSlider;
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
	Number1Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, CenterWidth, 1));
	Number1Label.SetText("1.");
	Number1Label.SetFont(F_Normal);
	Number1Label.SetTextColor(Basecolor);

	//	GhostSpec
	GhostSpectatorCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	GhostSpectatorCheck.SetText("Ghost Spectator");
	GhostSpectatorCheck.SetTextColor(Basecolor);
	GhostSpectatorCheck.SetFont(F_Normal);
	GhostSpectatorCheck.Align = TA_Left;

//	2	==========================================
	ControlOffset += ControlOffsetSpace;
//	2	==========================================
	Number2Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number2Label.SetText("2.");
	Number2Label.SetFont(F_Normal);
	Number2Label.SetTextColor(Basecolor);

	//	UseTeleporters
	UseTeleportersCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	UseTeleportersCheck.SetText("Use Teleporters");
	UseTeleportersCheck.SetTextColor(Basecolor);
	UseTeleportersCheck.SetFont(F_Normal);
	UseTeleportersCheck.Align = TA_Left;

//	3	==========================================
	ControlOffset += ControlOffsetSpace;
//	3	==========================================
	Number3Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number3Label.SetText("3.");
	Number3Label.SetFont(F_Normal);
	Number3Label.SetTextColor(Basecolor);

	//	ShowPlayerCollisions
	PlayerCollisionsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	PlayerCollisionsCheck.SetText("Show Player Collisions");
	PlayerCollisionsCheck.SetTextColor(Basecolor);
	PlayerCollisionsCheck.SetFont(F_Normal);
	PlayerCollisionsCheck.Align = TA_Left;

//	4	==========================================
	ControlOffset += ControlOffsetSpace;
//	4	==========================================
	Number4Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number4Label.SetText("4.");
	Number4Label.SetFont(F_Normal);
	Number4Label.SetTextColor(Basecolor);

	//	Wallhack
	WallHackCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	WallHackCheck.SetText("Wallhack");
	WallHackCheck.SetTextColor(Basecolor);
	WallHackCheck.SetFont(F_Normal);
	WallHackCheck.Align = TA_Left;

//	5	==========================================
	ControlOffset += ControlOffsetSpace;
//	5	==========================================
	Number5Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number5Label.SetText("5.");
	Number5Label.SetFont(F_Normal);
	Number5Label.SetTextColor(Basecolor);

	//	MuteTaunts
	MuteTauntsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	MuteTauntsCheck.SetText("Mute Taunts");
	MuteTauntsCheck.SetTextColor(Basecolor);
	MuteTauntsCheck.SetFont(F_Normal);
	MuteTauntsCheck.Align = TA_Left;

//	6	==========================================
	ControlOffset += ControlOffsetSpace;
//	6	==========================================
	Number6Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number6Label.SetText("6.");
	Number6Label.SetFont(F_Normal);
	Number6Label.SetTextColor(Basecolor);

	//	FollowViewRotation
	FollowViewRotationCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	FollowViewRotationCheck.SetText("Follow Viewrotation in Behindview");
	FollowViewRotationCheck.SetTextColor(Basecolor);
	FollowViewRotationCheck.SetFont(F_Normal);
	FollowViewRotationCheck.Align = TA_Left;

//	7	==========================================
	ControlOffset += ControlOffsetSpace;
//	7	==========================================
	Number7Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number7Label.SetText("7.");
	Number7Label.SetFont(F_Normal);
	Number7Label.SetTextColor(Basecolor);

	//	BehindviewDistanceLabel
	BehindviewDistanceLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos, ControlOffset+2, CenterWidth, 1));
	BehindviewDistanceLabel.SetText("Behindview");
	BehindviewDistanceLabel.SetFont(F_Normal);
	BehindviewDistanceLabel.SetTextColor(Basecolor);

	//	BehindviewDistance
	BehindviewDistanceSlider = BT_SliderControl(CreateControl(class'BT_SliderControl', CenterPos, ControlOffset+2, CenterWidth, 1));
	BehindviewDistanceSlider.SetRange(0, 4500, 1);
	BehindviewDistanceSlider.SetTextColor(Basecolor);
	BehindviewDistanceSlider.SetFont(F_Normal);
	BehindviewDistanceSlider.Align = TA_Right;

//	8	==========================================
	ControlOffset += ControlOffsetSpace;
//	8	==========================================
	Number8Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos-25, ControlOffset+2, 10, 1));
	Number8Label.SetText("8.");
	Number8Label.SetFont(F_Normal);
	Number8Label.SetTextColor(Basecolor);

	//	SpectatorSpeedLabel
	SpectatorSpeedLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos, ControlOffset+2, CenterWidth, 1));
	SpectatorSpeedLabel.SetText("Fly Speed");
	SpectatorSpeedLabel.SetFont(F_Normal);
	SpectatorSpeedLabel.SetTextColor(Basecolor);

	//	SpectatorSpeedSlider
	SpectatorSpeedSlider = BT_SliderControl(CreateControl(class'BT_SliderControl', CenterPos, ControlOffset+2, CenterWidth, 1));
	SpectatorSpeedSlider.SetRange(0, 15000, 1);
	SpectatorSpeedSlider.SetTextColor(Basecolor);
	SpectatorSpeedSlider.SetFont(F_Normal);
	SpectatorSpeedSlider.Align = TA_Right;
}

function LoadSettings()
{
	local float S;

	bInitialized = false;

	GhostSpectatorCheck.bChecked = BTEC.GhostSpectator;
	UseTeleportersCheck.bChecked = BTEC.UseTeleporters;
	PlayerCollisionsCheck.bChecked = BTEC.ShowPlayerCollisions;
	WallHackCheck.bChecked = BTEC.WallHack;
	MuteTauntsCheck.bChecked = BTEC.MuteTaunts;
	FollowViewRotationCheck.bChecked = BTEC.FollowViewRotation;

	BehindviewDistanceSlider.SetValue(BTEC.BehindviewDistance);
	S = (BehindviewDistanceSlider.Value / 180) * 100;
	BehindviewDistanceSlider.SetText("[" $ int(S) $ "%]");

	SpectatorSpeedSlider.SetValue(BTEC.SpectatorSpeed);
	S = (SpectatorSpeedSlider.Value / 300) * 100;
	SpectatorSpeedSlider.SetText("[" $ int(S) $ "%]");

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
					case GhostSpectatorCheck:
						GhostSpectatorChanged();
					break;

					case UseTeleportersCheck:
						UseTeleportersChanged();
					break;

					case PlayerCollisionsCheck:
						PlayerCollisionsChanged();
					break;

					case WallHackCheck:
						WallHackChanged();
					break;

					case MuteTauntsCheck:
						MuteTauntsChanged();
					break;

					case FollowViewRotationCheck:
						FollowViewRotationChanged();
					break;

					case SpectatorSpeedSlider:
						SpectatorSpeedChanged();
					break;

					case BehindviewDistanceSlider:
						BehindviewDistanceChanged();
					break;
				}
			break;
		}
	}
}

function GhostSpectatorChanged()
{
	local BT_Spectator BTSpec;

	BTSpec = BT_Spectator(GetPlayerOwner());
	if(BTSpec != None)
	{
		BTSpec.bCollideWorld = !GhostSpectatorCheck.bChecked;
		BTSpec.bGhostSpectator = GhostSpectatorCheck.bChecked;
	}
	BTEC.SwitchBool("GhostSpectator");
}

function UseTeleportersChanged()
{
	BTEC.SwitchBool("UseTeleporters");
}

function PlayerCollisionsChanged()
{
	local BT_CollisionPawn CP;

	BTEC.SwitchBool("ShowPlayerCollisions");

	if(!PlayerCollisionsCheck.bChecked)
	{
		Foreach GetLevel().AllActors(class'BT_CollisionPawn', CP)
		{
			CP.Destroy();
			CP.myPawn.bSpecialLit = false;
		}
	}
}

function WallHackChanged()
{
	local BT_CollisionPawn CP;

	BTEC.SwitchBool("WallHack");

	if(!WallHackCheck.bChecked)
		Foreach GetLevel().AllActors(class'BT_CollisionPawn', CP)
			CP.bWallhack = false;
}

function MuteTauntsChanged()
{
	BTEC.SwitchBool("MuteTaunts");
}

function FollowViewRotationChanged()
{
	BTEC.SwitchBool("FollowViewRotation");
}

function BehindviewDistanceChanged()
{
	local float S;
	BTEC.IntSetting("BehindViewDistance", BehindviewDistanceSlider.Value);

	if(BT_Spectator(GetPlayerOwner()) != None)
		BT_Spectator(GetPlayerOwner()).BehindViewDistance = BehindviewDistanceSlider.Value;

	S = (BehindviewDistanceSlider.Value / 180) * 100;
	BehindviewDistanceSlider.SetText("[" $ int(S) $ "%]");
}

function SpectatorSpeedChanged()
{
	local float S;
	local BT_Spectator BTSpec;
	BTEC.IntSetting("SpectatorSpeed", SpectatorSpeedSlider.Value);

	BTSpec = BT_Spectator(GetPlayerOwner());
	if(BTSpec != None)
		BTSpec.SpectatorSpeed = SpectatorSpeedSlider.Value;

	S = (SpectatorSpeedSlider.Value / 300) * 100;
	SpectatorSpeedSlider.SetText("[" $ int(S) $ "%]");
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