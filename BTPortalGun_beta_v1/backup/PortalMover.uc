// =============================================================================
// ActorAttacher
// =============================================================================
// (c) 2001 by ElBundee
// =============================================================================
// You may be right - I may be crazy
// =============================================================================

class PortalMover extends Keypoint;

// I never figured out how the AttachMover is supposed to work - so I
// made this actor. Allows attachment of a MAXIMUM AMOUNT of 8 actors to a
// specified mover, so that they will move as the mover moves, keeping their 
// relative position to the mover. Of course you can use more than one 
// ActorAttacher to attach more than 8 actors.
//
// The relative positions are determined by the positions of the actors
// during the first keyframe (0) of the mover. Note that bNoDelete of 
// Pickups has to be TRUE.


// =============================================================================
// Properties
// =============================================================================

var() Actor   PortalName;		// Names of Portal to be attached
var() Mover   MoverName;        // Name of Mover to attached to

// =============================================================================
// Variables
// =============================================================================

var   Rotator AttachRot;     // Remember the relative rotation
var   Vector  AttachVec;     // Remember the relative location

// =============================================================================
// Tick
// =============================================================================

simulated function Tick(float DeltaTime)
{
	local rotator R;
	local vector  V;

	if(PortalName != None && MoverName != None)
	{
		R = MoverName.Rotation - MoverName.KeyRot[0];

		V.X = (MoverName.Location + (AttachVec >> R)).X;
		V.Y = (MoverName.Location + (AttachVec >> R)).Y;
		V.Z = (MoverName.Location + (AttachVec >> R)).Z;

		PortalName.SetLocation(V);

		R.Yaw = (MoverName.Rotation + AttachRot).Yaw;
		R.Roll = (MoverName.Rotation + AttachRot).Roll;
		R.Pitch = (MoverName.Rotation + AttachRot).Pitch;

		PortalName.SetRotation(R);
	}
}


// =============================================================================
// PostBeginPlay
// =============================================================================

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(PortalName != None)
	{
		AttachRot = PortalName.Rotation - MoverName.Rotation;
		AttachVec = PortalName.Location - MoverName.Location;
	}
}

defaultproperties
{
	bStatic=false
}