//expanding the HUD class so we can make changes
//this version is for CTF matches
class LiveFeedCTFHUD extends ChallengeCTFHUD config(CTFLiveFeed);

#exec texture IMPORT NAME=PureBoots		FILE=TEXTURES\PureBoots.PCX		MIPS=OFF
#exec texture IMPORT NAME=PureTimeBG	FILE=TEXTURES\PureTimeBG.PCX	MIPS=OFF

var config string LiveFeedText;
var color BlackColor;
//This is the master HUD rendering function. We are making small changes to a couple of spots so you can
// look for this:
//  "//change//"
//and you will find where I made my alterations.
simulated function PostRender( canvas Canvas )
{
   local float XL, YL, XX, YY, XPos, YPos, FadeValue;
   local string Message;
   local int M, i, j, k, XOverflow, X, Y;
   local float OldOriginX;
	local CTFFlag Flag;
	local bool bAlt;

   HUDSetup(canvas);
   if ( (PawnOwner == None) || (PlayerOwner.PlayerReplicationInfo == None) )
      return;

   if ( bShowInfo )
   {
      ServerInfo.RenderInfo( Canvas );
      return;
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
      DrawTalkFace( Canvas,0, YPos );
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

   if ( !PlayerOwner.bBehindView && (PawnOwner.Weapon != None) && (Level.LevelAction == LEVACT_None) )
   {
      Canvas.DrawColor = WhiteColor;
      PawnOwner.Weapon.PostRender(Canvas);
      if ( !PawnOwner.Weapon.bOwnsCrossHair )
         DrawCrossHair(Canvas, 0,0 );
   }

	//change//
	if ( (PawnOwner != Owner) && PawnOwner.bIsPlayer )
	{
		Canvas.bCenter = true;
		Canvas.Style = ERenderStyle.STY_Normal;

		//	Set a Font Size
		Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);

		//	Set a Color
		Canvas.DrawColor = TeamColor[PawnOwner.PlayerReplicationInfo.Team];

		//	Set a Position
		Canvas.StrLen("test", XX, YY);
		Canvas.SetPos(0, Canvas.ClipY - YY * 0.666 - 0.0833 * Canvas.ClipY);

		// Draw it
		DrawShadowText(Canvas, LiveFeedText $ PawnOwner.PlayerReplicationInfo.PlayerName, True);

		//	This resets the Canvas
		Canvas.bCenter = false;
		Canvas.DrawColor = WhiteColor;
		Canvas.Style = Style;
		Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	}
	//change//

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
            
         // Draw Health/Armor status
         DrawStatus(Canvas);

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

	Canvas.Style = Style;
	if( !bHideHUD && !bHideTeamInfo )
	{
		X = Canvas.ClipX - 70 * Scale;
		Y = Canvas.ClipY - 350 * Scale;
			
		for ( i=0; i<4; i++ )
		{
			Flag = CTFReplicationInfo(PlayerOwner.GameReplicationInfo).FlagList[i];
			if ( Flag != None )
			{
				Canvas.DrawColor = TeamColor[Flag.Team];
				Canvas.SetPos(X,Y);

				if (Flag.Team == PawnOwner.PlayerReplicationInfo.Team)
					MyFlag = Flag;
				if ( Flag.bHome ) 
					Canvas.DrawIcon(texture'I_Home', Scale * 2);
				else if ( Flag.bHeld )
					Canvas.DrawIcon(texture'I_Capt', Scale * 2);
				else
					Canvas.DrawIcon(texture'I_Down', Scale * 2);
			}
			Y -= 150 * Scale;
		}
	}
}

simulated function DrawStatus(Canvas Canvas)
{
	local float StatScale, ChestAmount, ThighAmount, H1, H2, X, Y, DamageTime;
	Local int ArmorAmount,CurAbs,i;
	Local inventory Inv,BestArmor;
	local bool bChestArmor, bShieldbelt, bThighArmor, bJumpBoots, bHasDoll;
	local Bot BotOwner;
	local TournamentPlayer TPOwner;
	local texture Doll, DollBelt;
	local int BootCharges;

	ArmorAmount = 0;
	CurAbs = 0;
	i = 0;
	BestArmor=None;
	for( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
	{ 
		if (Inv.bIsAnArmor) 
		{
			if ( Inv.IsA('UT_Shieldbelt') )
				bShieldbelt = true;
			else if ( Inv.IsA('Thighpads') )
			{
				ThighAmount += Inv.Charge;
				bThighArmor = true;
			}
			else
			{ 
				bChestArmor = true;
				ChestAmount += Inv.Charge;
			}
			ArmorAmount += Inv.Charge;
		}
		else if ( Inv.IsA('UT_JumpBoots') )
		{
			bJumpBoots = true;
			BootCharges = Inv.Charge;
		}
		else
		{
			i++;
			if ( i > 100 )
				break; // can occasionally get temporary loops in netplay
		}
	}

	if ( !bHideStatus )
	{	
		TPOwner = TournamentPlayer(PawnOwner);
		if ( Canvas.ClipX < 400 )
			bHasDoll = false;
		else if ( TPOwner != None)
		{
			Doll = TPOwner.StatusDoll;
			DollBelt = TPOwner.StatusBelt;
			bHasDoll = true;
		}
		else
		{
			BotOwner = Bot(PawnOwner);
			if ( BotOwner != None )
			{
				Doll = BotOwner.StatusDoll;
				DollBelt = BotOwner.StatusBelt;
				bHasDoll = true;
			}
		}
		if ( bHasDoll )
		{ 							
			Canvas.Style = ERenderStyle.STY_Translucent;
			StatScale = Scale * StatusScale;
			X = Canvas.ClipX - 128 * StatScale;
			Canvas.SetPos(X, 0);
			if (PawnOwner.DamageScaling > 2.0)
				Canvas.DrawColor = PurpleColor;
			else
				Canvas.DrawColor = HUDColor;
			Canvas.DrawTile(Doll, 128*StatScale, 256*StatScale, 0, 0, 128.0, 256.0);
			Canvas.DrawColor = HUDColor;
			if ( bShieldBelt )
			{
				Canvas.DrawColor = BaseColor;
				Canvas.DrawColor.B = 0;
				Canvas.SetPos(X, 0);
				Canvas.DrawIcon(DollBelt, StatScale);
			}
			if ( bChestArmor )
			{
				ChestAmount = FMin(0.01 * ChestAmount,1);
				Canvas.DrawColor = HUDColor * ChestAmount;
				Canvas.SetPos(X, 0);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 0, 128, 64);
			}
			if ( bThighArmor )
			{
				ThighAmount = FMin(0.02 * ThighAmount,1);
				Canvas.DrawColor = HUDColor * ThighAmount;
				Canvas.SetPos(X, 64*StatScale);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 64, 128, 64);
			}
			if ( bJumpBoots )
			{
				Canvas.DrawColor = HUDColor;
				Canvas.SetPos(X, 128*StatScale);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 128, 128, 64);
			}
			Canvas.Style = Style;
			if ( (PawnOwner == PlayerOwner) && Level.bHighDetailMode && !Level.bDropDetail )
			{
				for ( i=0; i<4; i++ )
				{
					DamageTime = Level.TimeSeconds - HitTime[i];
					if ( DamageTime < 1 )
					{
						Canvas.SetPos(X + HitPos[i].X * StatScale, HitPos[i].Y * StatScale);
						if ( (HUDColor.G > 100) || (HUDColor.B > 100) )
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
	if ( bHideStatus && bHideAllWeapons )
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
	if ( PawnOwner.Health < 50 )
	{
		H1 = 1.5 * TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = WhiteColor * H2 + (HUDColor - WhiteColor) * H1;
	}
	else
		Canvas.DrawColor = HUDColor;
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 128, 128, 128.0, 64.0);

	if ( PawnOwner.Health < 50 )
	{
		H1 = 1.5 * TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = Canvas.DrawColor * H2 + (WhiteColor - Canvas.DrawColor) * H1;
	}
	else
		Canvas.DrawColor = WhiteColor;

	DrawBigNum(Canvas, Max(0, PawnOwner.Health), X + 4 * Scale, Y + 16 * Scale, 1);

	Canvas.DrawColor = HUDColor;
	if ( bHideStatus && bHideAllWeapons )
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
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 0, 192, 128.0, 64.0);
	if ( bHideStatus && bShieldBelt )
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = WhiteColor;
	DrawBigNum(Canvas, Min(150,ArmorAmount), X + 4 * Scale, Y + 16 * Scale, 1);

	if (PlayerOwner != None || CHSpectator(PlayerOwner) != None)
	{
		Canvas.DrawColor = HUDColor;
		if ( bHideStatus && bHideAllWeapons )
		{	// Draw in front of Frags
			X = 0.5 * Canvas.ClipX - 384 * Scale;
			Y = Canvas.ClipY - 64 * Scale;				
		}
		else
		{
			X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
			Y = 128 * Scale;
		}
		Canvas.SetPos(X,Y);
		Canvas.DrawTile(Texture'PureTimeBG', 128*Scale, 64*Scale, 0, 0, 128.0, 64.0);
		Canvas.DrawColor = WhiteColor;
		Class'PureHUDHelper'.Static.TimeFont(Canvas, Scale, MyFonts);
		//Log("Canvas Scale:"@Scale);
		Class'PureHUDHelper'.Static.DrawTime(Canvas, X + 64 * Scale, Y + 32 * Scale, PlayerOwner);

		if (bJumpBoots)
		{
			Canvas.DrawColor = HUDColor;
			if ( bHideStatus && bHideAllWeapons )
			{	// Draw after ammo.
				X = 0.5 * Canvas.ClipX + 256 * Scale;
				Y = Canvas.ClipY - 64 * Scale;
			}
			else
			{
				X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
				Y = 192 * Scale;
			}
			Canvas.SetPos(X,Y);
			Canvas.DrawTile(Texture'PureBoots', 128*Scale, 64*Scale, 0, 0, 128.0, 64.0);
			Canvas.DrawColor = WhiteColor;
			DrawBigNum(Canvas, BootCharges, X + 4 * Scale, Y + 16 * Scale, 1);
		}
	}
}

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