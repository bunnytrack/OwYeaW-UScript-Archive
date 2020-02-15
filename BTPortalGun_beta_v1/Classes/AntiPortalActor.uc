class AntiPortalActor extends Actor;

var() bool bInitiallyActive;

function Trigger( actor Other, pawn EventInstigator )
{
	bInitiallyActive = !bInitiallyActive;
	if ( bInitiallyActive )
		CheckTouchList();
}

function CheckTouchList()
{
	local int i;

	for (i=0; i < 4; i++)
		if ( Touching[i] != None )
			Touch(Touching[i]);
}

function Touch(Actor Other)
{
	local PortalBlue Portal;

	if(bInitiallyActive)
		if( PortalBlue(Other) != None )
			PortalBlue(Other).RemovePortal(Big, Destroy);
}

defaultproperties
{
	bHidden=True
	bEdShouldSnap=True
	bInitiallyActive=True
	CollisionRadius=32.000000
	CollisionHeight=32.000000
	bCollideActors=True
	Texture=Texture'Engine.S_Corpse'
}