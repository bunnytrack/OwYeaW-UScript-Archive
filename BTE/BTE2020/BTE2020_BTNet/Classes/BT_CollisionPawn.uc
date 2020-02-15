//=============================================================================
// BT_CollisionPawn made by OwYeaW
//=============================================================================
class BT_CollisionPawn expands BT_CollisionActor;
//-----------------------------------------------------------------------------
#exec texture IMPORT NAME=BT_CylinderPawn_SIDE	FILE=BTE_Files\BT_CylinderPawn_SIDE.BMP
#exec texture IMPORT NAME=BT_CylinderPawn_TOP	FILE=BTE_Files\BT_CylinderPawn_TOP.BMP
//-----------------------------------------------------------------------------
var Pawn myPawn;
var bool bWallhack, bHide;

function Tick(float Delta)
{
	local float viewDist;
	local vector camLoc;
	local rotator camRot;
	local Actor camActor;

	//	Move with the Pawn it's attached to
	if(myPawn != None)
	{
		if(CentralLoc != myPawn.Location)
			CentralLoc = myPawn.Location;
	}
	else
		Destroy();

	//	Calculate new location and prepivot and make the mesh always visible
	LocalPlayer.PlayerCalcView(camActor, camLoc, camRot);

	viewDist = VSize(camLoc - CentralLoc);
	if(viewDist <= RadiusView)
	{
		SetLocation(camLoc + vector(camRot) * RenderDistance); //set the actor on front of the player, at a distance set by RenderDistance
		PrePivot = CentralLoc - Location;
	}
	else if(Location != CentralLoc)
	{
		SetLocation(CentralLoc);
		PrePivot = vect(0,0,0);
	}

	if((LocalPlayer.ViewTarget == myPawn || LocalPlayer == myPawn) && !LocalPlayer.bBehindview)
	{
		bHide = true;
		bHidden = true;
	}
	else
	{
		bHide = false;
		bHidden = bWallhack;
	}
}

defaultproperties
{
	Skin=Texture'BT_CylinderPawn_TOP'
	MultiSkins(0)=Texture'BT_CylinderPawn_SIDE'
}