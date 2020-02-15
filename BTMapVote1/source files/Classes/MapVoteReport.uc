//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class MapVoteReport extends Info;

var 	string 					ReportText;
var 	int 					x;
var 	MapVoteWRI 				MVWRI;
var 	bool 					bSendResults;
var 	MapVoteHistory 			History;

//-----------------------------------------------------------------------------
function RunRport(string ReportType, PlayerPawn Sender, class<MapVoteHistory> MapVoteHistoryClass)
{
	// Find the requestors WRI
	foreach AllActors(class'BTMapVote1.MapVoteWRI', MVWRI)
	{
		if (Sender == MVWRI.Owner)
		break;
	}

	if (MVWRI == none)
	{
		log("Failed to find MVWRI");
		Destroy();
		return;
	}

	// change report area to show "Please Wait......."
	MVWRI.SendReportText("<html><body bgcolor=#000000><br><br><br><center><b>Please Wait.....</b></center></body></html>");
	MVWRI.SendReportText("");

	History = spawn(MapVoteHistoryClass);
	if (History == none)
	{
		log("Failed to spawn MapVoteHistory");
		Destroy();
		return;
	}

	History.MapReport(ReportType, self);
}

//-----------------------------------------------------------------------------
function tick(float DeltaTime)
{
	if (bSendResults)
	{
		// just incase the user gets tired of waiting
		if (MVWRI == None)
		{
			History.Destroy();
			Destroy();
			return;
		}

		if (x > len(ReportText))
		{
			MVWRI.SendReportText("");
			bSendResults = false;
			History.Destroy();
			Destroy();
		}
		else
		{
			MVWRI.SendReportText(Mid(ReportText, x, 250));
			x = x + 250;

			if (x < len(ReportText))
			{
				MVWRI.SendReportText(Mid(ReportText, x, 250));
				x = x + 250;
			}
		}
	}
}