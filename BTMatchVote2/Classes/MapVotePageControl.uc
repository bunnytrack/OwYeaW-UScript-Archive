//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MatchVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class MapVotePageControl expands UMenuPageControl;

function KeyDown(int Key, float X, float Y)
{
	super.KeyDown(Key, X, Y);
	ParentWindow.KeyDown(Key, X, Y);
}