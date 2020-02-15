class WeightedCube extends CompanionCube;

#exec TEXTURE IMPORT NAME=WeightedCube FILE=Textures\PortalCube_Weighted.BMP FLAGS=2

Auto State Animate
{
	Function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType) {}
}

Defaultproperties
{
	bPushable=false
	MultiSkins(1)=WeightedCube
}