//=============================================================================
// BT_HUD made by OwYeaW
//=============================================================================
class BT_HUD extends ChallengeTeamHUD;

#exec texture IMPORT NAME=BT_GreyBackground		FILE=BTE_Files\BT_GreyBackground.BMP	MIPS=OFF
#exec texture IMPORT NAME=BT_HUDBoots			FILE=BTE_Files\BT_HUDBoots.PCX			MIPS=OFF
#exec texture IMPORT NAME=BT_HUDTimer			FILE=BTE_Files\BT_HUDTimer.PCX			FLAGS=3			MIPS=OFF
#exec texture IMPORT NAME=BT_HUDBunny_BTNet		FILE=BTE_Files\BT_HUDBunny_BTNet.BMP	GROUP="Icons"	FLAGS=2		MIPS=ON
#exec texture IMPORT NAME=BT_HUDBunny_BTE		FILE=BTE_Files\BT_HUDBunny_BTE.PCX		GROUP="Icons"	FLAGS=2		MIPS=ON
#exec texture IMPORT NAME=BT_HUDBunny_BTPP		FILE=BTE_Files\BT_HUDBunny_BTPP.PCX		GROUP="Icons"	FLAGS=2		MIPS=ON

struct PlayerInfo
{
	var BT_PRI					BTPRI;
	var PlayerReplicationInfo	PRI;
	var BTPPReplicationInfo		RI;
};
var PlayerInfo PI[32];

var color					AltTeamColor[5];
var color					TeamColor[5];
var color					YellowColor;
var color					BlackColor;
var color					GreyColor;
var color					PurpleColor;
var color					OrangeColor;
var ClientData				Config;
var BT_PRI					tempPRI;
var BT_PRI					BTPRI;
var BT_EnhancementsMutator	BTE;
var BTEClientData			BTEC;
var BTPPGameReplicationInfo	GRI;
var BTPPReplicationInfo		RI;
var BT_CollisionData		CD;

var int		Index;
var int		LastTime;
var int		oldUpdate;
var bool	lastUpdate;
var float	cStamp;

var Texture BSTex[5];
var bool bBoundReplication;
var bool bAlwaysShowLogo;
var bool bLogoDone;
var int LogoTime;
var float LogoFadeValue;

function Timer()
{
	Super.Timer();

	if(PlayerOwner == None || PawnOwner == None)
		return;
	if(PawnOwner.PlayerReplicationInfo.HasFlag != None)
		PlayerOwner.ReceiveLocalizedMessage(class'CTFMessage2', 0);
}

simulated function BindReplications()
{
	local Info temp;

	if(Config == None || GRI == None || BTEC == None || BTE == None)
	{
		foreach AllActors(class'Info', temp)
		{
			if(PlayerPawn(temp.Owner) == PlayerOwner)
			{
				if(temp.IsA('ClientData'))
					Config = ClientData(temp);
				else if(temp.IsA('BTEClientData'))
					BTEC = BTEClientData(temp);
			}
			else if(temp.IsA('BTPPGameReplicationInfo'))
				GRI = BTPPGameReplicationInfo(temp);
			if(temp.IsA('BT_EnhancementsMutator'))
				BTE = BT_EnhancementsMutator(temp);
		}
	}
	if(Config == None && GRI == None && BTEC == None && BTE == None)
		bBoundReplication = true;
}

simulated function DrawLogo(canvas Canvas)
{
	local int X, Y;

	X = 10;
	Y = Canvas.ClipY - 64;

	if(LogoTime > 0)
	{
		Canvas.Reset();
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);
		Canvas.DrawColor = OrangeColor * LogoFadeValue;

		Canvas.SetPos(X, Y);
		Canvas.DrawIcon(Texture'BT_HUDBunny_BTE', 0.125);

		Canvas.SetPos(X+70, Y+8);
		Canvas.DrawText("BunnyTrack Enhancements");

		Canvas.SetPos(X+70, Y+35);
		Canvas.DrawText("Say !BT to open the BT Settings");

		Canvas.Reset();
		if(LogoTime < Level.TimeSeconds)
		{
			LogoFadeValue -= 0.001;
			if(LogoFadeValue <= 0)
				bLogoDone = True;
		}
	}
	else
		LogoTime = Level.TimeSeconds + 4;
}

simulated function PostRender(canvas Canvas)
{
	local float XL, YL, XPos, YPos, FadeValue, XX, YY;
	local string Message, S, SS, SSS, SSSS;
	local int M, i, j, k, XOverflow, X, Y, z;
	local float OldOriginX;
	local CTFFlag Flag;
	local bool bAlt;
	local int Time;

	local Pawn					xPawn;
	local BT_CollisionData		xCD;
	local BT_CollisionPawn		xCP, CP;
	local TournamentPlayer		xTP;

	HUDSetup(canvas);
	if(PawnOwner == None || PlayerOwner.PlayerReplicationInfo == None)
		return;

	if(bShowInfo)
	{
		ServerInfo.RenderInfo(Canvas);
		return;
	}
/*
==========================================================
*/
	if(!bBoundReplication)
		BindReplications();
	if(BTEC != None)
	{
		if(!bLogoDone)
			if(BTE.bAlwaysShowLogo || BTEC.NeverOpened)
				DrawLogo(Canvas);

		if(BTEC.BrightSkins || BTEC.Ghosts)
		{
			foreach AllActors(class'TournamentPlayer', xTP)
			{
				if(BTEC.BrightSkins)
				{
					if(xTP.MultiSkins[0] != BSTex[xTP.PlayerReplicationInfo.Team])
					{
						xTP.bUnlit = true;
						xTP.MultiSkins[0] = BSTex[xTP.PlayerReplicationInfo.Team];
						xTP.MultiSkins[1] = BSTex[xTP.PlayerReplicationInfo.Team];
						xTP.MultiSkins[2] = BSTex[xTP.PlayerReplicationInfo.Team];
						xTP.MultiSkins[3] = BSTex[xTP.PlayerReplicationInfo.Team];
					}
					if(xTP.Weapon != None)
					{
						if(xTP.Weapon.MultiSkins[0] != BSTex[xTP.PlayerReplicationInfo.Team])
						{
							xTP.Weapon.bUnlit = true;
							xTP.Weapon.MultiSkins[0] = BSTex[xTP.PlayerReplicationInfo.Team];
							xTP.Weapon.MultiSkins[1] = BSTex[xTP.PlayerReplicationInfo.Team];
							xTP.Weapon.MultiSkins[2] = BSTex[xTP.PlayerReplicationInfo.Team];
							xTP.Weapon.MultiSkins[3] = BSTex[xTP.PlayerReplicationInfo.Team];
							xTP.Weapon.MultiSkins[4] = BSTex[xTP.PlayerReplicationInfo.Team];
							xTP.Weapon.MultiSkins[5] = BSTex[xTP.PlayerReplicationInfo.Team];
							xTP.Weapon.MultiSkins[6] = BSTex[xTP.PlayerReplicationInfo.Team];
							xTP.Weapon.MultiSkins[7] = BSTex[xTP.PlayerReplicationInfo.Team];
						}
					}
				}
				if(BTEC.Ghosts)
				{
					if(xTP.Style != STY_Translucent)
						xTP.Style = STY_Translucent;
					if(xTP.Weapon != None && xTP.Weapon.Style != STY_Translucent)
						xTP.Weapon.Style = STY_Translucent;
				}
			}
		}

		if(BTEC.ShowCollisions)
		{
			if(CD == None)
			{
				Foreach AllActors(class'BT_CollisionData', xCD)
				{
					CD = xCD;
					CD.DrawCollisionActors(PlayerOwner);
				}
			}
		}
		else
			CD = None;

		if(BTEC.WallHack || BTEC.ShowPlayerCollisions)
		{
			if(!Pawn(Owner).PlayerReplicationInfo.bWaitingPlayer && Pawn(Owner).PlayerReplicationInfo.bIsSpectator)
			{
				foreach AllActors(class'Pawn', xPawn)
				{
					if(BTEC.WallHack)
					{
						if(xPawn != PawnOwner || (xPawn == PawnOwner && Pawn(Owner).bBehindView))
						{
							Canvas.DrawActor(xPawn, false, true);
							xPawn.bHidden = false;
						}
					}

					if(BTEC.ShowPlayerCollisions)
					{
						if(!xPawn.bSpecialLit && !xPawn.IsA('Spectator'))
						{
							CP						= Spawn(class'BT_CollisionPawn', , , xPawn.Location);
							CP.LocalPlayer			= PlayerPawn(Owner);
							CP.CentralLoc			= xPawn.Location;
							CP.myPawn				= xPawn;
							CP.Initialize(xPawn.CollisionRadius, xPawn.CollisionHeight);
							xPawn.bSpecialLit		= true;
						}
					}
				}
				if(BTEC.WallHack && BTEC.ShowPlayerCollisions)
				{
					Foreach AllActors(class'BT_CollisionPawn', xCP)
					{
						if(!xCP.bHide)
						{
							xCP.bWallhack = true;
							Canvas.DrawActor(xCP, false, true);
						}
					}
				}
			}
		}
	}
/*
==========================================================
*/
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	OldOriginX = Canvas.OrgX;
	// Master message short queue control loop.
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.StrLen("TEST", XL, YL);
	Canvas.SetClip(768*Scale - 10, Canvas.ClipY);
	bDrawFaceArea = false;
	if ( !bHideFaces && !PlayerOwner.bShowScores && !bForceScores && !bHideHUD && !PawnOwner.PlayerReplicationInfo.bIsSpectator && (Scale >= 0.4) )
	{
		DrawSpeechArea(Canvas, XL, YL);
		bDrawFaceArea = (FaceTexture != None) && (FaceTime > Level.TimeSeconds);
		if (bDrawFaceArea)
		{
			if ( !bHideHUD && ((PawnOwner.PlayerReplicationInfo == None) || !PawnOwner.PlayerReplicationInfo.bIsSpectator) )
				Canvas.SetOrigin( FMax(YL*4 + 8, 70*Scale) + 7*Scale + 6 + FaceAreaOffset, Canvas.OrgY );
		}
	}

	for (i = 0; i < 4; i++)
	{
		if (ShortMessageQueue[i].Message != None)
		{
			j++;

			if (bResChanged || ShortMessageQueue[i].XL == 0)
			{
				if (ShortMessageQueue[i].Message.Default.bComplexString)
					Canvas.StrLen(ShortMessageQueue[i].Message.Static.AssembleString(self,ShortMessageQueue[i].Switch,ShortMessageQueue[i].RelatedPRI,ShortMessageQueue[i].StringMessage),ShortMessageQueue[i].XL, ShortMessageQueue[i].YL);
				else
					Canvas.StrLen(ShortMessageQueue[i].StringMessage, ShortMessageQueue[i].XL, ShortMessageQueue[i].YL);
				Canvas.StrLen("TEST", XL, YL);
				ShortMessageQueue[i].numLines = 1;
				if (ShortMessageQueue[i].YL > YL)
				{
					ShortMessageQueue[i].numLines++;
					for (k = 2; k < 4-i; k++)
					{
						if (ShortMessageQueue[i].YL > YL*k)
							ShortMessageQueue[i].numLines++;
					}
				}
			}

			// Keep track of the amount of lines a message overflows, to offset the next message with.
			Canvas.SetPos(6, 2 + YL * YPos);
			YPos += ShortMessageQueue[i].numLines;
			if (YPos > 4)
				break;

			if (ShortMessageQueue[i].Message.Default.bComplexString)
			{
				// Use this for string messages with multiple colors.
				ShortMessageQueue[i].Message.Static.RenderComplexMessage(Canvas,ShortMessageQueue[i].XL,  YL,
				ShortMessageQueue[i].StringMessage,ShortMessageQueue[i].Switch,ShortMessageQueue[i].RelatedPRI,
				None,ShortMessageQueue[i].OptionalObject);
			}
			else
			{
				if(BTEC.MuteAnnouncerAndHUDMessages && (ClassIsChildOf(ShortMessageQueue[i].Message, class'CTFMessage') || ClassIsChildOf(ShortMessageQueue[i].Message, class'DeathMatchMessage')))// || ClassIsChildOf(ShortMessageQueue[i].Message, class'TimeMessage')))
					Canvas.DrawColor = GoldColor;
				else
					Canvas.DrawColor = ShortMessageQueue[i].Message.Default.DrawColor;

				Canvas.DrawText(ShortMessageQueue[i].StringMessage, False);
			}
		}
	}

	Canvas.DrawColor = WhiteColor;
	Canvas.SetClip(OldClipX, Canvas.ClipY);
	Canvas.SetOrigin(OldOriginX, Canvas.OrgY);

	if (PlayerOwner.bShowScores || bForceScores)
	{
		if (PlayerOwner.Scoring == None && PlayerOwner.ScoringType != None)
			PlayerOwner.Scoring = Spawn(PlayerOwner.ScoringType, PlayerOwner);
		if (PlayerOwner.Scoring != None)
		{
			PlayerOwner.Scoring.OwnerHUD = self;
			PlayerOwner.Scoring.ShowScores(Canvas);
			if (PlayerOwner.Player.Console.bTyping)
				DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);
			return;
		}
	}

	YPos = FMax(YL * 4 + 8, 70 * Scale);
	if (bDrawFaceArea)
		DrawTalkFace( Canvas,0, YPos );
	if (j > 0)
	{
		bDrawMessageArea = True;
		MessageFadeCount = 2;
	}
	else
		bDrawMessageArea = False;

	if(!bHideCenterMessages)
	{
		// Master localized message control loop.
		for (i = 0; i < 10; i++)
		{
			if (LocalMessages[i].Message != None)
			{
				if (LocalMessages[i].Message.Default.bFadeMessage && Level.bHighDetailMode)
				{
					Canvas.Style = ERenderStyle.STY_Translucent;
					FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);
					if (FadeValue > 0.0)
					{
						if (bResChanged || LocalMessages[i].XL == 0)
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
					if (bResChanged || LocalMessages[i].XL == 0)
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

	if((!PlayerOwner.bBehindView || (BTEC != None && BTEC.BehindviewCrosshair)) && PawnOwner.Weapon != None && Level.LevelAction == LEVACT_None)
	{
		Canvas.DrawColor = WhiteColor;
		PawnOwner.Weapon.PostRender(Canvas);
		if(!PawnOwner.Weapon.bOwnsCrossHair)
			DrawScaledCH(Canvas);
	}

	if(PawnOwner != None)
	{
		if(PawnOwner.bIsPlayer && !bHideHUD)
		{
			SetInfo(PawnOwner.PlayerReplicationInfo);
			//	DRAW NEW LIVE FEED
			if(PawnOwner != Owner)
			{
				Canvas.bCenter = true;
				Canvas.Style = ERenderStyle.STY_Normal;	
				Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);
				Canvas.StrLen("test", XX, YY);
				Canvas.SetPos(0, Canvas.ClipY - YY * 0.666 - 0.0833 * Canvas.ClipY);

				Canvas.DrawColor = TeamColor[PawnOwner.PlayerReplicationInfo.Team];

				DrawShadowText(Canvas, PawnOwner.PlayerReplicationInfo.PlayerName, True);

				//	RESET EVERYTHING
				Canvas.bCenter = false;
				Canvas.DrawColor = WhiteColor;
				Canvas.Style = Style;
				Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
			}
			//	DRAW INFO FOR PLAYERS
			if(!Pawn(Owner).PlayerReplicationInfo.bIsSpectator)
			{
				if(GRI != None)
				{
					if(GRI.bShowAntiBoostStatus)
						DrawAntiBoostStatus(Canvas);
					DrawCP_TimesStatus(Canvas, GRI.bShowAntiBoostStatus);
				}
			}
			//	DRAW TIMER
			if(RI != None && !PawnOwner.PlayerReplicationInfo.bWaitingPlayer && !PawnOwner.PlayerReplicationInfo.bIsSpectator)
			{
				//see if server sent a new runtime
				if(oldUpdate != RI.runTime)
				{
					oldUpdate = RI.runTime;
					cStamp = Level.TimeSeconds;
				}
				//update HUD-Timer if the Game is not ended and the player is on a run
				if(!PlayerOwner.IsInState('GameEnded') && !RI.bNeedsRespawn)
				{
					//round down
					//Time = RI.runTime/10;
					//this is about the current time: runs on until server saw a cap; this may cause the timer to jump back a bit
					Time = (oldUpdate + int((Level.TimeSeconds - cStamp) * 90.9090909))/10;//move on from last update until server sends a new one
					LastTime = Time;
					lastUpdate = False;
				}
				else
				{
					oldUpdate = 0;//either dead or game over -> reset
					if(!lastUpdate && !RI.bBoosted)//get the captime replicated, but only show deciseconds
					{
						Time = RI.LastCap / 10;
						LastTime = Time;
						lastUpdate = True;
					}
					Time = LastTime;
				}
				DrawHUDTimes(Canvas, Time / 600, Time % 600);
			}
		}
	}

	if (bStartUpMessage && Level.TimeSeconds < 5)
	{
		bStartUpMessage = false;
		PlayerOwner.SetProgressTime(7);
	}
	if (PlayerOwner.ProgressTimeOut > Level.TimeSeconds && !bHideCenterMessages && !BTEC.MuteAnnouncerAndHUDMessages)
		DisplayProgressMessage(Canvas);

	// Display MOTD
	if (MOTDFadeOutTime > 0.0)
		DrawMOTD(Canvas);

	if(!bHideHUD)
	{
		if(!PawnOwner.PlayerReplicationInfo.bIsSpectator)
		{
			Canvas.Style = Style;

			// Draw Ammo
			if (!bHideAmmo)
				DrawAmmo(Canvas);

			// Draw Health/Armor status + Boots
			if(BTPRI != None)
				DrawStatuz(Canvas);	// NEW AND IMPROVED
			else
				DrawStatus(Canvas);	// IF BTPRI ISNT WORKING

			if(BTEC != None && BTEC.ShowSpeedMeter)
				DrawSpeed(Canvas, PawnOwner);

			// Display Weapons
			if (!bHideAllWeapons)
				DrawWeapons(Canvas);
			else if (Level.bHighDetailMode && PawnOwner == PlayerOwner && PlayerOwner.Handedness == 2)
			{
				// if weapon bar hidden and weapon hidden, draw weapon name when it changes
				if (PawnOwner.PendingWeapon != None)
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
				else if (WeaponNameFade > 0 && PawnOwner.Weapon != None)
				{
					Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
					Canvas.DrawColor = PawnOwner.Weapon.NameColor;
					if (WeaponNameFade < 1)
						Canvas.DrawColor = Canvas.DrawColor * WeaponNameFade;
					Canvas.SetPos(Canvas.ClipX - 360 * Scale, Canvas.ClipY - 64 * Scale);
					Canvas.DrawText(PawnOwner.Weapon.ItemName, False);
				}
			}
			// Display Frag count
			if (!bAlwaysHideFrags && !bHideFrags)
				DrawFragCount(Canvas);
		}
		// Team Game Synopsis
		if (!bHideTeamInfo)
			DrawGameSynopsis(Canvas);

		// Display Identification Info
		if (PawnOwner == PlayerOwner)
			DrawIdentifyInfo(Canvas);

		if (HUDMutator != None)
			HUDMutator.PostRender(Canvas);

		if (PlayerOwner.GameReplicationInfo != None && PlayerPawn(Owner).GameReplicationInfo.RemainingTime > 0)
		{
			if (TimeMessageClass == None)
				TimeMessageClass = class<CriticalEventPlus>(DynamicLoadObject("Botpack.TimeMessage", class'Class'));

			if (PlayerOwner.GameReplicationInfo.RemainingTime <= 300 && PlayerOwner.GameReplicationInfo.RemainingTime != LastReportedTime)
			{
				LastReportedTime = PlayerOwner.GameReplicationInfo.RemainingTime;
				if (PlayerOwner.GameReplicationInfo.RemainingTime <= 30)
				{
					bTimeValid = (bTimeValid || PlayerOwner.GameReplicationInfo.RemainingTime > 0);
					if (PlayerOwner.GameReplicationInfo.RemainingTime == 30)
						TellTime(5);
					else if (bTimeValid && PlayerOwner.GameReplicationInfo.RemainingTime <= 10)
						TellTime(16 - PlayerOwner.GameReplicationInfo.RemainingTime);
				}
				else if (PlayerOwner.GameReplicationInfo.RemainingTime % 60 == 0)
				{
					M = PlayerOwner.GameReplicationInfo.RemainingTime/60;
					TellTime(5 - M);
				}
			}
		}
	}
	if (PlayerOwner.Player.Console.bTyping)
		DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);

	if (PlayerOwner.bBadConnectionAlert && PlayerOwner.Level.TimeSeconds > 5)
	{
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawColor = WhiteColor;
		Canvas.SetPos(Canvas.ClipX - (64 * Scale), Canvas.ClipY / 2);
		Canvas.DrawIcon(texture'DisconnectWarn', Scale);
	}

	if ( (PlayerOwner == None) || (PawnOwner == None) || (PlayerOwner.GameReplicationInfo == None) || (PawnOwner.PlayerReplicationInfo == None) || ((PlayerOwner.bShowMenu || PlayerOwner.bShowScores) && (Canvas.ClipX < 640)) )
		return;

	if(!bHideHUD && !bHideTeamInfo)
	{
		X = Canvas.ClipX - 70 * Scale;
		Y = Canvas.ClipY - 350 * Scale;

		Canvas.SetPos(X, Y);
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor = ChallengeTeamHUD(PlayerOwner.myHUD).TeamColor[0];
		
		if(BTE != None)
		{
			if(BTE.HUDBunnyType == 0)
				Canvas.DrawIcon(Texture'BT_HUDBunny_BTNet', Scale * 0.5);
			else if(BTE.HUDBunnyType == 1)
				Canvas.DrawIcon(Texture'BT_HUDBunny_BTE', Scale * 0.125);
			else if(BTE.HUDBunnyType == 2)
				Canvas.DrawIcon(Texture'BT_HUDBunny_BTPP', Scale * 2);
		}
		else
			Canvas.DrawIcon(Texture'BT_HUDBunny_BTPP', Scale * 2);

		DrawBigNum(Canvas, int(TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo).Teams[0].Score), Canvas.ClipX - 144 * Scale, Canvas.ClipY - 336 * Scale - (150 * Scale * 0), 1);
		Canvas.SetPos(X, Y - 150 * Scale);
		Canvas.DrawColor = ChallengeTeamHUD(PlayerOwner.myHUD).TeamColor[1];

		if(BTE != None)
		{
			if(BTE.HUDBunnyType == 0)
				Canvas.DrawIcon(Texture'BT_HUDBunny_BTNet', Scale * 0.5);
			else if(BTE.HUDBunnyType == 1)
				Canvas.DrawIcon(Texture'BT_HUDBunny_BTE', Scale * 0.125);
			else if(BTE.HUDBunnyType == 2)
				Canvas.DrawIcon(Texture'BT_HUDBunny_BTPP', Scale * 2);
		}
		else
			Canvas.DrawIcon(Texture'BT_HUDBunny_BTPP', Scale * 2);

		DrawBigNum(Canvas, int(TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo).Teams[1].Score), Canvas.ClipX - 144 * Scale, Canvas.ClipY - 336 * Scale - (150 * Scale * 1), 1);
		Canvas.Style = ERenderStyle.STY_Normal;
	}
}
//==========================================================
simulated function DrawScaledCH(Canvas canvas)
{
	local float XScale, PickDiff;
	local float XLength;
	local texture T;

 	if(Crosshair >= CrosshairCount)
		return;

	if(BTEC == None || BTEC.CrosshairScale < 0)
		XScale = 1;
	else
		XScale = BTEC.CrosshairScale;

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
//==========================================================
simulated function TellTime(int num)
{
	if(BTEC.MuteAnnouncerAndHUDMessages)
		PlayerOwner.ReceiveLocalizedMessage(Class'BT_TimeMessageWithoutSound', Num);
	else
		PlayerOwner.ReceiveLocalizedMessage(TimeMessageClass, Num);
}
//==========================================================
simulated function LocalizedMessage(class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString)
{
	if(BTEC.MuteAnnouncerAndHUDMessages)
	{
		if(ClassIsChildOf(Message, class'CTFMessage'))
		{
			PlayerOwner.ReceiveLocalizedMessage(Class'BT_CTFMessage', Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
			return;
		}
		else if(ClassIsChildOf(Message, class'DeathMatchMessage'))
		{
			PlayerOwner.ReceiveLocalizedMessage(Class'BT_DeathMatchMessage', Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
			return;
		}
		else if(CriticalString != "")
		{
			PlayerOwner.MyHUD.Message(RelatedPRI_1, CriticalString, 'None');
			return;
		}
	}
	Super.LocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString);
}
//==========================================================
function SetInfo(PlayerReplicationInfo PRI)
{
	local int i;
	local bool bInit, bFoundRI, bFoundBTPRI;
	local ReplicationInfo Rinfo;

	// See if it's already initialized
	for(i = 0; i < Index; i++)
	{
		if(PI[i].PRI == PRI)
		{
			BTPRI	= PI[i].BTPRI;
			RI		= PI[i].RI;
			bInit = true;
			break;
		}
	}
	if(!bInit)	// Not initialized, find the RI + BTPRI
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
			else if( Rinfo.IsA('BT_PRI') )
			{
				if(BT_PRI(Rinfo).PlayerID == PRI.PlayerID)
				{
					BTPRI = BT_PRI(Rinfo);
					bFoundBTPRI = true;
				}
			}
		}
		if(bFoundRI && bFoundBTPRI)	// Init the slot - on newly found BTPRI-RI
		{
			if(Index < 32)	// use empty elements in array
			{
				PI[Index].PRI = PRI;
				PI[Index].RI = RI;
				PI[Index].BTPRI = BTPRI;
				Index++;
			}
			else	// not enough empty elements, use an old element
			{
				for(i = 0; i < 32; i++)
				{
					if (PI[i].BTPRI == None)
						break;	// assign here
				}
				PI[i].PRI = PRI;
				PI[i].RI = RI;
				PI[i].BTPRI = BTPRI;
			}
		}
	}
}
/*##################################################################################################
##
## Draw Functions
##
##################################################################################################*/
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
			if(BTPRI.bShieldBelt)
			{
				Canvas.DrawColor = BaseColor;
				Canvas.DrawColor.B = 0;
				Canvas.SetPos(X, 0);
				Canvas.DrawIcon(DollBelt, StatScale);
			}
			if(BTPRI.bChestArmor)
			{
				Canvas.DrawColor = HUDColor * FMin(0.01 * BTPRI.ChestAmount, 1);
				Canvas.SetPos(X, 0);
				Canvas.DrawTile(Doll, 128 * StatScale, 64 * StatScale, 128, 0, 128, 64);
			}
			if(BTPRI.bThighArmor)
			{
				Canvas.DrawColor = HUDColor * FMin(0.02 * BTPRI.ThighAmount, 1);
				Canvas.SetPos(X, 64 * StatScale);
				Canvas.DrawTile(Doll, 128 * StatScale, 64 * StatScale, 128, 64, 128, 64);
			}
			if(BTPRI.bJumpBoots)
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

	if(BTPRI.bShieldBelt)
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = WhiteColor;
	DrawBigNum(Canvas, BTPRI.ArmorAmount, X + 4 * Scale, Y + 16 * Scale, 1);

	if(BTPRI.bJumpBoots)
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
		Canvas.DrawTile(Texture'BT_HUDBoots', 128 * Scale, 64 * Scale, 0, 0, 128.0, 64.0);
		Canvas.DrawColor = WhiteColor;
		DrawBigNum(Canvas, BTPRI.BootCharges, X + 4 * Scale, Y + 16 * Scale, 1);
	}
}
//=========================================================================
simulated function bool DrawIdentifyInfo(canvas Canvas)
{
	local BT_PRI searchPRI;
	local float XL, YL;
	local Pawn P;

	if(!TraceIdentify(Canvas))
		return false;

	if(IdentifyTarget.PlayerName != "")
	{
		if(tempPRI == None || tempPRI.PlayerID != IdentifyTarget.PlayerID)
		{
			foreach AllActors(class'BT_PRI', searchPRI)
				if(searchPRI.PlayerID == IdentifyTarget.PlayerID)
					tempPRI = searchPRI;
		}
		if(tempPRI != None)
		{
			Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);
			DrawTwoColorID(Canvas,IdentifyName, IdentifyTarget.PlayerName, Canvas.ClipY - 256 * Scale);

			Canvas.StrLen("TEST", XL, YL);
			P = Pawn(IdentifyTarget.Owner);
			Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
			if (P != None)
				DrawTwoColorID(Canvas,IdentifyHealth,string(P.Health), (Canvas.ClipY - 256 * Scale) + 1.5 * YL);
		}
	}
	return true;
}
//=========================================================================
simulated function DrawSpeed(Canvas Canvas, Pawn P)
{
	local int HoriSpeed;
	local int VertSpeed;
	local float YY, XX;

	HoriSpeed = Sqrt(P.Velocity.X * P.Velocity.X + P.Velocity.Y * P.Velocity.Y);
	VertSpeed = Abs(P.Velocity.Z);

	Canvas.bCenter = true;

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = WhiteColor;
	Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);
	Canvas.StrLen("test", XX, YY);

	Canvas.SetPos(0, (Canvas.ClipY - YY * 0.666 - 0.0833 * Canvas.ClipY) - YY * 2);
	DrawShadowText(Canvas, string(HoriSpeed));

	Canvas.SetPos(0, (Canvas.ClipY - YY * 0.666 - 0.0833 * Canvas.ClipY) - YY * 3);
	DrawShadowText(Canvas, string(VertSpeed));

	Canvas.bCenter = false;
}
//==========================================================
simulated function DrawHUDTimes(Canvas Canvas, int Minutes, int Seconds)
{
	local int d;
	local float TimerScale, W, H, SW;

	Canvas.Style = ERenderStyle.STY_Normal;

	if(BTEC != None && BTEC.CustomTimer)
	{
		TimerScale = Scale * BTEC.TimerScale;
		Canvas.CurX = (Canvas.ClipX / 2 - 86.5 * TimerScale) + BTEC.LocationX;
		Canvas.CurY = 4 + BTEC.LocationY;
	}
	else
	{
		TimerScale = Scale;
		Canvas.CurY = 4;
		Canvas.CurX = Canvas.ClipX / 2 - 86.5 * TimerScale;
	}

	if(Minutes > 99)//too long run time: show -:-- in red
	{
		Canvas.DrawColor = RedColor;
		if(BTEC != None && BTEC.CustomTimer)
			Canvas.CurX = (Canvas.ClipX / 2 - 57 * TimerScale) + BTEC.LocationX;
		else
			Canvas.CurX = Canvas.ClipX / 2 - 57 * TimerScale;

		//	-:
		DrawShadowTile(Canvas, Texture'BT_HUDTimer', TimerScale*50, 35*TimerScale, 0, 64, 50.0, 35.0);
		Canvas.CurX += 7*TimerScale;

		//	-
		DrawShadowTile(Canvas, Texture'BT_HUDTimer', TimerScale*25, 35*TimerScale, 0, 64, 25.0, 35.0);
		Canvas.CurX += 7*TimerScale;

		//	-
		DrawShadowTile(Canvas, Texture'BT_HUDTimer', TimerScale*25, 35*TimerScale, 0, 64, 25.0, 35.0);
	}
	else //	show actual timer
	{
		if(RI != None && RI.bNeedsRespawn)	//Captime/reset on death in grey
			Canvas.DrawColor = GreyColor;
		else if(Minutes < 100)
		{
			if(BTEC != None && BTEC.CustomTimer)
			{
				Canvas.DrawColor.R = BTEC.Red;
				Canvas.DrawColor.G = BTEC.Green;
				Canvas.DrawColor.B = BTEC.Blue;
			}
			else
				Canvas.DrawColor = YellowColor;
		}

		if ( Minutes >= 10 )
		{
			d = Minutes/10;
			DrawShadowTile(Canvas, Texture'BT_HUDTimer', TimerScale*25, 35*TimerScale, d*25, 0, 25.0, 35.0);
			Canvas.CurX += 7*TimerScale;
			Minutes= Minutes - 10 * d;
		}
		else
		{
			//leading 0
			DrawShadowTile(Canvas, Texture'BT_HUDTimer', TimerScale*25, 35*TimerScale, 0, 0, 25.0, 35.0);
			Canvas.CurX += 7*TimerScale;
		}

		//single digit minutes
		DrawShadowTile(Canvas, Texture'BT_HUDTimer', TimerScale*25, 35*TimerScale, Minutes*25, 0, 25.0, 35.0);
		Canvas.CurX += 3*TimerScale;

		// ":" 
		DrawShadowTile(Canvas, Texture'BT_HUDTimer', TimerScale*12, 35*TimerScale, 30, 64, 12.0, 35.0);
		Canvas.CurX += 5 * TimerScale;

		//Seconds 1
		d = Seconds/100;
		DrawShadowTile(Canvas, Texture'BT_HUDTimer', TimerScale*25, 35*TimerScale, 25*d, 0, 25.0, 35.0);
		Canvas.CurX += 7*TimerScale;

		//Seconds 2
		Seconds -=  100*d;
		d = Seconds / 10;
		DrawShadowTile(Canvas, Texture'BT_HUDTimer', TimerScale*25, 35*TimerScale, 25*d, 0, 25.0, 35.0);
		Canvas.CurX += 7*TimerScale;

		// "."
		DrawShadowTile(Canvas, Texture'BT_HUDTimer', TimerScale*12, 32*TimerScale, 32, 46, 12.0, 32.0);
		Canvas.CurX += 3 * TimerScale;

		//Deciseconds
		Seconds -= 10*d;
		DrawShadowTile(Canvas, Texture'BT_HUDTimer', TimerScale*16, 42*TimerScale, 25*Seconds, 0, 25.0, 64.0);
	}
	Canvas.DrawColor = GoldColor;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.Font = Canvas.SmallFont;

	if(RI.bBoosted)
	{
		Canvas.TextSize("YOU WERE BOOSTED, RECORD WILL NOT COUNT", W, H);
		Canvas.SetPos(Canvas.ClipX/2 - W/2, 50*TimerScale+2);
		Canvas.DrawColor = RedColor;
		DrawShadowText(Canvas, "YOU WERE BOOSTED, RECORD WILL NOT COUNT");
	}

	if(!Pawn(Owner).PlayerReplicationInfo.bIsSpectator)
	{
		Canvas.Reset();
		Canvas.SetPos(5, Canvas.ClipY/2);
		Canvas.Font = Canvas.SmallFont;
		Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).WhiteColor;
		DrawShadowText(Canvas, "SERVER RECORD:");
		Canvas.TextSize("SERVER RECORD:", W, H);
		Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).GoldColor;
		Canvas.SetPos(5, Canvas.ClipY/2 + H+1);
		DrawShadowText(Canvas, GRI.MapBestPlayer);
		Canvas.TextSize(GRI.MapBestPlayer, W, H);
		Canvas.SetPos(5+W, Canvas.ClipY/2 + H+1);
		Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).WhiteColor;
		DrawShadowText(Canvas, " - ");
		Canvas.TextSize(" - ", SW, H);
		Canvas.SetPos(5+W+SW, Canvas.ClipY/2 + H+1);
		Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).GreenColor;
		DrawShadowText(Canvas, GRI.MapBestTime);
		Canvas.SetPos(5, Canvas.ClipY/2 + 2*H+2);
		Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).WhiteColor;
		DrawShadowText(Canvas, "YOUR RECORD:");
		Canvas.SetPos(5, Canvas.ClipY/2 + 3*H+3);
		Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).GreenColor;
		DrawShadowText(Canvas, Config.BestTimeStr);
	}
}

simulated function DrawAntiBoostStatus(Canvas Canvas)
{
	local float W, H;

	Canvas.Reset();
	Canvas.Font = Canvas.SmallFont;
	Canvas.TextSize("ANTIBOOST: ", W, H);
	Canvas.SetPos(5, Canvas.ClipY/2-1.5*H-1);
	Canvas.DrawColor = WhiteColor;
	DrawShadowText(Canvas, "ANTIBOOST: ");
	Canvas.SetPos(5+W, Canvas.ClipY/2-1.5*H-1);
	if(Config.bAntiBoost)
	{
		Canvas.DrawColor = GreenColor;
		DrawShadowText(Canvas, "ON");
	}
	else
	{
		Canvas.DrawColor = RedColor;
		DrawShadowText(Canvas, "OFF");
	}
}

simulated function DrawCP_TimesStatus(Canvas Canvas, bool antiBoostThere)
{
	local float W, H;

	Canvas.Reset();
	Canvas.Font = Canvas.SmallFont;
	Canvas.TextSize("CP-TIMES: ", W, H);
	if(antiBoostThere)
		Canvas.SetPos(5, Canvas.ClipY/2-3.0*H-1);
	else
		Canvas.SetPos(5, Canvas.ClipY/2-1.5*H-1);
	Canvas.DrawColor = WhiteColor;
	DrawShadowText(Canvas, "CP-TIMES: ");
	if(antiBoostThere)
		Canvas.SetPos(5+W, Canvas.ClipY/2-3.0*H-1);
	else
		Canvas.SetPos(5+W, Canvas.ClipY/2-1.5*H-1);
	if(Config.bCheckpoints)
	{
		Canvas.DrawColor = GreenColor;
		DrawShadowText(Canvas, "ON");
	}
	else
	{
		Canvas.DrawColor = RedColor;
		DrawShadowText(Canvas, "OFF");
	}
}

function DrawShadowTile(Canvas Canvas, Texture Tex, float XL, float YL, float U, float V, float UL, float VL)
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

function DrawShadowText(Canvas Canvas, coerce string Text, optional bool Param)
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

simulated function string trimZeros(float number)
{
	local string tmp;

	tmp = number $ "";
	while (tmp != "0" && (Right(tmp, 1) == "0" || Right(tmp, 1) == "."))
	{
		if (Right(tmp, 1) == ".")
		{
			tmp = Left(tmp, Len(tmp)-1);
			break;
		}
		else if (Right(tmp, 1) == "0")
			tmp = Left(tmp, Len(tmp)-1);
	}
	return tmp;
}

function string ParseDelimited(string Text, string Delimiter, int Count, optional bool bToEndOfLine)
{
	local string Result, S;
	local int Found, i;

	Result = "";
	Found = 1;

	for(i = 0; i < Len(Text); i++)
	{
		S = Mid(Text, i, 1);
		if(InStr(Delimiter, S) != -1)
		{
			if(Found == Count)
			{
				if(bToEndOfLine)
					return Result$Mid(Text, i);
				else
					return Result;
			}
			Found++;
		}
		else
		{
			if(Found >= Count)
				Result = Result $ S;
		}
	}
	return Result;
}
simulated function DrawTeam(Canvas Canvas, TeamInfo TI){}
//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
	IdentifyName=""
	IdentifyHealth=""
	LogoFadeValue=1
	GreyColor=(R=170,G=170,B=170)
	YellowColor=(R=127,G=127,B=0)
    PurpleColor=(R=138,G=43,B=217,A=0)
    OrangeColor=(R=255,G=88)
	TeamColor(0)=(R=255)
	TeamColor(1)=(G=128,B=255)
	TeamColor(2)=(G=255)
	TeamColor(3)=(R=255,G=255)
	TeamColor(4)=(R=127,G=127,B=127)
	AltTeamColor(0)=(R=200)
	AltTeamColor(1)=(G=94,B=187)
	AltTeamColor(2)=(G=128)
	AltTeamColor(3)=(R=255,G=255,B=128)
	AltTeamColor(4)=(R=96,G=96,B=96)
	BSTex(0)=Texture'BT_BS_0'
	BSTex(1)=Texture'BT_BS_1'
	BSTex(2)=Texture'BT_BS_2'
	BSTex(3)=Texture'BT_BS_3'
	BSTex(4)=Texture'BT_BS_4'
}