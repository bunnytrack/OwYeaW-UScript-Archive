class BTServerName extends Mutator config(BTPlusPlusTournament);

var config int UpdateInterval;
var config string BaseText;
var config string symbol;

var BTPPGameReplicationInfo GRI;
var bool Initialized;
var string titleDefault;
var string ResetMap;

function PostBeginPlay()
{
	if (!Initialized)
	{
		Initialized = !Initialized;
		titleDefault = "";	// seems title is not set at this time; so we will load it later
		SetTimer(UpdateInterval,True);
	}
	Super.PostBeginPlay();
}

event Timer()
{
	local string text, ed1, ed2, ed3;
	local int redScore, blueScore;
	local int gameDuration, gdr, gdr2;

	if (Left(string(Level), InStr(string(Level), ".")) == GRI.ResetMap)
		text = BaseText;
	else
	{
		if (Level.Game.IsA('TeamGamePlus'))
		{
			redScore = TournamentGameReplicationInfo(Level.Game.GameReplicationInfo).Teams[0].Score;
			blueScore = TournamentGameReplicationInfo(Level.Game.GameReplicationInfo).Teams[1].Score;
			text = " " $ symbol $ " |"$redScore$"-"$blueScore$"|";
		}

		if (DeathMatchPlus(Level.Game).TimeLimit > 0)
		{
			gameDuration = (DeathMatchPlus(Level.Game).TimeLimit * 60) - Level.Game.GameReplicationInfo.RemainingTime;
			gdr = gameDuration/60;
			gdr2 = gameDuration - (60 * gdr);

			if ((DeathMatchPlus(Level.Game).TimeLimit * 60) - Level.Game.GameReplicationInfo.RemainingTime == 0)
				ed3 = "Waiting for Players";
			if (Level.Game.GameReplicationInfo.RemainingTime == 0 && !Level.Game.bGameEnded)
				ed3 = "Sudden Death";
			if (Level.Game.bGameEnded)
				ed3 = "Match Ended";
			if (!Level.Game.bGameEnded && Level.Game.GameReplicationInfo.RemainingTime != 0 && (DeathMatchPlus(Level.Game).TimeLimit * 60) - Level.Game.GameReplicationInfo.RemainingTime != 0)
				ed3 = DeathMatchPlus(Level.Game).MaxPlayers/2 $ " vs " $ DeathMatchPlus(Level.Game).MaxPlayers/2;
		}
		if (DeathMatchPlus(Level.Game).TimeLimit == 0)
		{
			gameDuration = DeathMatchPlus(Level.Game).ElapsedTime;
			gdr = gameDuration/60;
			gdr2 = gameDuration - (60 * gdr);

			if (DeathMatchPlus(Level.Game).ElapsedTime == 0)
				ed3 = "Waiting for Players";
			if (Level.Game.bGameEnded)
				ed3 = "Match Ended";
			if ((!Level.Game.bGameEnded) && (DeathMatchPlus(Level.Game).ElapsedTime > 0))
				ed3 = DeathMatchPlus(Level.Game).MaxPlayers/2 $ " vs " $ DeathMatchPlus(Level.Game).MaxPlayers/2;
		}

		if (!DeathMatchPlus(Level.Game).bTournament)
			ed3 = "No Match Mode";

		if (gdr == 0)
			ed1 = "00";
		if (gdr > 0 && gdr < 10)
			ed1 = "0" $ gdr;
		if (gdr > 9 && gdr < 60)
			ed1 = "" $ gdr;

		if (gdr2 < 0)
			ed2 = "" $ gameDuration;
		if (gdr2 >= 0 && gdr2 < 10)
			ed2 = "0" $ gdr2;
		if (gdr2 >= 10 && gdr2 <= 60)
			ed2 = "" $ gdr2;

		if (gdr >= 60)
			text = text $ " " $ ed3 $ " |1+ hour| " $ symbol;
		else
			text = text $ " " $ ed3 $ " |" $ ed1 $ ":" $ ed2 $ "| " $ symbol;
	}
	SetTitle(text);
}

function SetTitle(String newText)
{
	if (titleDefault == "")
		titleDefault = Level.Game.GameReplicationInfo.ServerName;
	Level.Game.GameReplicationInfo.ServerName = titleDefault $ newText;
}

function int SplitString(String str, String divider, out String parts[256])
{
	local int i, nextSplit;

	i=0;
	while (true)
	{
		nextSplit = InStr(str,divider);
		if (nextSplit >= 0)
		{
			parts[i] = Left(str,nextSplit);
			str = Mid(str,nextSplit+Len(divider));
			i++;
		}
		else
		{
			parts[i] = str;
			i++;
			break;
		}
	}
	return i;
}

function string GetDate()
{
	local string Date, Time;
	Date = Level.Year$"-"$PrePad(Level.Month,"0",2)$"-"$PrePad(Level.Day,"0",2);
	Time = PrePad(Level.Hour,"0",2)$":"$PrePad(Level.Minute,"0",2)$"."$PrePad(Level.Second,"0",2);
	return Date$"-"$Time;
}

function string PrePad(coerce string s, string p, int i)
{
	while (Len(s) < i)
		s = p$s;
	return s;
}

function bool StrStartsWith(string s, string x)
{
	return (InStr(s,x) == 0);
}

function bool StrContains(String s, String x)
{
	return (InStr(s,x) > -1);
}

function String StrAfter(String s, String x)
{
	local int i;

	i = Instr(s,x);
	return Mid(s,i+Len(x));
}

function string StrAfterLast(string s, string x)
{
	local int i;

	i = InStr(s,x);
	if (i == -1)
		return s;

	while (i != -1)
	{
		s = Mid(s,i+Len(x));
		i = InStr(s,x);
	}
	return s;
}

function string StrBefore(string s, string x)
{
	local int i;

	i = InStr(s,x);
	if (i == -1)
		return s;
	else
		return Left(s,i);
}

function string StrBeforeLast(string s, string x)
{
	local int i;

	i = InStrLast(s,x);
	if (i == -1)
		return s;
	else
		return Left(s,i);
}

function int InStrOff(string haystack, string needle, int offset)
{
	local int instrRest;

	instrRest = InStr(Mid(haystack,offset),needle);
	if (instrRest == -1)
		return instrRest;
	else
		return offset + instrRest;
}

function int InStrLast(string haystack, string needle)
{
	local int pos;
	local int posRest;

	pos = InStr(haystack,needle);
	if (pos == -1)
		return -1;
	else
	{
		posRest = InStrLast(Mid(haystack,pos+Len(needle)),needle);
		if (posRest == -1)
			return pos;
		else
			return pos + Len(needle) + posRest;
	}
}

// Converts a string to lower-case.
function String Locs(String in)
{
	local String out;
	local int i;
	local int c;

	out = "";
	for (i=0;i<Len(in);i++)
	{
		c = Asc(Mid(in,i,1));
		if (c>=65 && c<=90)
			c = c + 32;
		out = out $ Chr(c);
	}
	return out;
}