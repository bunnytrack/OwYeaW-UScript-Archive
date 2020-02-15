//=============================================================================
// BT_CollisionActor made by OwYeaW
//=============================================================================
class BT_CollisionActor expands Actor;
//-----------------------------------------------------------------------------
#exec MESH IMPORT		MESH=BT_CA1 ANIVFILE=BTE_Files\BT_CylinderActorMesh_a.3d	DATAFILE=BTE_Files\BT_CylinderActorMesh_d.3d	X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=2
#exec MESH LODPARAMS	MESH=BT_CA1 STRENGTH=0
#exec MESH ORIGIN		MESH=BT_CA1 X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0

#exec MESH SEQUENCE		MESH=BT_CA1 SEQ=All			STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE		MESH=BT_CA1 SEQ=Still		STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE		MESHMAP=BT_CA1 X=1 Y=1 Z=1
//-----------------------------------------------------------------------------
#exec MESH IMPORT		MESH=BT_CA2 ANIVFILE=BTE_Files\BT_CylinderActorMesh_a.3d	DATAFILE=BTE_Files\BT_CylinderActorMesh_d.3d	X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=2
#exec MESH LODPARAMS	MESH=BT_CA2 STRENGTH=0
#exec MESH ORIGIN		MESH=BT_CA2 X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0

#exec MESH SEQUENCE		MESH=BT_CA2 SEQ=All			STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE		MESH=BT_CA2 SEQ=Still		STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE		MESHMAP=BT_CA2 X=1 Y=1 Z=2
//-----------------------------------------------------------------------------
#exec MESH IMPORT		MESH=BT_CA4 ANIVFILE=BTE_Files\BT_CylinderActorMesh_a.3d	DATAFILE=BTE_Files\BT_CylinderActorMesh_d.3d	X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=2
#exec MESH LODPARAMS	MESH=BT_CA4 STRENGTH=0
#exec MESH ORIGIN		MESH=BT_CA4 X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0

#exec MESH SEQUENCE		MESH=BT_CA4 SEQ=All			STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE		MESH=BT_CA4 SEQ=Still		STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE		MESHMAP=BT_CA4 X=1 Y=1 Z=4
//-----------------------------------------------------------------------------
#exec MESH IMPORT		MESH=BT_CA8 ANIVFILE=BTE_Files\BT_CylinderActorMesh_a.3d	DATAFILE=BTE_Files\BT_CylinderActorMesh_d.3d	X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=2
#exec MESH LODPARAMS	MESH=BT_CA8 STRENGTH=0
#exec MESH ORIGIN		MESH=BT_CA8	X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0

#exec MESH SEQUENCE		MESH=BT_CA8 SEQ=All			STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE		MESH=BT_CA8 SEQ=Still		STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE		MESHMAP=BT_CA8 X=1 Y=1 Z=8
//-----------------------------------------------------------------------------
#exec MESH IMPORT		MESH=BT_CA16 ANIVFILE=BTE_Files\BT_CylinderActorMesh_a.3d	DATAFILE=BTE_Files\BT_CylinderActorMesh_d.3d	X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=2
#exec MESH LODPARAMS	MESH=BT_CA16 STRENGTH=0
#exec MESH ORIGIN		MESH=BT_CA16 X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0

#exec MESH SEQUENCE		MESH=BT_CA16 SEQ=All		STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE		MESH=BT_CA16 SEQ=Still		STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE		MESHMAP=BT_CA16 X=1 Y=1 Z=16
//-----------------------------------------------------------------------------
#exec MESH IMPORT		MESH=BT_CA32 ANIVFILE=BTE_Files\BT_CylinderActorMesh_a.3d	DATAFILE=BTE_Files\BT_CylinderActorMesh_d.3d	X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=2
#exec MESH LODPARAMS	MESH=BT_CA32 STRENGTH=0
#exec MESH ORIGIN		MESH=BT_CA32 X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0

#exec MESH SEQUENCE		MESH=BT_CA32 SEQ=All		STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE		MESH=BT_CA32 SEQ=Still		STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE		MESHMAP=BT_CA32 X=1 Y=1 Z=32
//-----------------------------------------------------------------------------
#exec MESH IMPORT		MESH=BT_CA64 ANIVFILE=BTE_Files\BT_CylinderActorMesh_a.3d	DATAFILE=BTE_Files\BT_CylinderActorMesh_d.3d	X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=2
#exec MESH LODPARAMS	MESH=BT_CA64 STRENGTH=0
#exec MESH ORIGIN		MESH=BT_CA64 X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0

#exec MESH SEQUENCE		MESH=BT_CA64 SEQ=All		STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE		MESH=BT_CA64 SEQ=Still		STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE		MESHMAP=BT_CA64 X=1 Y=1 Z=64
//-----------------------------------------------------------------------------
#exec MESH IMPORT		MESH=BT_CA128 ANIVFILE=BTE_Files\BT_CylinderActorMesh_a.3d	DATAFILE=BTE_Files\BT_CylinderActorMesh_d.3d	X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=2
#exec MESH LODPARAMS	MESH=BT_CA128 STRENGTH=0
#exec MESH ORIGIN		MESH=BT_CA128 X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0

#exec MESH SEQUENCE		MESH=BT_CA128 SEQ=All		STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE		MESH=BT_CA128 SEQ=Still		STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE		MESHMAP=BT_CA128 X=1 Y=1 Z=128
//-----------------------------------------------------------------------------
#exec MESH IMPORT		MESH=BT_CA256 ANIVFILE=BTE_Files\BT_CylinderActorMesh_a.3d	DATAFILE=BTE_Files\BT_CylinderActorMesh_d.3d	X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=2
#exec MESH LODPARAMS	MESH=BT_CA256 STRENGTH=0
#exec MESH ORIGIN		MESH=BT_CA256 X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0

#exec MESH SEQUENCE		MESH=BT_CA256 SEQ=All		STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE		MESH=BT_CA256 SEQ=Still		STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE		MESHMAP=BT_CA256 X=1 Y=1 Z=256
//-----------------------------------------------------------------------------
#exec MESH IMPORT		MESH=BT_CA512 ANIVFILE=BTE_Files\BT_CylinderActorMesh_a.3d	DATAFILE=BTE_Files\BT_CylinderActorMesh_d.3d	X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=2
#exec MESH LODPARAMS	MESH=BT_CA512 STRENGTH=0
#exec MESH ORIGIN		MESH=BT_CA512 X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0

#exec MESH SEQUENCE		MESH=BT_CA512 SEQ=All		STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE		MESH=BT_CA512 SEQ=Still		STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE		MESHMAP=BT_CA512 X=1 Y=1 Z=512
//-----------------------------------------------------------------------------
#exec MESH IMPORT		MESH=BT_CA1024 ANIVFILE=BTE_Files\BT_CylinderActorMesh_a.3d	DATAFILE=BTE_Files\BT_CylinderActorMesh_d.3d	X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=2
#exec MESH LODPARAMS	MESH=BT_CA1024 STRENGTH=0
#exec MESH ORIGIN		MESH=BT_CA1024 X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0

#exec MESH SEQUENCE		MESH=BT_CA1024 SEQ=All		STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE		MESH=BT_CA1024 SEQ=Still	STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE		MESHMAP=BT_CA1024 X=1 Y=1 Z=1024
//-----------------------------------------------------------------------------
#exec MESH IMPORT		MESH=BT_CA2048 ANIVFILE=BTE_Files\BT_CylinderActorMesh_a.3d	DATAFILE=BTE_Files\BT_CylinderActorMesh_d.3d	X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=2
#exec MESH LODPARAMS	MESH=BT_CA2048 STRENGTH=0
#exec MESH ORIGIN		MESH=BT_CA2048 X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0

#exec MESH SEQUENCE		MESH=BT_CA2048 SEQ=All		STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE		MESH=BT_CA2048 SEQ=Still	STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE		MESHMAP=BT_CA2048 X=1 Y=1 Z=2048
//-----------------------------------------------------------------------------
var PlayerPawn LocalPlayer;
var float RadiusView;
var float RenderDistance;
var vector CentralLoc;
var Actor AttachActor;
var Vector AttachVec;

function Initialize(float W, float H)
{
	local int Multiplier;

	RadiusView = FMax(W, H) * 1.5;

	if(H*2 <= W)
	{
		Mesh = LodMesh'BT_CA1';
		Multiplier = 1;
	}
	if(H <= W)
	{
		Mesh = LodMesh'BT_CA2';
		Multiplier = 2;
	}
	else if(H/2 <= W)
	{
		Mesh = LodMesh'BT_CA4';
		Multiplier = 4;
	}
	else if(H/4 <= W)
	{
		Mesh = LodMesh'BT_CA8';
		Multiplier = 8;
	}
	else if(H/8 <= W)
	{
		Mesh = LodMesh'BT_CA16';
		Multiplier = 16;
	}
	else if(H/16 <= W)
	{
		Mesh = LodMesh'BT_CA32';
		Multiplier = 32;
	}
	else if(H/32 <= W)
	{
		Mesh = LodMesh'BT_CA64';
		Multiplier = 64;
	}
	else if(H/64 <= W)
	{
		Mesh = LodMesh'BT_CA128';
		Multiplier = 128;
	}
	else if(H/128 <= W)
	{
		Mesh = LodMesh'BT_CA256';
		Multiplier = 256;
	}
	else if(H/256 <= W)
	{
		Mesh = LodMesh'BT_CA512';
		Multiplier = 512;
	}
	else if(H/512 <= W)
	{
		Mesh = LodMesh'BT_CA1024';
		Multiplier = 1024;
	}
	else if(H/1024 <= W)
	{
		Mesh = LodMesh'BT_CA2048';
		Multiplier = 2048;
	}
	else
		Destroy();

	DrawScale = FMax(W/256, 0.002);
	AnimFrame = (FMax(H, 1)/(128*Multiplier)/DrawScale) * 0.5;
	SetRotation(Rotator(Vect(0,0,0)));
}

function Tick(float Delta)
{
	local float viewDist;
	local vector camLoc;
	local rotator camRot;
	local Actor camActor;
	local Vector V;

	//	Move with the Actors it's attached to
	if(AttachActor != None)
	{
		V.X = (AttachActor.Location + AttachVec).X;
		V.Y = (AttachActor.Location + AttachVec).Y;
		V.Z = (AttachActor.Location + AttachVec).Z;

		if(V != CentralLoc)
			CentralLoc = V;
	}

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
}

defaultproperties
{
	RenderDistance=32
	Mesh=LodMesh'BT_CA1'
	AnimSequence=All
	Style=STY_Translucent
	DrawType=DT_Mesh
	VisibilityHeight=5000
	VisibilityRadius=5000
}