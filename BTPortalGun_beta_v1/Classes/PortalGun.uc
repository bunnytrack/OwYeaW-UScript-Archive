class PortalGun extends TournamentWeapon;

/*##################################################################################################
## Sounds
##################################################################################################*/
#exec audio import file=Sounds\Portal_AmbientLoop.wav
#exec audio import file=Sounds\Portal_Connected.wav
#exec audio import file=Sounds\Portal_Open.wav
#exec audio import file=Sounds\Portal_Close.wav
#exec audio import file=Sounds\Portal_Close2.wav
#exec audio import file=Sounds\Portal_Enter.wav
#exec audio import file=Sounds\Portal_Exit.wav
#exec audio import file=Sounds\PortalGun_Shoot_Blue.wav
#exec audio import file=Sounds\PortalGun_Shoot_Yellow.wav
#exec audio import file=Sounds\Portal_Invalid_Surface.wav
#exec audio import file=Sounds\Portal_Fail.wav
#exec audio import file=Sounds\PortalGun_Selected.wav

/*##################################################################################################
## Textures
##################################################################################################*/
#exec texture import file=Textures\PortalBlue.bmp			FLAGS=2 MIPS=ON
#exec texture import file=Textures\PortalYellow.bmp			FLAGS=2 MIPS=ON
#exec texture import file=Textures\w_PortalGun.bmp			FLAGS=2	MIPS=ON
#exec texture import file=Textures\v_PortalGun.bmp			FLAGS=2	MIPS=ON
#exec texture import file=Textures\v_PortalGun_Glass.bmp	FLAGS=2	MIPS=ON
#exec texture import file=Textures\v_portalgun_glass_b.bmp	FLAGS=2	MIPS=ON
#exec texture import file=Textures\v_portalgun_glass_y.bmp	FLAGS=2	MIPS=ON

#exec texture import file=Textures\PortalBlueSparkTex.bmp	FLAGS=2	MIPS=ON
#exec texture import file=Textures\PortalYellowSparkTex.bmp	FLAGS=2	MIPS=ON

/*##################################################################################################
## Mesh - Portal
##################################################################################################*/
#exec MESH IMPORT MESH=portal ANIVFILE=MODELS\portal_a.3d DATAFILE=MODELS\portal_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=portal X=24 Y=0 Z=0

#exec MESH SEQUENCE MESH=portal SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=portal SEQ=portal STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=portal MESH=portal
#exec MESHMAP SCALE MESHMAP=portal X=0.1 Y=0.1 Z=0.2

/*##################################################################################################
## Mesh - Pickup
##################################################################################################*/
#exec MESH IMPORT MESH=p_PortalGun ANIVFILE=MODELS\w_PortalGun_a.3d DATAFILE=MODELS\w_PortalGun_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=p_PortalGun X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=p_PortalGun SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=p_PortalGun SEQ=W_PORTALGUN STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW			MESHMAP=p_PortalGun MESH=p_PortalGun
#exec MESHMAP SCALE			MESHMAP=p_PortalGun X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE	MESHMAP=p_PortalGun NUM=0  TEXTURE=w_PortalGun

/*##################################################################################################
## Mesh - ThirdPerson
##################################################################################################*/
#exec MESH IMPORT MESH=w_PortalGun ANIVFILE=MODELS\w_PortalGun_a.3d DATAFILE=MODELS\w_PortalGun_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=w_PortalGun X=-80 Y=0 Z=-12 YAW=0 PITCH=8 ROLL=0

#exec MESH SEQUENCE MESH=w_PortalGun SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=w_PortalGun SEQ=W_PORTALGUN STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW			MESHMAP=w_PortalGun MESH=w_PortalGun
#exec MESHMAP SCALE			MESHMAP=w_PortalGun X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE	MESHMAP=w_PortalGun NUM=0  TEXTURE=w_PortalGun

/*##################################################################################################
## Mesh - FirstPerson
##################################################################################################*/
#exec OBJ LOAD FILE=FILE\PGmesh.u PACKAGE=BTPortalGun
#exec MESHMAP SETTEXTURE MESHMAP=v_PortalGun NUM=1  TEXTURE=v_PortalGun
#exec MESHMAP SETTEXTURE MESHMAP=v_PortalGun NUM=2  TEXTURE=v_PortalGun_Glass

/*##################################################################################################
##
## Portal Gun Class
##
##################################################################################################*/
var PortalBlue Portal1, Portal2;

var enum EFireType
{
	Fire,
	AltFire
} FireType;

var enum EAnimType
{
	Fire,
	InvalidSurface,
	PortalReturn
} AnimType;

Replication
{
	Reliable if(Role == ROLE_Authority)
		Portal1, Portal2, Anim;
}

/*##################################################################################################
##
## Render Functions
##
##################################################################################################*/
Simulated Event RenderOverlays(Canvas C)
{
	local bool bPlayerOwner;
	local int Hand;
	local Rotator NewRot;

	if(bHideWeapon || (Owner == None))
		return;

	if(PlayerPawn(Owner) != None)
	{
		bPlayerOwner = true;
		Hand = PlayerPawn(Owner).Handedness;
	}
	if((Level.NetMode == NM_Client) && bPlayerOwner && (Hand == 2))
	{
		bHideWeapon = true;
		return;
	}
	if ( !bPlayerOwner || (PlayerPawn(Owner).Player == None) )
		PlayerPawn(Owner).WalkBob = vect(0, 0, 0);

	newRot = Pawn(Owner).ViewRotation;
	SetLocation(Owner.Location + CalcDrawOffset());

	if ( Hand == 0 )
		newRot.Roll = -2 * Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll * Hand;
	setRotation(newRot);
	C.DrawActor(Self, false);
}

/*##################################################################################################
##
## Fire Functions
##
##################################################################################################*/
Function Fire(float value)
{
	bPointing = true;
	bCanClientFire = true;
	Pawn(Owner).PlayRecoil(FiringSpeed);

	if( Owner.Isa('playerpawn') )
		Traceng(Fire);
}

Function AltFire(float value)
{
	bPointing = true;
	bCanClientFire = true;
	Pawn(Owner).PlayRecoil(FiringSpeed);

	if( Owner.Isa('playerpawn') )
		Traceng(AltFire);
}

Function Traceng(EFireType FireType)
{
	local Vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local Actor Other;

	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z; 

	AdjustedAim = Pawn(Owner).AdjustAim(1000000, StartTrace, 2.75 * AimError, False, False);
	EndTrace = StartTrace + (10000 * vector(AdjustedAim));

	Other = Pawn(Owner).Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

	if(Other != None)
	{
		if( !AntiPortalZone(Pawn(Owner), HitLocation, AdjustedAim) )
		{
			Owner.MakeNoise(Pawn(Owner).SoundDampening);
			if( !AntiPortalMover(Other) )
			{
				if( !AntiPortalActor(StartTrace, HitLocation, AdjustedAim, FireType) )
				{
					if( !CollidingPortal(HitLocation, FireType) )
					{
						if( Other == Level || Other.IsA('Mover') )
						{
							ShootPortal(Other, HitLocation, HitNormal, FireType);
							Anim(Fire);
							ColoredGlass(FireType);
						}
						else
						{
							Anim(InvalidSurface);
							// Shooting on Nothing
							// No Effectz needed
						}
					}
					else
					{
						Anim(PortalReturn);
						ColoredGlass(FireType);
						Effectz(Hitlocation, Hitnormal, FireType);
						// Shooting in own Portal
					}
				}
				else
				{
					Anim(InvalidSurface);
					ColoredGlass(FireType);
					// Shooting on an Anti Portal Actor
					// Effectz done via Function AntiPortalActor
				}
			}
			else
			{
				Anim(InvalidSurface);
				ColoredGlass(FireType);
				Effectz(Hitlocation, Hitnormal, FireType);
				// Shooting on an Anti Portal Mover
			}
		}
		else
		{
			Anim(InvalidSurface);
			// Shooting from or inside an Anti Portal Zone
			// No Effectz needed
		}
	}
	else
	{
		Anim(InvalidSurface);
		// Shooting on Nothing
		// No Effectz needed
	}
}

Function ShootPortal(Actor Other, Vector HitLocation, Vector HitNormal, EFireType FireType)
{
	if(FireType == Fire)
	{
		if(Portal1 != None)
		{
			Portal1.RemovePortal(Big, Destroy);
			Portal1 = None;
		}

		Portal1 = Spawn(class'PortalBlue',,, HitLocation + (8 * HitNormal), Rotator(HitNormal));
		if(Other.IsA('Mover'))
			Portal1.MoverName = Mover(Other);
	}
	else if(FireType == AltFire)
	{
		if(Portal2 != None)
		{
			Portal2.RemovePortal(Big, Destroy);
			Portal2 = None;
		}

		Portal2 = Spawn(class'PortalYellow',,, HitLocation + (8 * HitNormal), Rotator(HitNormal));
		if(Other.IsA('Mover'))
			Portal2.MoverName = Mover(Other);
	}
}

Simulated Function Effectz(Vector HitLocation, Vector HitNormal, EFireType FireType)
{
	local Spark3 Effect;

	if(FireType == Fire)
	{
		SpawnSparks(HitLocation, HitNormal, FireType);
		Effect = Spawn(class'Spark3',,, HitLocation, Rotator(HitNormal));
		Effect.DrawScale = 0.1;
	}
	else if(FireType == AltFire)
	{
		SpawnSparks(HitLocation, HitNormal, FireType);
		Effect = Spawn(class'Spark34',,, HitLocation, Rotator(HitNormal));
		Effect.DrawScale = 0.1;
	}
}

Function SpawnSparks(Vector HitLocation, Vector HitNormal, EFireType FireType)
{
	local PortalBlue_Spark Spark;
	local int NumSparks;
	local int x;

	NumSparks = FMax(Rand(16), 8);
	if(FireType == Fire)
	{
		for (x = 0; x < NumSparks; x++)
		{
			Spark = Spawn(class'PortalBlue_Spark',,, HitLocation + (8 * HitNormal), Rotator(HitNormal));
			Spark.Velocity = (HitLocation + VRand()) * 125 * FRand();
		}
	}
	else if(FireType == AltFire)
	{
		for (x = 0; x < NumSparks; x++)
		{
			Spark = Spawn(class'PortalYellow_Spark',,, HitLocation + (8 * HitNormal), Rotator(HitNormal));
			Spark.Velocity = (HitLocation + VRand()) * 125 * FRand();
		}
	}
}

Simulated Function ColoredGlass(EFireType FireType)
{
	if(FireType == Fire)
	{
		MultiSkins[2] = Texture'v_portalgun_glass_b';
		SetTimer(0.05, false);
	}
	else if(FireType == AltFire)
	{
		MultiSkins[2] = Texture'v_portalgun_glass_y';
		SetTimer(0.05, false);
	}
}

Simulated Function Timer()
{
	MultiSkins[2] = None;
}

/*##################################################################################################
##
## Anti-Portal Stuff
##
##################################################################################################*/
Function bool AntiPortalActor(Vector StartTrace, Vector EndTrace, Rotator AdjustedAim, EFireType FireType)
{
	local Vector EffectLocation, EffectNormal;
	local Vector BlockLocation, BlockNormal;
	local bool bFoundAntiPortalActor;
	local AntiPortalActor A;

	foreach TraceActors(class'AntiPortalActor', A, BlockLocation, BlockNormal, EndTrace + (4 * vector(AdjustedAim)), StartTrace - (4 * vector(AdjustedAim)) )
	{
		if( A.IsA('AntiPortalActor') )
		{
			EffectLocation = BlockLocation;
			EffectNormal = BlockNormal;
			bFoundAntiPortalActor = true;
			break;
		}
	}

	if(bFoundAntiPortalActor)
	{
		Effectz(EffectLocation, EffectNormal, FireType);
		return true;
	}
	else
		return false;
}

Function bool CollidingPortal(Vector PortalLocation, EFireType FireType)
{
	local PortalBlue Bro;

	foreach VisibleCollidingActors(class'PortalBlue', Bro, 78, PortalLocation)
	{
		if( (Bro.Instigator == Pawn(Owner) && Bro.IsA('PortalYellow') && FireType == Fire)
		||	(Bro.Instigator == Pawn(Owner) && !Bro.IsA('PortalYellow') && FireType == AltFire) )
		{
			Bro.RemovePortal(Spray, Destroy);

			if(FireType == Fire)
			{
				if(Portal1 != None)
				{
					Portal1.RemovePortal(Big, Destroy);
					Portal1 = None;
				}
			}
			else if(FireType == AltFire)
			{
				if(Portal2 != None)
				{
					Portal2.RemovePortal(Big, Destroy);
					Portal2 = None;
				}
			}
			return true;
		}
	}
	return false;
}

Function bool AntiPortalZone(Pawn P, Vector HitLocation, Rotator AdjustedAim)
{
	local bool bAntiPortalZone;
	local AntiPortalChecker APC;

	APC = Spawn(class'AntiPortalChecker',,, HitLocation - (4 * vector(AdjustedAim)));
	if(APC != None)
		if( APC.Region.Zone.IsA('AntiPortalZoneInfo') || APC.Region.Zone.IsA('AntiPortalWaterZone') || APC.Region.Zone.IsA('AntiPortalLavaZone') || APC.Region.Zone.IsA('AntiPortalSlimeZone') )
			bAntiPortalZone = true;
	else if( P.Region.Zone.IsA('AntiPortalZoneInfo') || P.Region.Zone.IsA('AntiPortalWaterZone') || P.Region.Zone.IsA('AntiPortalLavaZone') || P.Region.Zone.IsA('AntiPortalSlimeZone') )
		bAntiPortalZone = true;

	APC.Destroy();
	if(bAntiPortalZone)
		return true;
	else
		return false;
}

Function bool AntiPortalMover(Actor A)
{
	if( A.IsA('AntiPortalAttachMover') || A.IsA('AntiPortalAssertMover') || A.IsA('AntiPortalFurryMover4') )
		return true;
	else
		return false;
}

/*##################################################################################################
##
## Dumb Stuff
##
##################################################################################################*/
simulated function bool ClientFire( float Value ) {}
simulated function bool ClientAltFire( float Value ) {}
/*##################################################################################################
##
## States
##
##################################################################################################*/
simulated state NormalFire
{
	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function Fire(float F) {}
	function AltFire(float F) {}

	function AnimEnd()
	{
		Finish();
	}

Begin:
	Sleep(0.0);
}

/*##################################################################################################
##
## Animation Functions
##
##################################################################################################*/
Simulated Function Anim(EAnimType Animation)
{
	if(Animation == Fire)
	{
		if ( Role < ROLE_Authority || Level.NetMode != NM_DedicatedServer )
			PlayAnim('Fire', 1.3, 0);
	}
	else if(Animation == InvalidSurface)
	{
		Owner.PlaySound(Sound'Portal_Invalid_Surface', SLOT_None, 16.0);
		if ( Role < ROLE_Authority || Level.NetMode != NM_DedicatedServer )
			PlayAnim('Fizzle', 1.0, 0);
	}
	else if(Animation == PortalReturn)
	{
		Owner.PlaySound(Sound'Portal_Fail', SLOT_None, 16.0);
		if ( Role < ROLE_Authority || Level.NetMode != NM_DedicatedServer )
			PlayAnim('Release', 1.0, 0);
	}
	GotoState('NormalFire');
}

/*##################################################################################################
##
## Function Destroy
##
##################################################################################################*/
event Destroyed()
{
	if(Portal1 != None)
		Portal1.RemovePortal(Big, Left);
	if(Portal2 != None)
		Portal2.RemovePortal(Big, Left);
}

/*##################################################################################################
##
## Default Properties
##
##################################################################################################*/
Defaultproperties
{
	ItemName="Portal Gun"
	PickupMessage="You got the Portal Gun"
	StatusIcon=Texture'Botpack.Icons.UseTrans'
	Icon=Texture'Botpack.Icons.UseTrans'
	Mesh=LodMesh'p_PortalGun'
	DrawScale=1.75
	bNoSmooth=False
	PlayerViewMesh=SkeletalMesh'v_portalgun'
	PlayerViewOffset=(X=-6.00,Y=0.00,Z=0.00)
	PlayerViewScale=1
	ThirdPersonMesh=LodMesh'w_PortalGun'
	ThirdPersonScale=1.30
	PickupViewMesh=LodMesh'p_PortalGun'
	PickupViewScale=1.75
	PickupMessage="You got the Portal Gun"
	PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
	SelectSound=Sound'PortalGun_Selected'
	LODBias=16
	bEdShouldSnap=true
	CollisionRadius=16
	CollisionHeight=8
	DeathMessage="%o was killed by %k's portals"
}