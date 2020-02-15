//=============================================================================
// BT_CTFMessage made by OwYeaW
//=============================================================================
class BT_CTFMessage extends LocalMessagePlus;
//-----------------------------------------------------------------------------
var localized string ReturnBlue, ReturnRed;
var localized string ReturnedBlue, ReturnedRed;
var localized string CaptureBlue, CaptureRed;
var localized string DroppedBlue, DroppedRed;
var localized string HasBlue,HasRed;
//-----------------------------------------------------------------------------
static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		// Captured the flag.
		case 0:
			if (RelatedPRI_1 == None)
				return "";
			if ( CTFFlag(OptionalObject) == None )
				return "";

			if ( CTFFlag(OptionalObject).Team == 0 )
				return RelatedPRI_1.PlayerName@Default.CaptureRed;
			else
				return RelatedPRI_1.PlayerName@Default.CaptureBlue;
			break;

		// Returned the flag.
		case 1:
			if ( CTFFlag(OptionalObject) == None )
				return "";
			if (RelatedPRI_1 == None)
			{
				if ( CTFFlag(OptionalObject).Team == 0 )
					return Default.ReturnedRed;
				else
					return Default.ReturnedBlue;
			}
			if ( CTFFlag(OptionalObject).Team == 0 )
				return RelatedPRI_1.PlayerName@Default.ReturnRed;
			else
				return RelatedPRI_1.PlayerName@Default.ReturnBlue;
			break;

		// Dropped the flag.
		case 2:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return RelatedPRI_1.PlayerName@Default.DroppedRed;
			else
				return RelatedPRI_1.PlayerName@Default.DroppedBlue;
			break;

		// Was returned.
		case 3:
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return Default.ReturnedRed;
			else
				return Default.ReturnedBlue;
			break;

		// Has the flag.
		case 4:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return RelatedPRI_1.PlayerName@Default.HasRed;
			else
				return RelatedPRI_1.PlayerName@Default.HasBlue;
			break;

		// Auto send home.
		case 5:
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return Default.ReturnedRed;
			else
				return Default.ReturnedBlue;
			break;

		// Pickup
		case 6:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return RelatedPRI_1.PlayerName@Default.HasRed;
			else
				return RelatedPRI_1.PlayerName@Default.HasBlue;
			break;
	}
	return "";
}
//-----------------------------------------------------------------------------
defaultproperties
{
	ReturnBlue="returns the blue flag!"
	ReturnRed="returns the red flag!"
	ReturnedBlue="The blue flag was returned!"
	ReturnedRed="The red flag was returned!"
	CaptureBlue="captured the blue flag!"
	CaptureRed="captured the red flag!"
	DroppedBlue="dropped the blue flag!"
	DroppedRed="dropped the red flag!"
	HasBlue="has the blue flag!"
	HasRed="has the red flag!"
	bIsConsoleMessage=False
	bIsSpecial=False
}