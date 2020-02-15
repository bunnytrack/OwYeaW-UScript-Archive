class BTHUD extends ChallengeTeamHUD;

#exec texture IMPORT NAME=bunnyZfl	FILE=TEXTURES\bunnyZfl.PCX	GROUP="Icons"	FLAGS=2 MIPS=ON
#exec texture IMPORT NAME=bunnyZfr	FILE=TEXTURES\bunnyZfr.PCX	GROUP="Icons"	FLAGS=2 MIPS=ON
#exec texture IMPORT NAME=skullicon	FILE=TEXTURES\skullicon.PCX	GROUP="Icons"	FLAGS=3 MIPS=OFF
#exec texture IMPORT NAME=BTTIMER	FILE=TEXTURES\BTTIMER.PCX					FLAGS=3 MIPS=OFF
#exec texture IMPORT NAME=BTTlogo	FILE=TEXTURES\BTTlogo.PCX					FLAGS=3 MIPS=ON
#exec texture IMPORT NAME=Bootz		FILE=TEXTURES\Bootz.PCX								MIPS=OFF

#exec TEXTURE IMPORT NAME=BTFlagR	FILE=Textures\BTFlagRED.pcx					FLAGS=2
#exec TEXTURE IMPORT NAME=BTFlagB	FILE=Textures\BTFlagBLUE.pcx				FLAGS=2

struct PlayerInfo
{
	var BTEPRI					EPRI;
	var PlayerReplicationInfo	PRI;
	var BTPPReplicationInfo		RI;
};
var PlayerInfo PI[32];

var enum EDrawState
{
	DRAW_BLANK,
	DRAW_FADE_IN,
	DRAW_DISPLAY,
	DRAW_DISPLAY1,
	DRAW_DISPLAY2,
	DRAW_DISPLAY3,
	DRAW_DISPLAY4,
	DRAW_DISPLAY5,
	DRAW_DISPLAY6,
	DRAW_DISPLAY7,
	DRAW_DISPLAY8,
	DRAW_FADE_OUT,
	DRAW_DONE
} DrawState;

var bool	bDrawSplash;
var float 	DrawTime;
var float 	DrawTick;
var texture	Logo;

var color		BlackColor;
var color		RedColor;
var color		OrangeColor;
var color		GreyColor;
var bool		bSplashDrawn;

var int			Index;
var int			LastTime;
var bool		lastUpdate;

var()	color	TeamColor[4];
var()	color	AltTeamColor[4];
var()	name	OrderNames[16];
var()	int		NumOrders;
var 	CTFFlag	MyFlag;

var CH_Client	OwnerSetup;

var BTPPReplicationInfo		RI;
var BTEPRI					EPRI;
var BTEClientData			BTEC;


simulated function PostBeginPlay()
{
	local BTEClientData temp;

	foreach AllActors(class'BTEClientData', temp)
		if(temp.Owner == Owner)
			BTEC = temp;

	Super.PostBeginPlay();
}	


function SetInfo(PlayerReplicationInfo PRI)
{
	local int i;
	local bool bInit, bFoundRI, bFoundEPRI;
	local ReplicationInfo Rinfo;

	// See if it's already initialized
	for(i = 0; i < Index; i++)
	{
		if(PI[i].PRI == PRI)
		{
			EPRI	= PI[i].EPRI;
			RI		= PI[i].RI;
			bInit = true;
			break;
		}
	}
	if(!bInit)	// Not initialized, find the RI + EPRI
	{
		foreach Level.AllActors(class'ReplicationInfo', Rinfo)
		{
			if( Rinfo.IsA('BTPPReplicationInfo') )
			{
				if(BTPPReplicationInfo(Rinfo).PlayerID == PRI.PlayerID)
				{
					RI = BTPPReplicationInfo(Rinfo);
					bFoundRI = true;
				}
			}
			else if( Rinfo.IsA('BTEPRI') )
			{
				if(BTEPRI(Rinfo).PlayerID == PRI.PlayerID)
				{
					EPRI = BTEPRI(Rinfo);
					bFoundEPRI = true;
				}
			}
		}
		if(bFoundRI && bFoundEPRI)	// Init the slot - on newly found EPRI-RI
		{
			if(Index < 32)	// use empty elements in array
			{
				PI[Index].PRI = PRI;
				PI[Index].RI = RI;
				PI[Index].EPRI = EPRI;
				Index++;
			}
			else	// not enough empty elements, use an old element
			{
				for(i = 0; i < 32; i++)
				{
					if (PI[i].EPRI == None)
						break;	// assign here
				}
				PI[i].PRI = PRI;
				PI[i].RI = RI;
				PI[i].EPRI = EPRI;
			}
		}
	}
}

simulated function bool FindOwnerSetup()
{
	local int i;

	foreach AllActors(class'CH_Client', OwnerSetup)
		if(OwnerSetup.Owner == PlayerOwner)
			return True;
	return False;
}

simulated function PostRender( canvas Canvas )
{
	local float XL, YL, XPos, YPos, FadeValue, XX, YY;
	local string Message;
	local int M, i, j, k, XOverflow, X, Y, z;
	local float OldOriginX;
	local CTFFlag Flag;
	local bool bAlt;
	local int Time;
	local CheckPoint CP;

	HUDSetup(canvas);
	if ( (PawnOwner == None) || (PlayerOwner.PlayerReplicationInfo == None) )
		return;

	if ( bShowInfo )
	{
		ServerInfo.RenderInfo( Canvas );
		return;
	}

	if (!PlayerOwner.PlayerReplicationInfo.bIsSpectator)
	{
		if (OwnerSetup == None)
		{
			if (!FindOwnerSetup())
				return;
		}
	}

	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	OldOriginX = Canvas.OrgX;
	// Master message short queue control loop.
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.StrLen("TEST", XL, YL);
	Canvas.SetClip(768*Scale - 10, Canvas.ClipY);
	bDrawFaceArea = false;
	if ( !bHideFaces && !PlayerOwner.bShowScores && !bForceScores && !bHideHUD
		&& !PawnOwner.PlayerReplicationInfo.bIsSpectator && (Scale >= 0.4) )
	{
		DrawSpeechArea(Canvas, XL, YL);
		bDrawFaceArea = (FaceTexture != None) && (FaceTime > Level.TimeSeconds);
		if ( bDrawFaceArea )
		{
			if ( !bHideHUD && ((PawnOwner.PlayerReplicationInfo == None) || !PawnOwner.PlayerReplicationInfo.bIsSpectator) )
				Canvas.SetOrigin( FMax(YL*4 + 8, 70*Scale) + 7*Scale + 6 + FaceAreaOffset, Canvas.OrgY );
		}
	}

	for (i=0; i<4; i++)
	{
		if ( ShortMessageQueue[i].Message != None )
		{
			j++;

			if ( bResChanged || (ShortMessageQueue[i].XL == 0) )
			{
				if ( ShortMessageQueue[i].Message.Default.bComplexString )
					Canvas.StrLen(ShortMessageQueue[i].Message.Static.AssembleString(self,ShortMessageQueue[i].Switch,
					ShortMessageQueue[i].RelatedPRI,ShortMessageQueue[i].StringMessage),ShortMessageQueue[i].XL, ShortMessageQueue[i].YL);
				else
					Canvas.StrLen(ShortMessageQueue[i].StringMessage, ShortMessageQueue[i].XL, ShortMessageQueue[i].YL);
					Canvas.StrLen("TEST", XL, YL);
					ShortMessageQueue[i].numLines = 1;
				if ( ShortMessageQueue[i].YL > YL )
				{
					ShortMessageQueue[i].numLines++;
					for (k=2; k<4-i; k++)
					{
						if (ShortMessageQueue[i].YL > YL*k)
							ShortMessageQueue[i].numLines++;
					}
				}
			}

			// Keep track of the amount of lines a message overflows, to offset the next message with.
			Canvas.SetPos(6, 2 + YL * YPos);
			YPos += ShortMessageQueue[i].numLines;
			if ( YPos > 4 )
				break;

			if ( ShortMessageQueue[i].Message.Default.bComplexString )
			{
				// Use this for string messages with multiple colors.
				ShortMessageQueue[i].Message.Static.RenderComplexMessage(Canvas,ShortMessageQueue[i].XL,  YL,
				ShortMessageQueue[i].StringMessage,ShortMessageQueue[i].Switch,ShortMessageQueue[i].RelatedPRI,
				None,ShortMessageQueue[i].OptionalObject);
			}
			else
			{
				Canvas.DrawColor = ShortMessageQueue[i].Message.Default.DrawColor;
				Canvas.DrawText(ShortMessageQueue[i].StringMessage, False);
			}
		}
	}

	Canvas.DrawColor = WhiteColor;
	Canvas.SetClip(OldClipX, Canvas.ClipY);
	Canvas.SetOrigin(OldOriginX, Canvas.OrgY);

	if ( PlayerOwner.bShowScores || bForceScores )
	{
		if ( (PlayerOwner.Scoring == None) && (PlayerOwner.ScoringType != None) )
			PlayerOwner.Scoring = Spawn(PlayerOwner.ScoringType, PlayerOwner);
		if ( PlayerOwner.Scoring != None )
		{
			PlayerOwner.Scoring.OwnerHUD = self;
			PlayerOwner.Scoring.ShowScores(Canvas);
			if ( PlayerOwner.Player.Console.bTyping )
				DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);
			return;
		}
	}

	YPos = FMax(YL*4 + 8, 70*Scale);
	if ( bDrawFaceArea )
		DrawTalkFace( Canvas,0, YPos );	// DrawTalkFace( Canvas, YPos ); WAS ERROR CODE?
		//DrawTalkFace( Canvas, YPos ); // DrawTalkFace( Canvas,0, YPos ); WAS ERROR CODE?
	if (j > 0)
	{
		bDrawMessageArea = True;
		MessageFadeCount = 2;
	}
	else
		bDrawMessageArea = False;

	if ( !bHideCenterMessages )
	{
		// Master localized message control loop.
		for (i=0; i<10; i++)
		{
			if (LocalMessages[i].Message != None)
			{
				if (LocalMessages[i].Message.Default.bFadeMessage && Level.bHighDetailMode)
				{
					Canvas.Style = ERenderStyle.STY_Translucent;
					FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);
					if (FadeValue > 0.0)
					{
						if ( bResChanged || (LocalMessages[i].XL == 0) )
						{
							if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch) == 1 )
								LocalMessages[i].StringFont = MyFonts.GetBigFont( Canvas.ClipX );
							else // ==2
								LocalMessages[i].StringFont = MyFonts.GetHugeFont( Canvas.ClipX );
							Canvas.Font = LocalMessages[i].StringFont;
							Canvas.StrLen(LocalMessages[i].StringMessage, LocalMessages[i].XL, LocalMessages[i].YL);
							LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, LocalMessages[i].YL, Canvas.ClipY);
						}
						Canvas.Font = LocalMessages[i].StringFont;
						Canvas.DrawColor = LocalMessages[i].DrawColor * (FadeValue/LocalMessages[i].LifeTime);
						Canvas.SetPos( 0.5 * (Canvas.ClipX - LocalMessages[i].XL), LocalMessages[i].YPos );
						Canvas.DrawText( LocalMessages[i].StringMessage, False );
					}
				}
				else
				{
					if ( bResChanged || (LocalMessages[i].XL == 0) )
					{
						if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch) == 1 )
							LocalMessages[i].StringFont = MyFonts.GetBigFont( Canvas.ClipX );
						else // == 2
							LocalMessages[i].StringFont = MyFonts.GetHugeFont( Canvas.ClipX );
						Canvas.Font = LocalMessages[i].StringFont;
						Canvas.StrLen(LocalMessages[i].StringMessage, LocalMessages[i].XL, LocalMessages[i].YL);
						LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, LocalMessages[i].YL, Canvas.ClipY);
					}
					Canvas.Font = LocalMessages[i].StringFont;
					Canvas.Style = ERenderStyle.STY_Normal;
					Canvas.DrawColor = LocalMessages[i].DrawColor;
					Canvas.SetPos( 0.5 * (Canvas.ClipX - LocalMessages[i].XL), LocalMessages[i].YPos );
					Canvas.DrawText( LocalMessages[i].StringMessage, False );
				}
			}
		}
	}
	Canvas.Style = ERenderStyle.STY_Normal;

	if ( (!PlayerOwner.bBehindView || (PlayerOwner.bBehindView && PlayerOwner.ViewTarget == None && !PlayerOwner.IsInState('GameEnded'))) && (PawnOwner.Weapon != None) && (Level.LevelAction == LEVACT_None) )
	{
		Canvas.DrawColor = WhiteColor;
		PawnOwner.Weapon.PostRender(Canvas);
		if ( !PawnOwner.Weapon.bOwnsCrossHair )
			DrawScaledCH(Canvas);
	}

	if (PawnOwner != None)
	{
		if (PawnOwner.bIsPlayer && !bHideHUD)
		{
			SetInfo(PawnOwner.PlayerReplicationInfo);

			//	TEXT STUFF
			Canvas.bCenter = true;
			Canvas.Style = ERenderStyle.STY_Normal;	
			Canvas.StrLen("test", XX, YY);
			Canvas.SetPos(0, Canvas.ClipY - YY*0.666 - 0.0833*Canvas.ClipY);
			if (PawnOwner != Owner)
			{
				//	DRAW NEW LIVE FEED
				Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);
				Canvas.DrawColor = ChallengeTeamHUD(PlayerOwner.myHUD).TeamColor[PawnOwner.PlayerReplicationInfo.Team];
				DrawShadowText(Canvas, PawnOwner.PlayerReplicationInfo.PlayerName, True);
			}
			else
			{
				foreach VisibleCollidingActors(class'CheckPoint', CP, 64.0, PlayerOwner.Location)
				{
					if (CP.owner != none && PlayerPawn(CP.owner) != PlayerOwner)
					{
						Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);
						Canvas.DrawColor = OrangeColor;
						DrawShadowText(Canvas, PlayerPawn(CP.owner).PlayerReplicationInfo.PlayerName $ "'s Checkpoint");
					}
				}
			}
			//	RESET TEXT STUFF
			Canvas.bCenter = false;
			Canvas.DrawColor = WhiteColor;
			Canvas.Style = Style;
			Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );

			RI = FindInfo(PawnOwner.PlayerReplicationInfo, z);
			if(RI != None && !PawnOwner.IsInState('GameEnded') && !PawnOwner.PlayerReplicationInfo.bWaitingPlayer && !PawnOwner.PlayerReplicationInfo.bIsSpectator)
			{
				if(!RI.bNeedsRespawn)
				{
					Time = RI.GetRuntime() / 10;
					LastTime = Time;
					lastUpdate = False;
				}
				else
				{
					if(!lastUpdate)
					{
						LastTime = RI.LastCap / 10;
						lastUpdate = True;
					}
					Time = LastTime;
				}
				DrawHUDTimes(Canvas, Time/600, Time % 600);
			}
		}
	}

	if ( bStartUpMessage && (Level.TimeSeconds < 5) )
	{
		bStartUpMessage = false;
		PlayerOwner.SetProgressTime(7);
	}
	if ( (PlayerOwner.ProgressTimeOut > Level.TimeSeconds) && !bHideCenterMessages )
		DisplayProgressMessage(Canvas);

	// Display MOTD
	if ( MOTDFadeOutTime > 0.0 )
		DrawMOTD(Canvas);

	if( !bHideHUD )
	{
		if ( !PawnOwner.PlayerReplicationInfo.bIsSpectator )
		{
			Canvas.Style = Style;

			// Draw Ammo
			if ( !bHideAmmo )
				DrawAmmo(Canvas);

			// Draw Health/Armor status + Boots
			if(EPRI != None)
				DrawStatuz(Canvas);	// NEW AND IMPROVED
			else
				DrawStatus(Canvas);	// IF EPRI ISNT WORKING

			// Display Weapons
			if ( !bHideAllWeapons )
				DrawWeapons(Canvas);
			else if ( Level.bHighDetailMode && (PawnOwner == PlayerOwner) && (PlayerOwner.Handedness == 2) )
			{
				// if weapon bar hidden and weapon hidden, draw weapon name when it changes
				if ( PawnOwner.PendingWeapon != None )
				{
					WeaponNameFade = 1.0;
					Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
					Canvas.DrawColor = PawnOwner.PendingWeapon.NameColor;
					Canvas.SetPos(Canvas.ClipX - 360 * Scale, Canvas.ClipY - 64 * Scale);
					Canvas.DrawText(PawnOwner.PendingWeapon.ItemName, False);
				}
				else if ( (Level.NetMode == NM_Client) && PawnOwner.IsA('TournamentPlayer') && (TournamentPlayer(PawnOwner).ClientPending != None) )
				{
					WeaponNameFade = 1.0;
					Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
					Canvas.DrawColor = TournamentPlayer(PawnOwner).ClientPending.NameColor;
					Canvas.SetPos(Canvas.ClipX - 360 * Scale, Canvas.ClipY - 64 * Scale);
					Canvas.DrawText(TournamentPlayer(PawnOwner).ClientPending.ItemName, False);
				}
				else if ( (WeaponNameFade > 0) && (PawnOwner.Weapon != None) )
				{
					Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
					Canvas.DrawColor = PawnOwner.Weapon.NameColor;
					if ( WeaponNameFade < 1 )
						Canvas.DrawColor = Canvas.DrawColor * WeaponNameFade;
					Canvas.SetPos(Canvas.ClipX - 360 * Scale, Canvas.ClipY - 64 * Scale);
					Canvas.DrawText(PawnOwner.Weapon.ItemName, False);
				}
			}
			// Display Frag count
			if ( !bAlwaysHideFrags && !bHideFrags )
				DrawFragCount(Canvas);
		}
		// Team Game Synopsis
		if ( !bHideTeamInfo )
			DrawGameSynopsis(Canvas);

		// Display Identification Info
		if ( PawnOwner == PlayerOwner )
			DrawIdentifyInfo(Canvas);

		if ( HUDMutator != None )
			HUDMutator.PostRender(Canvas);

		if ( (PlayerOwner.GameReplicationInfo != None) && (PlayerPawn(Owner).GameReplicationInfo.RemainingTime > 0) )
		{
			if ( TimeMessageClass == None )
				TimeMessageClass = class<CriticalEventPlus>(DynamicLoadObject("Botpack.TimeMessage", class'Class'));

			if ( (PlayerOwner.GameReplicationInfo.RemainingTime <= 300) && (PlayerOwner.GameReplicationInfo.RemainingTime != LastReportedTime) )
			{
				LastReportedTime = PlayerOwner.GameReplicationInfo.RemainingTime;
				if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 30 )
				{
					bTimeValid = ( bTimeValid || (PlayerOwner.GameReplicationInfo.RemainingTime > 0) );
					if ( PlayerOwner.GameReplicationInfo.RemainingTime == 30 )
						TellTime(5);
					else if ( bTimeValid && PlayerOwner.GameReplicationInfo.RemainingTime <= 10 )
						TellTime(16 - PlayerOwner.GameReplicationInfo.RemainingTime);
				}
				else if ( PlayerOwner.GameReplicationInfo.RemainingTime % 60 == 0 )
				{
					M = PlayerOwner.GameReplicationInfo.RemainingTime/60;
					TellTime(5 - M);
				}
			}
		}
	}
	if ( PlayerOwner.Player.Console.bTyping )
		DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);

	if ( PlayerOwner.bBadConnectionAlert && (PlayerOwner.Level.TimeSeconds > 5) )
	{
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawColor = WhiteColor;
		Canvas.SetPos(Canvas.ClipX - (64*Scale), Canvas.ClipY / 2);
		Canvas.DrawIcon(texture'DisconnectWarn', Scale);
	}

   	//Super.PostRender( Canvas );

	if ( (PlayerOwner == None) || (PawnOwner == None) || (PlayerOwner.GameReplicationInfo == None)
		|| (PawnOwner.PlayerReplicationInfo == None)
		|| ((PlayerOwner.bShowMenu || PlayerOwner.bShowScores) && (Canvas.ClipX < 640)) )
		return;

	if (DrawState != DRAW_DONE)
	{
		if (!bDrawSplash)
		{
			Logo = texture'BTTlogo';
			bDrawSplash = True;
			DrawState = EDrawState.DRAW_BLANK;
			DrawTick = 0.0625;
			SetTimer(DrawTick, True);
		}
		else if (DrawState != DRAW_DONE)
			DrawSplash(Canvas);
	}

	//Canvas.Style = Style;
	if( !bHideHUD && !bHideTeamInfo )
	{
		X = Canvas.ClipX - 70 * Scale;
		Y = Canvas.ClipY - 350 * Scale;

		Canvas.SetPos(X, Y);
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor = ChallengeTeamHUD(PlayerOwner.myHUD).TeamColor[0];
		Canvas.DrawIcon(texture'bunnyZfl', Scale * 0.125);
		DrawBigNum(Canvas, int(TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo).Teams[0].Score), Canvas.ClipX - 144 * Scale, Canvas.ClipY - 336 * Scale - (150 * Scale * 0), 1);
		Canvas.SetPos(X, Y - 150 * Scale);
		Canvas.DrawColor = ChallengeTeamHUD(PlayerOwner.myHUD).TeamColor[1];
		Canvas.DrawIcon(texture'bunnyZfl', Scale * 0.125);
		DrawBigNum(Canvas, int(TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo).Teams[1].Score), Canvas.ClipX - 144 * Scale, Canvas.ClipY - 336 * Scale - (150 * Scale * 1), 1);
		Canvas.Style = ERenderStyle.STY_Normal;
	}
}

simulated function DrawScaledCH(Canvas canvas)
{
	local float XScale, PickDiff;
	local float XLength;
	local texture T;

 	if (Crosshair>=CrosshairCount)
		Return;

	if (PlayerOwner.PlayerReplicationInfo.bIsSpectator)
		XScale = 2;
	else
	{
		if (OwnerSetup.scale != 0)
			XScale = OwnerSetup.scale;
		else
			XScale = 1;
	}

	PickDiff = Level.TimeSeconds - PickupTime;
	if ( PickDiff < 0.4 )
	{
		if ( PickDiff < 0.2 )
			XScale *= (1 + 5 * PickDiff);
		else
			XScale *= (3 - 5 * PickDiff);
	}
	XLength = XScale * 64.0;

	Canvas.bNoSmooth = False;
	if ( PlayerOwner.Handedness == -1 )
		Canvas.SetPos(0.503 * (Canvas.ClipX - XLength), 0.504 * (Canvas.ClipY - XLength));
	else if ( PlayerOwner.Handedness == 1 )
		Canvas.SetPos(0.497 * (Canvas.ClipX - XLength), 0.496 * (Canvas.ClipY - XLength));
	else
		Canvas.SetPos(0.5 * (Canvas.ClipX - XLength), 0.5 * (Canvas.ClipY - XLength));
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor = 15 * CrosshairColor;

	T = CrossHairTextures[Crosshair];
	if( T == None )
		T = LoadCrosshair(Crosshair);

	Canvas.DrawTile(T, XLength, XLength, 0, 0, 64, 64);
	Canvas.bNoSmooth = True;
	Canvas.Style = Style;
}

simulated function DrawSplash(canvas Canvas)
{
	local float W, H, X;
	X = 255;

	if (DrawState != EDrawState.DRAW_BLANK)
	{
		Canvas.Reset();
		Canvas.SetPos( (Canvas.ClipX/2) - ((Canvas.ClipY/4.5)/2) , (Canvas.ClipY*0.875) - ((Canvas.ClipY/4.5)/2) );

		Switch (DrawState)
		{
			case EDrawState.DRAW_FADE_IN :
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.DrawColor.R = 255 * DrawTime;
				Canvas.DrawColor.G = 140 * DrawTime;
				Canvas.DrawColor.B = 0;
			break;

			case EDrawState.DRAW_DISPLAY :
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.DrawColor.R = 255;
				Canvas.DrawColor.G = 140;
				Canvas.DrawColor.B = 0;
			break;

			case EDrawState.DRAW_DISPLAY1 :
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.DrawColor.R = 255;
				Canvas.DrawColor.G = 140 - (X * DrawTime);
				Canvas.DrawColor.B = 0;
			break;

			case EDrawState.DRAW_DISPLAY2 :
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.DrawColor.R = 255;
				Canvas.DrawColor.G = 0;
				Canvas.DrawColor.B = 0 + (X * DrawTime);
			break;

			case EDrawState.DRAW_DISPLAY3 :
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.DrawColor.R = 255 - (X * DrawTime);
				Canvas.DrawColor.G = 0;
				Canvas.DrawColor.B = 255;
			break;

			case EDrawState.DRAW_DISPLAY4 :
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.DrawColor.R = 0;
				Canvas.DrawColor.G = 0 + (X * DrawTime);
				Canvas.DrawColor.B = 255;
			break;

			case EDrawState.DRAW_DISPLAY5 :
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.DrawColor.R = 0;
				Canvas.DrawColor.G = 255;
				Canvas.DrawColor.B = 255 - (X * DrawTime);
			break;

			case EDrawState.DRAW_DISPLAY6 :
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.DrawColor.R = 0 + (X * DrawTime);
				Canvas.DrawColor.G = 255;
				Canvas.DrawColor.B = 0;
			break;

			case EDrawState.DRAW_DISPLAY7 :
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.DrawColor.R = 255;
				Canvas.DrawColor.G = 255 - (X * DrawTime);
				Canvas.DrawColor.B = 0;
			break;

			case EDrawState.DRAW_DISPLAY8 :
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.DrawColor.R = 255;
				Canvas.DrawColor.G = 255 - (X * DrawTime);
				Canvas.DrawColor.B = 0;
			break;

			case EDrawState.DRAW_FADE_OUT :
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.DrawColor.R = 255 - (255 * DrawTime);
				Canvas.DrawColor.G = 140 - (140 * DrawTime);
				Canvas.DrawColor.B = 0;
			break;
		}
		Canvas.DrawIcon(Logo, ((Canvas.ClipY/4.5)/512));
		Canvas.Reset();
		Canvas.bCenter = False;
	}
}

simulated function Timer()
{
	local float X;
	DrawTime = DrawTime + DrawTick;
	X = 1;

	if (!bSplashDrawn)
	{
		Switch (DrawState)
		{
			case EDrawState.DRAW_BLANK :
				if (DrawTime >= 1.0)
				{
					DrawState = EDrawState.DRAW_FADE_IN;
					DrawTime = 0.0;
				}
			break;
// PHASE FADE IN
			case EDrawState.DRAW_FADE_IN :
				if (DrawTime >= 1.0)
				{
					DrawState = EDrawState.DRAW_DISPLAY;
					DrawTime = 0.0;
				}
			break;
// PHASE STANDART DISPLAY
			case EDrawState.DRAW_DISPLAY :
				if (PlayerOwner.PlayerReplicationInfo.bWaitingPlayer)
				{
					DrawState = EDrawState.DRAW_DISPLAY1;
					DrawTime = 0;
				}
				else if (DrawTime >= 2.0)
				{
					DrawState = EDrawState.DRAW_FADE_OUT;
					DrawTime = 0.0;
				}
			break;
// PHASE START COLOR DISPLAY
			case EDrawState.DRAW_DISPLAY1 :
				if (DrawTime >= X * 0.55)
				{
					DrawState = EDrawState.DRAW_DISPLAY2;
					DrawTime = 0;
				}
			break;
// PHASE 1 -> 2 LOOP START
			case EDrawState.DRAW_DISPLAY2 :
				if (DrawTime >= X)
				{
					DrawState = EDrawState.DRAW_DISPLAY3;
					DrawTime = 0;
				}
			break;
// PHASE 2 -> 3
			case EDrawState.DRAW_DISPLAY3 :
				if (DrawTime >= X)
				{
					DrawState = EDrawState.DRAW_DISPLAY4;
					DrawTime = 0;
				}
			break;
// PHASE 4 -> 5
			case EDrawState.DRAW_DISPLAY4 :
				if (DrawTime >= X)
				{
					DrawState = EDrawState.DRAW_DISPLAY5;
					DrawTime = 0;
				}
			break;
// PHASE 5 -> 6
			case EDrawState.DRAW_DISPLAY5 :
				if (DrawTime >= X)
				{
					DrawState = EDrawState.DRAW_DISPLAY6;
					DrawTime = 0;
				}
			break;
// PHASE 6 -> 7 or 8 if countdown begins LOOP END
			case EDrawState.DRAW_DISPLAY6 :
				if (RI.bReadyToPlay || !PlayerOwner.PlayerReplicationInfo.bWaitingPlayer)
				{
					if (DrawTime >= X)
					{
						DrawState = EDrawState.DRAW_DISPLAY8;
						DrawTime = 0;
					}
				}
				else
				{
					if (DrawTime >= X)
					{
						DrawState = EDrawState.DRAW_DISPLAY7;
						DrawTime = 0;
					}
				}
			break;
// PHASE 7 -> 2
			case EDrawState.DRAW_DISPLAY7 :
				if (DrawTime >= X)
				{
					DrawState = EDrawState.DRAW_DISPLAY2;
					DrawTime = 0;
				}
			break;
// PHASE RESET TO ORANGE
			case EDrawState.DRAW_DISPLAY8 :
				if (DrawTime >= X * 0.451)
				{
					DrawState = EDrawState.DRAW_FADE_OUT;
					DrawTime = 0.0;
				}
			break;
// PHASE FADE OUT
			case EDrawState.DRAW_FADE_OUT :
				if (DrawTime >= 1.0)
				{
					DrawState = EDrawState.DRAW_DONE;
					DrawTime = 0.0;
				}
			break;
// PHASE DONE
			case EDrawState.DRAW_DONE :
				//Disable('Timer');
				bSplashDrawn = True;
				Logo = None;
			break;
		}
	}
	Super.Timer();
}

simulated function DrawTeam(Canvas Canvas, TeamInfo TI){}

//searches for the BTPP RI by the UT PRI given
function BTPPReplicationInfo FindInfo(PlayerReplicationInfo PRI, out int ident)
{
	local int i;
	local BTPPReplicationInfo RI;
	local bool bFound;

	// See if it's already initialized
	for (i=0;i<Index;i++)
	{
		if (PI[i].PRI == PRI)
		{
			ident = i;
			return PI[i].RI;
		}
	}

	// Not initialized, find the RI and init a new slot
	foreach Level.AllActors(class'BTPPReplicationInfo', RI)
	{
		if (RI.PlayerID == PRI.PlayerID)
		{
			bFound = true;
			break;
		}
    }
	// Couldn't find RI, this sucks
	if (!bFound)
		return None;

	// Init the slot - on newly found BTPP-RI
	if (Index < 32)//empty elements in array
	{
		InitInfo(Index, PRI, RI);
		ident = Index;
		Index++;
		return RI;
	}
	else //search dead one
	{
		for (i=0;i<32;i++) //chg from ++i in 098
		{
			if (PI[i].RI == None)
				break;//assign here; else return none/-1
		}
		InitInfo(i, PRI, RI);
		ident = i;
		return RI;
	}
	ident = -1;
	return None;
}

function InitInfo (int i, PlayerReplicationInfo PRI, BTPPReplicationInfo RI)
{
	PI[i].PRI = PRI;
	PI[i].RI = RI;
}

simulated function DrawHUDTimes(Canvas Canvas, int Minutes, int Seconds)
{
	local int d;
	local float TimerScale;

	Canvas.Style = ERenderStyle.STY_Normal;

	if(BTEC != None && BTEC.CustomTimer)
	{
		TimerScale = Scale * BTEC.TimerScale;
		Canvas.CurX = (Canvas.ClipX / 2 - 86 * TimerScale) + BTEC.LocationX;
		Canvas.CurY = 4 + BTEC.LocationY;
	}
	else
	{
		TimerScale = Scale;
		Canvas.CurY = 4;
		Canvas.CurX = Canvas.ClipX / 2 - 86 * TimerScale;
	}

	if(Minutes > 99)//too long run time: show -:-- in red
	{
		if(BTEC != None && BTEC.CustomTimer)
			Canvas.CurX = (Canvas.ClipX / 2 - 57 * TimerScale) + BTEC.LocationX;
		else
			Canvas.CurX = Canvas.ClipX / 2 - 57 * TimerScale;

		Canvas.DrawColor = RedColor;
		Canvas.CurX = Canvas.ClipX / 2 - 57 * TimerScale;

		//	-:
		DrawShadowTile(Canvas, Texture'BTTimer', TimerScale*50, 35*TimerScale, 0, 64, 50.0, 35.0);
		Canvas.CurX += 7*TimerScale;

		//	-
		DrawShadowTile(Canvas, Texture'BTTimer', TimerScale*25, 35*TimerScale, 0, 64, 25.0, 35.0);
		Canvas.CurX += 7*TimerScale;

		//	-
		DrawShadowTile(Canvas, Texture'BTTimer', TimerScale*25, 35*TimerScale, 0, 64, 25.0, 35.0);
	}
	else //	show actual timer
	{
		if(RI != None && RI.bNeedsRespawn)	//Captime/reset on death in grey
			Canvas.DrawColor = GreyColor;
		else 
		{
			if(BTEC != None && BTEC.CustomTimer)
			{
				Canvas.DrawColor.R = BTEC.Red;
				Canvas.DrawColor.G = BTEC.Green;
				Canvas.DrawColor.B = BTEC.Blue;
			}
			else
				Canvas.DrawColor = OrangeColor;

			if(RI != None && RI.CPUsed)
				Canvas.DrawColor = GreyColor;
		}

		if ( Minutes >= 10 )
		{
			d = Minutes/10;
			DrawShadowTile(Canvas, Texture'BTTimer', TimerScale*25, 35*TimerScale, d*25, 0, 25.0, 35.0);
			Canvas.CurX += 7*TimerScale;
			Minutes = Minutes - 10 * d;
		}
		else
		{
			//leading 0
			DrawShadowTile(Canvas, Texture'BTTimer', TimerScale*25, 35*TimerScale, 0, 0, 25.0, 35.0);
			Canvas.CurX += 7*TimerScale;
		}

		//single digit minutes
		DrawShadowTile(Canvas, Texture'BTTimer', TimerScale*25, 35*TimerScale, Minutes*25, 0, 25.0, 35.0);
		Canvas.CurX += 3*TimerScale;

		// ":" 
		DrawShadowTile(Canvas, Texture'BTTimer', TimerScale*12, 35*TimerScale, 30, 64, 12.0, 35.0);
		Canvas.CurX += 5 * TimerScale;

		//Seconds 1
		d = Seconds/100;
		DrawShadowTile(Canvas, Texture'BTTimer', TimerScale*25, 35*TimerScale, 25*d, 0, 25.0, 35.0);
		Canvas.CurX += 7*TimerScale;

		//Seconds 2
		Seconds -=  100*d;
		d = Seconds / 10;
		DrawShadowTile(Canvas, Texture'BTTimer', TimerScale*25, 35*TimerScale, 25*d, 0, 25.0, 35.0);
		Canvas.CurX += 7*TimerScale;

		// "."
		DrawShadowTile(Canvas, Texture'BTTimer', TimerScale*12, 32*TimerScale, 32, 46, 12.0, 32.0);
		Canvas.CurX += 3 * TimerScale;

		//Deciseconds
		Seconds -= 10*d;
		DrawShadowTile(Canvas, Texture'BTTimer', TimerScale*16, 42*TimerScale, 25*Seconds, 0, 25.0, 64.0);
	}
	Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).GoldColor;
	Canvas.Style = ERenderStyle.STY_Normal;
}
//=========================================================================
simulated function DrawStatuz(Canvas Canvas)
{
	local float StatScale, H1, H2, X, Y, DamageTime;
	Local int i;
	local bool bHasDoll;
	local Bot BotOwner;
	local TournamentPlayer TPOwner;
	local texture Doll, DollBelt;

	if(!bHideStatus)
	{
		TPOwner = TournamentPlayer(PawnOwner);
		if (Canvas.ClipX < 400)
			bHasDoll = false;
		else if(TPOwner != None)
		{
			Doll = TPOwner.StatusDoll;
			DollBelt = TPOwner.StatusBelt;
			bHasDoll = true;
		}
		else
		{
			BotOwner = Bot(PawnOwner);
			if(BotOwner != None)
			{
				Doll = BotOwner.StatusDoll;
				DollBelt = BotOwner.StatusBelt;
				bHasDoll = true;
			}
		}
		if(bHasDoll)
		{
			Canvas.Style = ERenderStyle.STY_Translucent;
			StatScale = Scale * StatusScale;
			X = Canvas.ClipX - 128 * StatScale;
			Canvas.SetPos(X, 0);
			if(PawnOwner.DamageScaling > 2.0)
				Canvas.DrawColor = PurpleColor;
			else
				Canvas.DrawColor = HUDColor;
			Canvas.DrawTile(Doll, 128 * StatScale, 256 * StatScale, 0, 0, 128.0, 256.0);
			Canvas.DrawColor = HUDColor;
			if(EPRI.bShieldBelt)
			{
				Canvas.DrawColor = BaseColor;
				Canvas.DrawColor.B = 0;
				Canvas.SetPos(X, 0);
				Canvas.DrawIcon(DollBelt, StatScale);
			}
			if(EPRI.bChestArmor)
			{
				Canvas.DrawColor = HUDColor * FMin(0.01 * EPRI.ChestAmount, 1);
				Canvas.SetPos(X, 0);
				Canvas.DrawTile(Doll, 128 * StatScale, 64 * StatScale, 128, 0, 128, 64);
			}
			if(EPRI.bThighArmor)
			{
				Canvas.DrawColor = HUDColor * FMin(0.02 * EPRI.ThighAmount, 1);
				Canvas.SetPos(X, 64 * StatScale);
				Canvas.DrawTile(Doll, 128 * StatScale, 64 * StatScale, 128, 64, 128, 64);
			}
			if(EPRI.bJumpBoots)
			{
				Canvas.DrawColor = HUDColor;
				Canvas.SetPos(X, 128 * StatScale);
				Canvas.DrawTile(Doll, 128 * StatScale, 64 * StatScale, 128, 128, 128, 64);
			}
			Canvas.Style = Style;
			if( (PawnOwner == PlayerOwner) && Level.bHighDetailMode && !Level.bDropDetail )
			{
				for(i = 0; i < 4; i++)
				{
					DamageTime = Level.TimeSeconds - HitTime[i];
					if(DamageTime < 1)
					{
						Canvas.SetPos(X + HitPos[i].X * StatScale, HitPos[i].Y * StatScale);
						if(HUDColor.G > 100 || HUDColor.B > 100)
							Canvas.DrawColor = RedColor;
						else
							Canvas.DrawColor = (WhiteColor - HudColor) * FMin(1, 2 * DamageTime);
						Canvas.DrawColor.R = 255 * FMin(1, 2 * DamageTime);
						Canvas.DrawTile(Texture'BotPack.HudElements1', StatScale * HitDamage[i] * 25, StatScale * HitDamage[i] * 64, 0, 64, 25.0, 64.0);
					}
				}
			}
		}
	}
	Canvas.DrawColor = HUDColor;
	if(bHideStatus && bHideAllWeapons)
	{
		X = 0.5 * Canvas.ClipX;
		Y = Canvas.ClipY - 64 * Scale;
	}
	else
	{
		X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
		Y = 64 * Scale;
	}
	Canvas.SetPos(X,Y);
	if(PawnOwner.Health < 50)
	{
		H1 = 1.5 * TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = WhiteColor * H2 + (HUDColor - WhiteColor) * H1;
	}
	else
		Canvas.DrawColor = HUDColor;
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128 * Scale, 64 * Scale, 128, 128, 128.0, 64.0);

	if(PawnOwner.Health < 50)
	{
		H1 = 1.5 * TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = Canvas.DrawColor * H2 + (WhiteColor - Canvas.DrawColor) * H1;
	}
	else
		Canvas.DrawColor = WhiteColor;
	DrawBigNum(Canvas, Max(0, PawnOwner.Health), X + 4 * Scale, Y + 16 * Scale, 1);

	Canvas.DrawColor = HUDColor;
	if(bHideStatus && bHideAllWeapons)
	{
		X = 0.5 * Canvas.ClipX - 128 * Scale;
		Y = Canvas.ClipY - 64 * Scale;
	}
	else
	{
		X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
		Y = 0;
	}
	Canvas.SetPos(X, Y);
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128 * Scale, 64 * Scale, 0, 192, 128.0, 64.0);

	if(EPRI.bShieldBelt)
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = WhiteColor;
	DrawBigNum(Canvas, EPRI.ArmorAmount, X + 4 * Scale, Y + 16 * Scale, 1);

	if(EPRI.bJumpBoots)
	{
		Canvas.DrawColor = HUDColor;
		if(bHideStatus && bHideAllWeapons)
		{
			if(bHideAmmo)
			{
				X = 0.5 * Canvas.ClipX + 128 * Scale;
				Y = Canvas.ClipY - 64 * Scale;
			}
			else	// Draw after ammo.
			{
				X = 0.5 * Canvas.ClipX + 256 * Scale;
				Y = Canvas.ClipY - 64 * Scale;
			}
		}
		else
		{
			X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
			Y = 128 * Scale;
		}
		Canvas.SetPos(X,Y);
		Canvas.DrawTile(Texture'Bootz', 128 * Scale, 64 * Scale, 0, 0, 128.0, 64.0);
		Canvas.DrawColor = WhiteColor;
		DrawBigNum(Canvas, EPRI.BootCharges, X + 4 * Scale, Y + 16 * Scale, 1);
	}
}
//=========================================================================
simulated function bool DrawIdentifyInfo(canvas Canvas)
{
	local BTEPRI BTEPRI;
	local float XL, YL;
	local Pawn P;

	if(!TraceIdentify(Canvas))
		return false;

	if(IdentifyTarget.PlayerName != "")
	{
		Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);
		DrawTwoColorID(Canvas,IdentifyName, IdentifyTarget.PlayerName, Canvas.ClipY - 256 * Scale);

		Canvas.StrLen("TEST", XL, YL);
		P = Pawn(IdentifyTarget.Owner);
		Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
		if (P != None)
			DrawTwoColorID(Canvas,IdentifyHealth,string(P.Health), (Canvas.ClipY - 256 * Scale) + 1.5 * YL);
	}
	return true;
}
simulated function SetIDColor(Canvas Canvas, int Type)
{
	if(Type == 0)
		Canvas.DrawColor = AltTeamColor[IdentifyTarget.Team] * 0.333 * IdentifyFadeTime;
	else
		Canvas.DrawColor = TeamColor[IdentifyTarget.Team] * 0.333 * IdentifyFadeTime;
}
//=========================================================================
function DrawShadowTile( Canvas Canvas, Texture Tex, float XL, float YL, float U, float V, float UL, float VL)
{
	local float X, Y;
	local color OldColor;

	X = Canvas.CurX;
	Y = Canvas.CurY;
	Canvas.CurX += 1;
	Canvas.CurY += 1;
	OldColor = Canvas.DrawColor;
	Canvas.DrawColor = BlackColor;
	Canvas.DrawTile(Tex, XL, YL, U, V, UL, VL);
	Canvas.SetPos(X, Y);
	Canvas.DrawColor = OldColor;
	Canvas.DrawTile(Tex, XL, YL, U, V, UL, VL);
}
//=========================================================================
function DrawShadowText (Canvas Canvas, coerce string Text, optional bool Param)
{
    local Color OldColor;
    local int XL,YL;
    local float X, Y;

	if(Text == "")
		Text = " ";

    OldColor = Canvas.DrawColor;
    Canvas.DrawColor = BlackColor;
    XL = 1;
	YL = 1;
	X = Canvas.CurX;
	Y = Canvas.CurY;
	Canvas.SetPos(X+XL,Y+YL);
	Canvas.DrawText(Text, Param);
	Canvas.DrawColor = OldColor;
	Canvas.SetPos(X,Y);
	Canvas.DrawText(Text, Param);
}

defaultproperties
{
	IdentifyName=""
	IdentifyHealth=""
	RedColor=(R=255)
	GreyColor=(R=170,G=170,B=170)
	OrangeColor=(R=255,G=88)
}