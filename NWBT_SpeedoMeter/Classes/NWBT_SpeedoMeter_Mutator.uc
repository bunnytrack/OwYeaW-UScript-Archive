//=============================================================================
// NWBT_SpeedoMeter_Mutator made by OwYeaW
//=============================================================================
class NWBT_SpeedoMeter_Mutator extends Mutator;

enum Fontz
{
	Smallest,
	Small,
	Medium,
	Big,
	Huge,
};

var(SpeedoMeter) Fontz TextSize;
var(SpeedoMeter) color TextColor;
var(SpeedoMeter) color TextShadow;
var Font SelectedFont;
var FontInfo MyFonts;

replication
{
	reliable if (Role == ROLE_Authority)
		TextSize, TextColor, TextShadow;
}
//=============================================================================
// Tick
//=============================================================================
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if(!bHUDMutator && Level.NetMode != NM_DedicatedServer)
	{
		RegisterHUDMutator();
		MyFonts = FontInfo(Spawn(Class<Actor>(DynamicLoadObject(class'ChallengeHUD'.default.FontInfoClass, class'Class'))));
	}
}
//=============================================================================
// PostRender
//=============================================================================
simulated function PostRender(Canvas C)
{
	local Actor Target;
	local Pawn PawnOwner;

	if(NextHUDMutator != None)
		NextHUDMutator.PostRender(C);

	if(SelectedFont == None)
	{
		switch(TextSize)
		{
			case Smallest:	SelectedFont = MyFonts.GetSmallestFont(C.ClipX);	break;
			case Small:		SelectedFont = MyFonts.GetSmallFont(C.ClipX);		break;
			case Medium:	SelectedFont = MyFonts.GetMediumFont(C.ClipX);		break;
			case Big:		SelectedFont = MyFonts.GetBigFont(C.ClipX);			break;
			case Huge:		SelectedFont = MyFonts.GetHugeFont(C.ClipX);		break;
		}
	}

	PawnOwner = C.Viewport.Actor;
	if(PawnOwner != None)
	{
		Target = PlayerPawn(PawnOwner).ViewTarget;
		if(Pawn(Target) == None)
			Target = PawnOwner;
		if(Pawn(Target) != None && !Pawn(Target).PlayerReplicationInfo.bIsSpectator)
			DrawSpeed(C, Target);
	}
}
//=============================================================================
// DrawSpeed
//=============================================================================
simulated function DrawSpeed(Canvas C, Actor A)
{
	local color		OldColor;
	local bool		OldCenter;
	local byte		OldStyle;
	local Vector	HorizontalVelocity;
	local int		HoriSpeed;

	HorizontalVelocity = A.Velocity;
	HorizontalVelocity.Z = 0;
	HoriSpeed = VSize(HorizontalVelocity);

	C.Font = SelectedFont;
	C.SetPos(0, (C.ClipY * 0.80));

	//	saving old values
	OldColor	= C.DrawColor;
	OldCenter	= C.bCenter;
	OldStyle	= C.Style;

	//	setting new values
	C.DrawColor = TextColor;
	C.bCenter	= true;
	C.Style		= ERenderStyle.STY_Normal;

	//	draw the horizontal speed
	DrawShadowText(C, string(HoriSpeed));

	//	restoring old values
	C.DrawColor	= OldColor;
	C.bCenter	= OldCenter;
	C.Style		= OldStyle;
}
//=============================================================================
// DrawShadowText
//=============================================================================
simulated function DrawShadowText(Canvas C, coerce string Text, optional bool Param)
{
    local Color OldColor;
    local int XL,YL;
    local float X, Y;

	if(Text == "")
		Text = " ";

    OldColor = C.DrawColor;

    C.DrawColor = TextShadow;
    XL = 1;
	YL = 1;
	X = C.CurX;
	Y = C.CurY;
	C.SetPos(X+XL,Y+YL);
	C.DrawText(Text, Param);
	C.DrawColor = OldColor;
	C.SetPos(X,Y);
	C.DrawText(Text, Param);
}
//=============================================================================
// Defaultproperties
//=============================================================================
defaultproperties
{
	TextSize=Huge
	TextColor=(R=255,G=255,B=255)
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	Texture=Texture'Engine.S_Flag'
	bEdShouldSnap=True
}