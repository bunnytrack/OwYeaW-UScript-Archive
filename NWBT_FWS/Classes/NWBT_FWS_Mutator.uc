//==================================================================
// NWBT_FWS_Mutator made by OwYeaW
//==================================================================
//	FWS = Fast Weapon Switch
//	
//	Average UT switch speed is around 3
//	UTPure's FWS is around 7
//==================================================================
class NWBT_FWS_Mutator extends Mutator;

var(FastWeaponSwitch) float WeaponSwitchSpeed;

function PreBeginPlay()
{
	Level.Game.BaseMutator.AddMutator(self);
	Super.PreBeginPlay();
}

function ModifyPlayer(Pawn Other)
{
	local FWS_Handler H;

	if(NextMutator != None)
		NextMutator.ModifyPlayer(Other);

	ForEach Other.ChildActors(class'FWS_Handler', H)
		return;

	H = Spawn(class'FWS_Handler', Other);
	H.WeaponSwitchSpeed = WeaponSwitchSpeed;
}

defaultproperties
{
	WeaponSwitchSpeed=10
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	Texture=Texture'Engine.S_Flag'
	bEdShouldSnap=True
}