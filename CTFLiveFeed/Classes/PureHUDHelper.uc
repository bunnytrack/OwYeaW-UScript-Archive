// ===============================================================
// UTPureRC7A.PureHUDHelper: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class PureHUDHelper extends Actor
	abstract;

static simulated function DrawTime(Canvas Canvas, float X, float Y, PlayerPawn PlayerOwner)
{
	local GameReplicationInfo GRI;
	local int Min, Sec;
	local string Time;
	local float fX, fY;
	
	GRI = PlayerOwner.GameReplicationInfo;
	Min = GRI.RemainingTime;
	
	if (Min == 0)
		Min = GRI.ElapsedTime;

	Sec = Min % 60;
	Min = Min / 60;

	Time = string(Min)$":";
	if (Sec < 10)
		Time = Time$"0"$string(Sec);
	else
		Time = Time$string(Sec);
	
	Canvas.StrLen(Time, fX, fY);
	Canvas.SetPos(X - fX * 0.5, Y - fY * 0.5);
	Canvas.DrawText(Time);
}

static simulated function TimeFont(Canvas Canvas, float Scale, FontInfo MyFonts)
{
	if (Scale > 0.5)
		Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);
	else if (Scale > 0.3)
		Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);
	else if (Scale > 0.2)
		Canvas.Font = MyFonts.GetMediumFont(Canvas.ClipX);
	else if (Scale > 0.1)
		Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
	else
		Canvas.Font = MyFonts.GetSmallestFont(Canvas.ClipX);
}

defaultproperties
{
}
