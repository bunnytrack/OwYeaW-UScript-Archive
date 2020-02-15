//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class UMenuMapVoteList expands UWindowListBoxItem;

var 	string 					MapName;

//-----------------------------------------------------------------------------
function int Compare(UWindowList T, UWindowList B)
{
	if (Caps(UMenuMapVoteList(T).MapName) < Caps(UMenuMapVoteList(B).MapName))
		return -1;
	return 1;
}