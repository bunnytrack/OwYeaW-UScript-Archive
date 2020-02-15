/*##################################################################################################
##
##  BTCheckPoints 1.0
##  Copyright (C) 2010 Patrick "Sp0ngeb0b" Peltzer
##
##  This program is free software; you can redistribute and/or modify
##  it under the terms of the Open Unreal Mod License version 1.1.
##
##  Contact: spongebobut@yahoo.com | www.unrealriders.de
##
####################################################################################################
##
## Class: Checkpoint
##
##################################################################################################*/
class CheckPoint extends Decoration;

#exec TEXTURE IMPORT NAME=CheckPointFlag FILE=Textures\CheckPointFlag.pcx

var vector OrgLocation;       // Original Player Location
var rotator OrgRotation;      // Original Player Rotation

/*##################################################################################################
##
## PostBeginPlay -> Set mesh, skin, and animation
##
##################################################################################################*/
function PostBeginPlay()
{
	local vector currLocation;
	local Rotator currRotation;

	// Save original location and rotation
	OrgLocation = Location;
	OrgRotation = Rotation;

	currLocation = Location;
	currLocation.Z += 16.0;   // Put the flag on the ground
	currRotation = Rotation;
	currRotation.Yaw += 32678;
	currRotation.Pitch = -3200;
	currRotation.Roll = 65536;
	setLocation(currLocation);
	SetRotation(currRotation);

	LoopAnim('newflag');
}

defaultproperties
{
	bUnlit=True
	LightBrightness=255
	LightHue=20
	LightSaturation=64
	LightEffect=LE_Shock
	LightRadius=8
	LightType=LT_Steady
	DrawType=DT_Mesh
	Style=STY_Masked
	Mesh=LodMesh'Botpack.newflag'
	Skin=Texture'CheckPointFlag'
	Multiskins(0)=Texture'CheckPointFlag'
	bNoDelete=false
	bStatic=false
	bCollideActors=true
}