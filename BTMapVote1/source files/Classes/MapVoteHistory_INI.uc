//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class MapVoteHistory_INI extends MapVoteHistory;

const ArraySize = 1023; // Bah, static arrays can't be longer than 1024 -> TODO: investigate dynamic arrays

var() 	config string 			M[1024];
var() 	config int    			P[1024];
var() 	config int    			S[1024];
var() 	config int    			LastMapIndex;
var 	MapVoteReport 			MVReport;
var 	string 					ReportType;
var 	int 					a, b;
var 	string 					ReportText;

//-----------------------------------------------------------------------------
function AddMap(string MapName)
{
	local int x, y;
	local bool bFound;

	if (MapName == "")
		return;

	if (LastMapIndex >= ArraySize)
		RemoveOldestMap();

	// brand new list
	if (LastMapIndex == 0)
	{
		// add new map
		M[1] = MapName;
		P[1] = 1;
		S[1] = 1;
		LastMapIndex = 1;
		return;
	}

	bFound = false;
	for (x = 1; x <= LastMapIndex; x++)
	{
		if (MapName == M[x])
		{
			// Set sequence (last 1 map played)
			S[x] = 1;
			// increment Play count
			P[x]++;
			bFound = true;
		}
		else
		{
			// -1 indicates a never play map
			// increment the sequence of all maps to make room for # 1
			if (S[x] > -1)
				S[x]++;
		}

		// MapName is not in array and should be inserted here
		if (Caps(M[x]) > Caps(MapName) && !bFound)
		{
			// move all maps down one to make room for the new one
			for (y = LastMapIndex; y >= x; y--)
			{
				M[y + 1] = M[y];
				P[y + 1] = P[y];
				S[y + 1] = S[y];

				if (y != x && S[y] > -1)
					S[y+1]++;
			}
			// add new map
			M[x] = MapName;
			P[x] = 1;
			S[x] = 1;
			LastMapIndex++;
			return;
		}
	}
	// didn't find insertion point so add at end
	if (!bFound)
	{
		LastMapIndex++;
		M[LastMapIndex] = MapName;
		P[LastMapIndex] = 1;
		S[LastMapIndex] = 1;
	}
	return;
}

//-----------------------------------------------------------------------------
function int GetMapSequence(string MapName)
{
	local int Index;
	Index = FindIndex(MapName);

	if (Index == 0)
		return ArraySize + 1;
	else
		return(S[Index]);
}

//-----------------------------------------------------------------------------
function SetMapSequence(string MapName, int NewSeq)
{
	local int Index;
	Index = FindIndex(MapName);
	if (Index > 0)
		S[Index]=NewSeq;
}

//-----------------------------------------------------------------------------
function int GetPlayCount(string MapName)
{
	local int Index;
	Index = FindIndex(MapName);
	if (Index == 0)
		return(0);
	else
		return(P[Index]);
}

//-----------------------------------------------------------------------------
function SetPlayCount(string MapName, int NewPlayCount)
{
	local int Index;
	Index = FindIndex(MapName);
	if (Index > 0)
		P[Index] = NewPlayCount;
}

//-----------------------------------------------------------------------------
function Save()
{
	SaveConfig();
}

//-----------------------------------------------------------------------------
function RemoveOldestMap()
{
	local int x, Lowest;

	// scan the list for the oldest played map
	Lowest = 1;
	for (x = 2; x <= LastMapIndex; x++)
	{
		if (S[x] < S[Lowest])
		Lowest = x;
	}
	RemoveMapByIndex(Lowest);
}

//-----------------------------------------------------------------------------
function RemoveMap(string MapName)
{
	local int Index;
	Index = FindIndex(MapName);
	if (Index > 0)
		RemoveMapByIndex(Index);
}

//-----------------------------------------------------------------------------
function RemoveMapByIndex(int Index)
{
	local int x;

	for (x = Index; x < LastMapIndex; x++)
	{
		M[x] = M[x+  1];
		P[x] = P[x + 1];
		S[x] = S[x + 1];
	}
	// blank out last
	M[LastMapIndex] = "";
	P[LastMapIndex] = 0;
	S[LastMapIndex] = 0;
	LastMapIndex--;
}

//-----------------------------------------------------------------------------
function int FindIndex(string MapName)
{
	local int a, b, i;

	if (LastMapIndex == 0)
		return(0);

	a = 1;
	b = LastMapIndex;
	while(true)
	{
		i = ((b - a) / 2) + a;
		// check for a match
		if (M[i] ~= MapName)
			return(i); // found

		if (a == b) // Not found
			return(0);

		// check mid-way
		if (Caps(M[i]) > Caps(MapName))
			b = i; // too high
		else
		{
			if (a == i)
				a = b;
			else
				a = i; // too low
		}
	}
}

//-----------------------------------------------------------------------------
function MapReport(string p_ReportType, MapVoteReport p_MVReport)
{
	MVReport = p_MVReport;
	ReportType = p_ReportType;
	a = 1;
	GotoState('sorting');
}

//-----------------------------------------------------------------------------
function SendReport()
{
}

//-----------------------------------------------------------------------------
function Swap(int a, int b)
{
	local int pc, seq;
	local string MapName;

	MapName = M[a];
	M[a]    = M[b];
	M[b]    = MapName;

	pc      = P[a];
	P[a]    = P[b];
	P[b]    = pc;

	seq     = S[a];
	S[a]    = S[b];
	S[b]    = seq;
}

//-----------------------------------------------------------------------------
state sorting
{
	function tick(float DeltaTime)
	{
		local int loopcount;
		for(loopcount = 1; loopcount <= 4; loopcount++)
		{
			if (a <= LastMapIndex-1)
			{
				for (b = a + 1; b <= LastMapIndex; b++)
				{
					if (ReportType == "SEQ")
						if (S[a] > S[b])
							Swap(a, b);

						if (ReportType == "PC")
							if (P[b] > P[a])
								Swap(a, b);
				}
				a++;
			}
			else
			{
				GotoState('formating');
				break;
			}
		}
	}
}

//-----------------------------------------------------------------------------
state formating
{
	function tick(float DeltaTime)
	{
		local int loopcount, MaxMaps;

		for (loopcount = 1; loopcount <= 2; loopcount++)
		{
			// limit results to 100 maps to prevent lag
			if (LastMapIndex > 100)
				MaxMaps = 100;
			else
				MaxMaps = LastMapIndex - 1;

			if (a <= MaxMaps)
			{
				ReportText = ReportText $ "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";

				if (ReportType == "SEQ")
				{
					ReportText = ReportText $ S[a];
					for (b = 1; b < 20 - len(String(S[a])); b++)
						ReportText = ReportText $ "&nbsp;";
				}

				if (ReportType == "PC")
				{
					ReportText = ReportText $ P[a];
					for (b = 1; b < 20 - len(String(P[a])); b++)
					ReportText = ReportText $ "&nbsp;";
				}

				ReportText = ReportText $ M[a] $ "<br>";
				a++;
			}
			else
			{
				ReportText = ReportText $ "</body></html>";
				if (MVReport == None)
				{
					Destroy();
					return;
				}
				MVReport.ReportText = ReportText;
				MVReport.bSendResults = true;
				GotoState('');
				break;
			}
		}
	}

	function BeginState()
	{
		ReportText = "<html><body bgcolor=#000000><center><h1><font color=#0000FF>Map Report ";

		if (ReportType == "SEQ")
			ReportText = ReportText $ "2";

		if (ReportType == "PC")
			ReportText = ReportText $ "1";

		ReportText = ReportText $ "</font></h1></center><p>";
		ReportText = ReportText $ "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";

		if (ReportType == "SEQ")
			ReportText = ReportText $ "Sequence&nbsp;&nbsp;";

		if (ReportType == "PC")
			ReportText = ReportText $ "PlayCount&nbsp;";

		ReportText = ReportText $ "     Map Name<br>";
		ReportText = ReportText $ "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
		ReportText = ReportText $ "------------    -------------------------------<br>";

		a = 1;
	}
}