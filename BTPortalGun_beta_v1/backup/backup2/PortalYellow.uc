class PortalYellow extends PortalBlue;

defaultproperties
{
	CollisionRadius=39.000000
	CollisionHeight=39.000000
	Physics=PHYS_Rotating
	RotationRate=(Pitch=0,Yaw=0,Roll=100000)
	DrawType=DT_Mesh
	Mesh=LodMesh'portal'
	bUnlit=True
	DrawScale=2
	Style=STY_Translucent	
	Skin=Texture'PortalYellow'
	AmbientSound=sound'Portal_AmbientLoop'
	SoundRadius=32
	SoundVolume=255
}