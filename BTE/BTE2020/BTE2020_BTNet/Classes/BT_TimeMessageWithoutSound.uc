//=============================================================================
// BT_TimeMessageWithoutSound made by OwYeaW
//=============================================================================
class BT_TimeMessageWithoutSound extends LocalMessagePlus;
//-----------------------------------------------------------------------------
var localized string TimeMessage[16];
//-----------------------------------------------------------------------------
static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.TimeMessage[Switch];
}
//-----------------------------------------------------------------------------
static simulated function ClientReceive( 
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}
//-----------------------------------------------------------------------------
defaultproperties
{
	TimeMessage(0)="5 minutes left in the game!"
	TimeMessage(2)="3 minutes left in the game!"
	TimeMessage(3)="2 minutes left in the game!"
	TimeMessage(4)="1 minute left in the game!"
	TimeMessage(5)="30 seconds left!"
	TimeMessage(6)="10 seconds left!"
	TimeMessage(7)="9..."
	TimeMessage(8)="8..."
	TimeMessage(9)="7..."
	TimeMessage(10)="6..."
	TimeMessage(11)="5 seconds and counting..."
	TimeMessage(12)="4..."
	TimeMessage(13)="3..."
	TimeMessage(14)="2..."
	TimeMessage(15)="1..."
	bBeep=False
	bIsSpecial=False
}