//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class MapVoteHistory extends Info;

function 						AddMap(string MapName);
function 						RemoveMap(string MapName);
function 						SetMapSequence(string MapName,int NewSeq);
function 						SetPlayCount(string MapName,int NewPlayCount);
function 						Save();
function 						MapReport(string ReportType,MapVoteReport MVReport);

function 	string 				GetMap(int SeqNum);
function 	string 				GetLeastPlayedMap();
function 	string 				GetMostPlayedMap();

function 	int 				GetMapSequence(string MapName);
function 	int 				GetPlayCount(string MapName);
