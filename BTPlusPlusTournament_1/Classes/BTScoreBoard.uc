/*
	BTPlusPlus Tournament is an improved version of BTPlusPlus 0.994
	Flaws have been corrected and extra features have been added
	This Tournament vesion is created by OwYeaW

	BTPlusPlus 0.994
	Copyright (C) 2004-2006 Damian "Rush" Kaczmarek

	This program is free software; you can redistribute and/or modify
	it under the terms of the Open Unreal Mod License version 1.1.
*/

class BTScoreBoard extends UnrealCTFScoreBoard;

struct PlayerInfo
{
	var PlayerReplicationInfo PRI;
	var BTPPReplicationInfo RI;
	var string captime;
	var int captimeInt;
};
var PlayerInfo PI[32];

struct FlagData
{
	var string Prefix;
	var texture Tex;
};
var FlagData FD[32];	// there can be max 32 (players?) so max 32 different flags
var int saveindex;		// new loaded flags will be saved in FD[index]

var string 		Spectators[32];
var PlayerPawn	PlayerOwner;

var int		tempCaps[32];
var int		tempDeaths[32];
var float	tempTime[32];

var BTPPGameReplicationInfo	GRI;
var BTPPReplicationInfo		OwnerRI;
var ClientData				Config;

var const int	MAX_CAPTIME;
var float		scale;
var bool 		Initialized;
var int			Index;

var Color BlackColor;
var color OrangeColor;

var bool	bGameEndTime;
var string	GameEndTime;

// 	THIS MAKES SURE THE PERSONAL RECORD SHOWS UP ON THE SCOREBOARD
simulated event postbeginplay()
{
	if (!Initialized)
	{
		Initialized = !Initialized;
		foreach allactors(class'clientdata',config)
			break;
	}
	Super.PostBeginPlay();
}

// 	REFRESHES SPECTATORS LIST
function Timer()
{
	local int i, k;
	local PlayerReplicationInfo PRI;

	if(PlayerOwner == None)
		PlayerOwner = PlayerPawn(Owner);

	for(k = 0;k < 32;k++)
	{
		PRI = PlayerOwner.GameReplicationInfo.PRIArray[k];
		if(PRI == None)
			break;
		if(PRI.bIsSpectator && !PRI.bWaitingPlayer && PRI.PlayerName != "Player")
			Spectators[i++] = PRI.PlayerName;
	}
	while(i<32)
		Spectators[i++] = "";
}

// 	THIS MAKES SURE THE PERSONAL RECORD SHOWS UP ON THE SCOREBOARD
simulated function BindReplications()
{
	local Info temp;
	// Spectators doesn't have Replicationinfo spawned in BTPlusPlus.InitNewSpec(), if we don't check against the spectator, the function would run every tick cause RI would be always None
	if((OwnerRI == None && (!PlayerOwner.PlayerReplicationInfo.bIsSpectator || PlayerOwner.PlayerReplicationInfo.bWaitingPlayer)) || Config == None || GRI == None )
	{
		foreach AllActors(class'Info', temp)
		{
			if(temp.Owner == PlayerOwner)
			{
				if(temp.IsA('BTPPReplicationInfo'))
					OwnerRI=BTPPReplicationInfo(temp);
				else if(temp.IsA('ClientData'))
					Config=ClientData(temp);
			}
			else if(temp.IsA('BTPPGameReplicationInfo'))
				GRI=BTPPGameReplicationInfo(temp);
		}
	}
}

//	DrawTrailer - custom version
function DrawTrailer( canvas Canvas )
{
	local int Hours, Minutes, Seconds;
	local float XL, YL, W, H, SW, XW, YW, ZW, XYZ, XLL, YLL, BW, AW;

// 	ELAPSED & REMAINING TIME	
	Canvas.DrawColor = OrangeColor;
	Canvas.bCenter = true;
	if(Canvas.ClipX < 1024)
		Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
	else
		Canvas.Font = MyFonts.GetHugeFont( Canvas.ClipX );	
	Canvas.StrLen("Test", XL, YL);
	Canvas.SetPos(0, Canvas.ClipY - YL);

	if (GRI.bMatchMode)
	{
		if (!GRI.bGameEnded)
		{
			if (GRI.bGameStarted)
			{
				if (bTimeDown || GRI.RemainingTime > 0)
				{
					bTimeDown = true;
					if (GRI.RemainingTime <= 0)
						DrawShadowText(Canvas, "~ Sudden Death ~", true);
					else
					{
						Minutes = GRI.RemainingTime / 60;
						Seconds = GRI.RemainingTime % 60;
						Canvas.SetPos(0, Canvas.ClipY - YL + 4);
						DrawShadowText(Canvas, TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
					}
				}
				else
				{
					Seconds	= GRI.ElapsedTime;
					Minutes	= Seconds / 60;
					Hours	= Minutes / 60;
					Seconds	= Seconds - (Minutes * 60);
					Minutes	= Minutes - (Hours * 60);
					DrawShadowText(Canvas, TwoDigitString(Hours)$":"$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
				}
			}
			else
				DrawShadowText(Canvas, "~ Waiting for Players ~", true);
		}
		else
			DrawShadowText(Canvas, "~ Match Ended ~", true);
	}
	else
	{
		if (GRI.bTournament)
			DrawShadowText(Canvas, "~ Match Mode Activated~", true);
		else
			DrawShadowText(Canvas, "~ No Match Mode ~", true);
	}

//	ENDGAME TEXT
	if (GRI.bGameEnded && GRI.bMatchMode)
	{
		if (GRI.GameBestTime != "")
		{
			Canvas.StrLen("Test", XLL, YLL);
			Canvas.SetPos(0, Canvas.ClipY - YL - 48);
			Canvas.DrawColor = TeamColor[GRI.GameBestPlayerTeam];
			DrawShadowText(Canvas, "Cap of the Match: "$GRI.GameBestTime $" by " $ GRI.GameBestPlayerName, true);
		}
		// WINNER TEXT
		Canvas.DrawColor = GRI.WinnerColor;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - YL - YLL -48);
		DrawShadowText(Canvas, GRI.EndStatsText, true);
		Canvas.SetPos(0, Canvas.ClipY - YL - YL - YLL -48);
		DrawShadowText(Canvas, GRI.WinnerText, true);
	}
	else if (PlayerOwner != None && PlayerOwner.Health <= 0)
	{
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - YL - YLL -48);
		Canvas.DrawColor = GreenColor;
		DrawShadowText(Canvas, "Hit [Fire] to Respawn!", true);
	}

// 	SERVER RECORD
	Canvas.bCenter = false;
	if(Canvas.ClipX < 1024)
	{
		Canvas.Font = Canvas.SmallFont;
		XYZ = 10;
	}
	else
	{
		Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
		XYZ = 20;
	}
	if(GRI.MapBestTime != "-:--")
	{
		Canvas.SetPos(5, Canvas.ClipY - XYZ);
		Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).WhiteColor;
		DrawShadowText(Canvas, "The Server Record is ", True, true);
		Canvas.TextSize("The Server Record is ", W, H);

		Canvas.SetPos(5+W, Canvas.ClipY - XYZ);
		Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).GreenColor;
		DrawShadowText(Canvas, GRI.MapBestTime, False, true);
		Canvas.TextSize(GRI.MapBestTime, ZW, H);

		Canvas.SetPos(5+W+ZW, Canvas.ClipY - XYZ);
		Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).WhiteColor;
		DrawShadowText(Canvas, " set by ", False, true);
		Canvas.TextSize(" set by ", SW, H);

		Canvas.SetPos(5+W+ZW+SW, Canvas.ClipY - XYZ);
		Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).GoldColor;
		DrawShadowText(Canvas, GRI.MapBestPlayer, False, true);
		Canvas.TextSize(GRI.MapBestPlayer$" ", XW, H);

		if(GRI.MapBestAge == "0")
		{
			Canvas.SetPos(5+W+ZW+SW+XW, Canvas.ClipY - XYZ);
			Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).WhiteColor;
			DrawShadowText(Canvas, "today", False, True);
		}
		if(GRI.MapBestAge == "1")
		{
			Canvas.SetPos(5+W+ZW+SW+XW, Canvas.ClipY - XYZ);
			Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).WhiteColor;
			DrawShadowText(Canvas, GRI.MapBestAge, False, true);
			Canvas.TextSize(GRI.MapBestAge, YW, H);

			Canvas.SetPos(5+W+ZW+SW+XW+YW, Canvas.ClipY - XYZ);
			Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).WhiteColor;
			DrawShadowText(Canvas, " day ago", False, true);
		}
		if((GRI.MapBestAge != "0") && (GRI.MapBestAge != "1"))
		{
			Canvas.SetPos(5+W+ZW+SW+XW, Canvas.ClipY - XYZ);
			Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).WhiteColor;
			DrawShadowText(Canvas, GRI.MapBestAge, False, true);
			Canvas.TextSize(GRI.MapBestAge, YW, H);

			Canvas.SetPos(5+W+ZW+SW+XW+YW, Canvas.ClipY - XYZ);
			Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).WhiteColor;
			DrawShadowText(Canvas, " days ago", False, true);
		}
	}
	else
	{
		Canvas.SetPos(5, Canvas.ClipY - XYZ);
		Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).WhiteColor;
		DrawShadowText(Canvas, "There is no Server Record yet", True, true);
	}

// 	PERSONAL RECORD
	if (!PlayerOwner.PlayerReplicationInfo.bIsSpectator)
	{
		if((Config.BestTimeStr != "-:--") && (Config.BestTimeStr != ""))
		{
			Canvas.TextSize(Config.BestTimeStr, AW, H);
			Canvas.SetPos(Canvas.ClipX - AW -5, Canvas.ClipY - XYZ);
			Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).GreenColor;
			DrawShadowText(Canvas, Config.BestTimeStr, False, true);
	
			Canvas.TextSize("Your Personal Record is ", BW, H);		
			Canvas.SetPos(Canvas.ClipX - AW - BW -5, Canvas.ClipY - XYZ);
			Canvas.DrawColor = ChallengeHUD(PlayerOwner.myHUD).WhiteColor;
			DrawShadowText(Canvas, "Your Personal Record is ", False, true);
		}
	}
}

function int GetFlagIndex(string Prefix)
{
	local int i;
	for(i=0;i<32;i++)
		if(FD[i].Prefix == Prefix)
			return i;
	FD[saveindex].Prefix = Prefix;
	FD[saveindex].Tex = texture(DynamicLoadObject(GRI.CountryFlagsPackage$"."$Prefix, class'Texture'));
	i = saveindex;
	saveindex = (saveindex+1) % 256;
	return i;
}

function ShowScores( canvas Canvas )
{
	local PlayerReplicationInfo PRI;
	local BTPPReplicationInfo BT_PRI;
	local int PlayerCount, i, CijferLengte, CijferBreedte;
	local float LoopCountTeam[4];
	local float XL, YL, XOffset, YOffset, XStart;
	local int PlayerCounts[4];
	local int LongLists[4];
	local int BottomSlot[4];
	local font CanvasFont;
	local bool bCompressed;
	local int ident;
	local TournamentGameReplicationInfo TGRI;

	TGRI = TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo);

	if(GRI == None)
	{
		foreach AllActors(class'BTPPGameReplicationInfo', GRI)
		{
			SetTimer(1.0, true); // good place to initialize our timer
			break;
		}
	}

	if(PlayerOwner == None)
		PlayerOwner = PlayerPawn(Owner);

	OwnerInfo = Pawn(Owner).PlayerReplicationInfo;
	OwnerGame = TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo);
	Canvas.Style = ERenderStyle.STY_Normal;
	DrawSpectators(Canvas, Ordered[I]);

	CanvasFont = Canvas.Font;

	DrawVictoryConditions(Canvas);

	for ( i=0; i<32; i++ )
	{
		PRI = PlayerOwner.GameReplicationInfo.PRIArray[i];
		if(PRI != None)
		{
			if(!PRI.bIsSpectator || PRI.bWaitingPlayer)
			{
				Ordered[PlayerCount] = PRI;

				PlayerCounts[PRI.Team]++;

				/////use own measure to sort////
				BT_PRI = FindInfo(PRI, ident);

				if(BT_PRI == None)
				{
					tempCaps[PlayerCount] = 0;
					tempDeaths[PlayerCount] = 999999999;
					tempTime[PlayerCount] = 600000;
				}
				else
				{
					tempCaps[PlayerCount] = BT_PRI.Caps;
					tempDeaths[PlayerCount] = BT_PRI.Runs - BT_PRI.Caps;
					if (BT_PRI.BestTime != 0)
						tempTime[PlayerCount] = BT_PRI.BestTime;
					else
						tempTime[PlayerCount] = 600000;
				}
				PlayerCount++;
			}
		}
	}

//	SORT SCORES
	SortScores(PlayerCount);
	ScoreStart = Canvas.CurY + YL*2;

//	PLAYERNAMES
	for ( I=0; I<PlayerCount; I++ )
	{
		if ( Ordered[I].Team < 4 )
		{
			if ( Ordered[I].Team % 2 == 0 )
				XOffset = (Canvas.ClipX / 4) - (Canvas.ClipX / 8);
			else
				XOffset = ((Canvas.ClipX / 4) * 3) - (Canvas.ClipX / 8);

			Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
			Canvas.StrLen("TEXT", XL, YL);
			Canvas.DrawColor = AltTeamColor[Ordered[I].Team];
			YOffset = ScoreStart + (LoopCountTeam[Ordered[I].Team] * YL);	//	+ 2

			if (LoopCountTeam[Ordered[I].Team] < 32)
				DrawNameAndPing( Canvas, Ordered[I], XOffset, YOffset, bCompressed);

			LoopCountTeam[Ordered[I].Team] += 2;
		}
	}

//	TEAM STUFF
	for ( i=0; i<4; i++ )
	{
		if ( PlayerCounts[i] > 0 )
		{
			if ( i % 2 == 0 )
				XOffset = (Canvas.ClipX / 4) - (Canvas.ClipX / 8);
			else
				XOffset = ((Canvas.ClipX / 4) * 3) - (Canvas.ClipX / 8);

			YOffset = ScoreStart - YL;
			Canvas.DrawColor = TeamColor[i];
			Canvas.Style = ERenderStyle.STY_Masked;

// 			TEAM SCORE LINES
			Canvas.CurX = XOffset - 16;
			Canvas.CurY = YOffset + 6;
			DrawShadowTile( Canvas, Texture'UWindow.WhiteTexture', (Canvas.ClipX*0.25) + 32, (Canvas.ClipX*0.25)/64, 0, 0, 64.0, 64.0);

// 			TEAM SCORE NUMBERS
			Scale 			= ChallengeHUD(PlayerOwner.myHUD).Scale;
			CijferBreedte 	= Scale*100;
			CijferLengte 	= Scale*140;

			Canvas.CurX = ((XOffset + XOffset + (Canvas.ClipX*0.25))/2)-(CijferBreedte/2);
			Canvas.CurY = YOffset - YL - CijferLengte - 8;

			if (OwnerGame.Teams[i].Score < 10)
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 25*OwnerGame.Teams[i].Score, 0, 25.0, 35.0);

			Canvas.CurX = ((XOffset + XOffset + (Canvas.ClipX*0.25))/2)-(CijferBreedte);
			Canvas.CurY = YOffset - YL - CijferLengte - 8;

			if ( (OwnerGame.Teams[i].Score < 20) && (OwnerGame.Teams[i].Score > 9) )
			{
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 25, 0, 25.0, 35.0);
				Canvas.CurX += 7*Scale;
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 25*(OwnerGame.Teams[i].Score - 10), 0, 25.0, 35.0);
			}
			if ( (OwnerGame.Teams[i].Score < 30) && (OwnerGame.Teams[i].Score > 19) )
			{
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 50, 0, 25.0, 35.0);
				Canvas.CurX += 7*Scale;
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 25*(OwnerGame.Teams[i].Score - 20), 0, 25.0, 35.0);
			}
			if ( (OwnerGame.Teams[i].Score < 40) && (OwnerGame.Teams[i].Score > 29) )
			{
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 75, 0, 25.0, 35.0);
				Canvas.CurX += 7*Scale;
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 25*(OwnerGame.Teams[i].Score - 30), 0, 25.0, 35.0);
			}
			if ( (OwnerGame.Teams[i].Score < 50) && (OwnerGame.Teams[i].Score > 39) )
			{
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 100, 0, 25.0, 35.0);
				Canvas.CurX += 7*Scale;
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 25*(OwnerGame.Teams[i].Score - 40), 0, 25.0, 35.0);
			}
			if ( (OwnerGame.Teams[i].Score < 60) && (OwnerGame.Teams[i].Score > 49) )
			{
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 125, 0, 25.0, 35.0);
				Canvas.CurX += 7*Scale;
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 25*(OwnerGame.Teams[i].Score - 50), 0, 25.0, 35.0);
			}
			if ( (OwnerGame.Teams[i].Score < 70) && (OwnerGame.Teams[i].Score > 59) )
			{
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 150, 0, 25.0, 35.0);
				Canvas.CurX += 7*Scale;
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 25*(OwnerGame.Teams[i].Score - 60), 0, 25.0, 35.0);
			}
			if ( (OwnerGame.Teams[i].Score < 80) && (OwnerGame.Teams[i].Score > 69) )
			{
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 175, 0, 25.0, 35.0);
				Canvas.CurX += 7*Scale;
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 25*(OwnerGame.Teams[i].Score - 70), 0, 25.0, 35.0);
			}
			if ( (OwnerGame.Teams[i].Score < 90) && (OwnerGame.Teams[i].Score > 79) )
			{
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 200, 0, 25.0, 35.0);
				Canvas.CurX += 7*Scale;
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 25*(OwnerGame.Teams[i].Score - 80), 0, 25.0, 35.0);
			}
			if ( (OwnerGame.Teams[i].Score < 100) && (OwnerGame.Teams[i].Score > 89) )
			{
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 225, 0, 25.0, 35.0);
				Canvas.CurX += 7*Scale;
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 25*(OwnerGame.Teams[i].Score - 90), 0, 25.0, 35.0);
			}
			if (OwnerGame.Teams[i].Score > 99)	
			{
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 225, 0, 25.0, 35.0);
				Canvas.CurX += 7*Scale;
				DrawShadowTile( Canvas, Texture'BTTIMER', CijferBreedte, CijferLengte, 225, 0, 25.0, 35.0);
//			DRAW BUNNIES IF SCORE 99+
				Canvas.Style = ERenderStyle.STY_Masked; // MAKE IT MASKED

				Canvas.SetPos( XOffset - 16, YOffset - (Canvas.ClipX/12) );
				Canvas.DrawIcon( Texture'bunnyZfl', Canvas.ClipX/6150 );
				Canvas.SetPos( XOffset + (Canvas.ClipX*0.25) + 16 - (Canvas.ClipX/12), YOffset - (Canvas.ClipX/12) );
				Canvas.DrawIcon( Texture'bunnyZfr', Canvas.ClipX/6150 );

				Canvas.Style = ERenderStyle.STY_Normal; // BACK TO NORMAL
			}
		}
	}
// 	DRAW TRAILER
	DrawTrailer(Canvas);
}

function DrawSpectators(Canvas Canvas, PlayerReplicationInfo PRI)
{
	local float XL, YL;
	local int i;

	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.DrawColor = WhiteColor;
	Canvas.StrLen("Spectators", XL, YL);
	Canvas.SetPos(Canvas.ClipX-XL-2, Canvas.ClipY/15);
	DrawShadowText(Canvas, "Spectators", False, true);
	if(Spectators[0] == "")
	{
		Canvas.DrawColor = SilverColor;
		Canvas.StrLen("None", XL, YL);
		Canvas.SetPos(Canvas.ClipX-XL-2, Canvas.CurY);
		DrawShadowText(Canvas, "None", False, true);
	}
	else
	{
		Canvas.DrawColor = GreenColor;
		for(i=0;i<32;i++)
		{
			if(Spectators[i] == "")
				break;
			Canvas.StrLen(Spectators[i], XL, YL);
			Canvas.SetPos(Canvas.ClipX-XL-2, Canvas.CurY);
			DrawShadowText(Canvas, Spectators[i], False, true);
		}
	}
}

function DrawCapsAndTime(Canvas Canvas, int Caps, string Time, float XOffset, float YOffset, bool bCompressed, int height)
{
	local float XL, YL, XL2, YL2;

	Canvas.DrawColor = GreenColor;
	Canvas.StrLen(Time, XL, YL);
	Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );

	if(Canvas.ClipX <= 800)
		Canvas.SetPos(XOffset + (Canvas.ClipX*0.30) - XL, YOffset);
	else
		Canvas.SetPos(XOffset + (Canvas.ClipX*0.25) - XL, YOffset);

	DrawShadowText(Canvas, Time, False, true);

	if(Canvas.ClipX < 640 || bCompressed)
		return;

	Canvas.DrawColor=GoldColor;
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.StrLen("Caps:"@Caps, XL2, YL2);

	if(YL == 0)
		YL = height;	//in case player deleted his/her maprecord but capped before -> no game-best-time present

	if(Canvas.ClipX <= 800)
	{
		Canvas.SetPos(XOffset + (Canvas.ClipX*0.30) - XL2, YOffset+YL);
		DrawShadowText(Canvas, "Caps:"@Caps, False, true);
		
		Canvas.Style = ERenderStyle.STY_Masked;
		Canvas.SetPos(XOffset + (Canvas.ClipX*0.30) - XL2 - 28, YOffset+YL -2);
		Canvas.DrawIcon(FlagIcon[3], 0.875);
	}
	else
	{
		Canvas.SetPos(XOffset + (Canvas.ClipX*0.25) - XL2, YOffset+YL);
		DrawShadowText(Canvas, "Caps:"@Caps, False, true);

		Canvas.Style = ERenderStyle.STY_Masked;
		Canvas.SetPos(XOffset + (Canvas.ClipX*0.25) - XL2 -28, YOffset+YL -2);
		Canvas.DrawIcon(FlagIcon[3], 0.875);
	}
}

function DrawNameAndPing(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset, bool bCompressed)
{
	local float XL, YL, XL2, YL2, YB;
	local String S, L, T, tempL;
	local Font CanvasFont;
	local int Time, Eff, i, FlagShift;
	local BTPPReplicationInfo RI;
	local color OldColor;
	local int lenstrip; // used for stripping the ZoneInfo to an appropriate width
	local float stripmod; // a modifier dependant on resolution

	RI = FindInfo(PRI, i);//RI == PI[i].RI
	
	if (RI == None) // this sucks, FindInfo couldn't have found PRI
		return;
		
	if (PlayerOwner == None)
		PlayerOwner = PlayerPawn(Owner);

	if (OwnerRI == None)
	{
		if(PlayerOwner.PlayerReplicationInfo.bIsSpectator && !PlayerOwner.PlayerReplicationInfo.bWaitingPlayer)
		{
			foreach Level.AllActors(class'BTPPReplicationInfo', OwnerRI)
				if(PlayerOwner.PlayerReplicationInfo.PlayerID == OwnerRI.PlayerID)
					break;
				else
					OwnerRI = None;
		}
	}

	Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
	
//	NAME COLORS
	if (PRI.bAdmin)
		Canvas.DrawColor = WhiteColor;
	else if (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName)
		Canvas.DrawColor = GoldColor;

	Canvas.StrLen(PRI.PlayerName, XL, YB);

//	DRAW COUNTRYFLAG
	if (Canvas.ClipX >= 512)
	{
		if (RI.CountryPrefix != "")
		{
			OldColor = Canvas.DrawColor;
			Canvas.SetPos(XOffset-6, YOffset+YB/2-4);
			Canvas.DrawColor = WhiteColor;
			Canvas.bNoSmooth = False;
			Canvas.DrawIcon(FD[GetFlagIndex(RI.CountryPrefix)].Tex, 1.0);
			Canvas.DrawColor = OldColor;
			Canvas.bNoSmooth = True;
			FlagShift = 12;
		}
	}
	Canvas.SetPos(XOffset + FlagShift, YOffset);
	DrawShadowText(Canvas, PRI.PlayerName, False, true);

	if (Canvas.ClipX > 512)
	{
		CanvasFont = Canvas.Font;
		Canvas.Font = Canvas.SmallFont;
		
		Canvas.DrawColor = WhiteColor;

			if (Canvas.ClipX >= 640)
			{
				if (!bCompressed)
				{
					// Draw Time
					Time = Max(0, (Level.TimeSeconds + OwnerRI.timeDelta + OwnerRI.JoinTime - RI.JoinTime)/66);//realtime
					Canvas.StrLen("Time:    ", XL, YL);
					Canvas.SetPos(XOffset - XL - 6, YOffset + 2);
					DrawShadowText(Canvas, "Time:"$Time, false, true);
				}

				if (CTFFlag(PRI.HasFlag) != None)
				{
					// Flag icon
					Canvas.SetPos(XOffset - XL - 35 -12, YOffset);
					Canvas.DrawIcon(FlagIcon[CTFFlag(PRI.HasFlag).Team], 1.333);
				}
				
				if (RI.bNeedsRespawn)
				{
					if (!PRI.bIsSpectator || (PlayerOwner != None && !PlayerOwner.IsInState('GameEnded')) || !PRI.bWaitingPlayer)
					{
						if(RI.lastCap == 0)
						{
							Canvas.SetPos(XOffset - XL - 35 -12, YOffset);
							Canvas.Style = ERenderStyle.STY_Masked;
							Canvas.DrawIcon(texture'skullicon', 0.666);
						}
					}
				}
				else if (RI.bReadyToPlay && PRI.bWaitingPlayer)
				{
					Canvas.DrawColor = WhiteColor;
					Canvas.Style = ERenderStyle.STY_Masked;
					Canvas.SetPos(XOffset -XL - 35 -12, YOffset);
					Canvas.DrawIcon(FlagIcon[2], 1.333); // DRAW GREEN FLAG
				}
			}

		if (Level.NetMode != NM_Standalone)
		{
			if (!bCompressed)
			{
				Canvas.StrLen("Ping:    ", XL2, YL2);
				if (YL == 0)//?bug; time not printed -> don't mess P L E with YL == 0
					YL = YL2;
				// Draw Ping
				Canvas.SetPos(XOffset - XL2 - 6, YOffset + (YL+1) + 3);
				DrawShadowText(Canvas, "Ping:"$PRI.Ping, false, true);

				Canvas.StrLen("Loss:    ", XL2, YL2);
				Canvas.SetPos(XOffset - XL2 - 6, YOffset + 2*(YL+1) + 4);
				DrawShadowText(Canvas, "Loss:"$PRI.PacketLoss$"%", false, true);
			}
		}
		
		if (Canvas.ClipX > 640)
		{
			// 	DRAW NETSPEED		
			Canvas.StrLen("Net:     ", XL2, YL2);
			Canvas.SetPos(XOffset - XL2 - 6, YOffset + 3*(YL+1) + 5);
			DrawShadowText(Canvas, "Net:"$RI.NetSpeed, false, true);
		}

		Canvas.Font = CanvasFont;
	}

	// Draw Score
	if (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName)
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = TeamColor[PRI.Team];

	if (RI.Caps != 0)
		DrawCapsAndTime(Canvas, RI.Caps, RI.BestTimeStr, XOffset, YOffset, bCompressed, YB);

	Canvas.Font = CanvasFont;

	if (Canvas.ClipX < 512)
		return;

	// DRAW PLAYER TIMER
	if (!bCompressed)
	{
		CanvasFont = Canvas.Font;
		Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
		Canvas.DrawColor = GoldColor;		

		Canvas.StrLen("Timer: ", XL, YL);
		Canvas.SetPos(XOffset - 6, YOffset + YB);
		DrawShadowText(Canvas, "Timer: ", False, True);	

		//	NOT ON A RUN
		Canvas.SetPos(XOffset + XL - 6, YOffset + YB);

		if(RI.bNeedsRespawn || (PlayerOwner != None && PlayerOwner.IsInState('GameEnded')))
		{
			Canvas.DrawColor = SilverColor;

			if(RI.lastCap != 0)//got to show the captime
			{
				if(PI[i].captimeInt != RI.lastCap)//new captime?
				{	
					PI[i].captime = FormatCentiseconds(RI.lastCap, True);
					PI[i].captimeInt = RI.lastCap;
				}
				DrawShadowText(Canvas, PI[i].captime, False, True);
			}
			else //idle/game ended
				DrawShadowText(Canvas, "-:--", False, True);
		}

		//	ON A RUN
		else
		{			
			if(PRI.bIsSpectator && PRI.bWaitingPlayer)
			{
				Canvas.DrawColor = SilverColor;
				T = "-:--";
			}
			else
			{
				Canvas.DrawColor = GreenColor;
				T = FormatScore(RI.GetRuntime() / 100);
			}
			DrawShadowText(Canvas, T, False, true);
		}

		Canvas.DrawColor = GoldColor;
		Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );

		if (RI.Runs - RI.Caps > 0)
		{
			if(Canvas.ClipX <= 800)
			{
				Canvas.SetPos(XOffset + (Canvas.ClipX*0.15) - ((XL*3)>>3) - 28, YOffset + YB -2);
				Canvas.Style = ERenderStyle.STY_Masked;;
				Canvas.DrawIcon(texture'skullicon', 0.333);

				Canvas.StrLen("Deaths:"@int(PRI.Deaths), XL, YL);			
				Canvas.SetPos(XOffset + (Canvas.ClipX*0.15) - ((XL*3)>>3), YOffset + YB);
				DrawShadowText(Canvas, "Deaths:" @ (RI.Runs - RI.Caps), False, true);
			}
			else
			{
				Canvas.SetPos(XOffset + (Canvas.ClipX*0.13) - ((XL*3)>>3) - 28, YOffset + YB -2);
				Canvas.Style = ERenderStyle.STY_Masked;;
				Canvas.DrawIcon(texture'skullicon', 0.333);

				Canvas.StrLen("Deaths:"@int(PRI.Deaths), XL, YL);			
				Canvas.SetPos(XOffset + (Canvas.ClipX*0.13) - ((XL*3)>>3), YOffset + YB);
				DrawShadowText(Canvas, "Deaths:" @ (RI.Runs - RI.Caps), False, true);
			}
		}
	}
}

function DrawVictoryConditions(Canvas Canvas)
{
	local float XL, YL, LX, LY, XXL, YYL, XXXL, YYYL, XXXXL, YYYYL;

//	DRAW BUNNYTRACK TOURNAMENT LOGO
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor = WhiteColor;
	Canvas.bCenter = True;
	Canvas.SetPos((Canvas.ClipX/2) - ((Canvas.ClipY/4.5)/2), 0);
	Canvas.DrawIcon(texture'BTTlogo', ((Canvas.ClipY/4.5)/512));
	Canvas.Style = ERenderStyle.STY_Normal;

//	GAMEINFO TEXT
	Canvas.DrawColor = OrangeColor;
	Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );

	//	MAPNAME
	Canvas.StrLen("Test", LX, LY);
	Canvas.SetPos(0, (Canvas.ClipY/4.5) - LY);
	DrawShadowText(Canvas, Left(string(Level), InStr(string(Level), ".")), true);

	//	GAME SETTINGS
	if (GRI.bTournament)
	{
		if (GRI.TimeLimit > 0)
		{
			Canvas.StrLen("Test", XL, YL);	
			Canvas.SetPos(0, (Canvas.ClipY/4.5));
			DrawShadowText(Canvas, TimeLimit@GRI.TimeLimit$":00", true);
		}
		if (GRI.CapLimit > 0)
		{
			Canvas.StrLen("Test", XXL, YYL);
			Canvas.SetPos(0, (Canvas.ClipY/4.5) + YL);
			DrawShadowText(Canvas, FragGoal@GRI.CapLimit, true);
		}
		Canvas.StrLen("Test", XXXL, YYYL);
		Canvas.SetPos(0, (Canvas.ClipY/4.5) + YL + YYL);
		DrawShadowText(Canvas, GRI.MaxPlayers/2 $ " vs " $ GRI.MaxPlayers/2, true);
//	FILLERS
		if (GRI.TimeLimit == 0)
		{
			Canvas.StrLen("Test", XXXXL, YYYYL);
			Canvas.SetPos(0, (Canvas.ClipY/4.5) + YL + YYL + YYYL);
			DrawShadowText(Canvas, "     ", true);
		}
		if (GRI.CapLimit == 0)
		{
			Canvas.SetPos(0, (Canvas.ClipY/4.5) + YL + YYL + YYYL + YYYYL);
			DrawShadowText(Canvas, "     ", true);
		}
	}
	else
	{
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, (Canvas.ClipY/4.5));
		DrawShadowText(Canvas, "     ", true);

		Canvas.StrLen("Test", XXL, YYL);
		Canvas.SetPos(0, (Canvas.ClipY/4.5) + YL);
		DrawShadowText(Canvas, "     ", true);

		Canvas.SetPos(0, (Canvas.ClipY/4.5) + YL + YYL);
		DrawShadowText(Canvas, "     ", true);
	}
	Canvas.bCenter = False;
}

// idea and function from UTPro by AnthraX
function DrawShadowText (Canvas Canvas, coerce string Text, optional bool Param,optional bool bSmall, optional bool bGrayShadow)
{
	local Color OldColor;
	local float XL,YL;
	local float X, Y;

	OldColor = Canvas.DrawColor;

	if (bGrayShadow)
	{
		Canvas.DrawColor.R = 127;
		Canvas.DrawColor.G = 127;
		Canvas.DrawColor.B = 127;
	}
	else
	{
		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 0;
		Canvas.DrawColor.B = 0;
	}
	if (bSmall)
	{
		XL = 1;
		YL = 1;
	}
	else
	{
		XL = 2;
		YL = 2;
	}
	X=Canvas.CurX;
	Y=Canvas.CurY;
	Canvas.SetPos(X+XL,Y+YL);
	Canvas.DrawText(Text, Param);
	Canvas.DrawColor = OldColor;
	Canvas.SetPos(X,Y);
	Canvas.DrawText(Text, Param);
}

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

function SortScores(int N)
{
	local int I, J, Max;
	local int tempC, tempD;
	local float	tempT;
	local PlayerReplicationInfo TempPRI;

	for ( I = 0; I < N - 1; I++ )
	{
		Max = I;
		for ( J = I + 1; J < N; J++ )
		{
			if (tempCaps[J] > tempCaps[I])
				Max = J;
			else if (tempCaps[J] == tempCaps[I] && tempTime[J] > tempTime[I])
				Max = J;
			else if (tempCaps[J] == tempCaps[I] && tempTime[J] == tempTime[I] && tempDeaths[J] < tempDeaths[I])
				Max = J;
			else if (tempCaps[J] == tempCaps[I] && tempTime[J] == tempTime[I] && tempDeaths[J] == tempDeaths[I] && Ordered[J].PlayerName < Ordered[Max].PlayerName)
				Max = J;
		}
	
		if(Max != I)
		{
			//move PRI
			TempPRI = Ordered[Max];
			Ordered[Max] = Ordered[I];
			Ordered[I] = TempPRI;
/*			//move temp caps
			tempC = tempCaps[Max];
			tempCaps[Max] = tempCaps[I];
			tempCaps[I] = tempC;
			//move temp time
			tempT = tempTime[Max];
			tempTime[Max] = tempTime[I];
			tempTime[I] = tempT;
			//move temp deahts
			tempD = tempDeaths[Max];
			tempDeaths[Max] = tempDeaths[I];
			tempDeaths[I] = tempD;*/
		}
	}
}

//searches for the BTPP RI by the UT PRI given
function BTPPReplicationInfo FindInfo (PlayerReplicationInfo PRI, out int ident)
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

	if (PRI == PlayerOwner.PlayerReplicationInfo)
		OwnerRI = RI;
}

//====================================
// FormatScore - formats seconds to minutes & seconds
// Triggered in: DrawNameAndPing
//====================================
static final function string FormatScore(int Time)
{
	if(int(Time % 60) < 10)//fill up a leading 0 to single-digit seconds
		return Time/60 $ ":0" $ int(Time%60);
	else
		return Time/60 $ ":" $ int(Time%60);
}

//====================================
// FormatCentiseconds - formats Score to m:ss.cc
// Triggered in: ?
//====================================
static final function string FormatCentiseconds(coerce int Centis, bool plain)
{
	if(Centis <= 0 || Centis >= Default.MAX_CAPTIME)
		return "-:--";

	if(!plain)
		Centis = Default.MAX_CAPTIME - Centis;

	if(Centis / 100 < 60)//less than 1 minute -> no formatting needed
	{
		if(Centis % 100 < 10)
			return (Centis / 100) $ ".0" $ int(Centis % 100);
		else
			return (Centis / 100) $ "." $ int(Centis % 100);
	}
	else
	{
		if(Centis % 100 < 10)
			return FormatScore(Centis / 100) $ ".0" $ int(Centis % 100);
		else
			return FormatScore(Centis / 100) $ "." $ int(Centis % 100);
	}
}

defaultproperties
{
	MAX_CAPTIME=600000
	OrangeColor=(R=255,G=88)
}