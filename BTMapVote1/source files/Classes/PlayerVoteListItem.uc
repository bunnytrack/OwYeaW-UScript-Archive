//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class PlayerVoteListItem expands UWindowListBoxItem;

var 	string 					PlayerName;

//-----------------------------------------------------------------------------
function int Compare(UWindowList T, UWindowList B)
{
	if (Caps(PlayerVoteListItem(T).PlayerName) < Caps(PlayerVoteListItem(B).PlayerName))
		return -1;
	return 1;
}