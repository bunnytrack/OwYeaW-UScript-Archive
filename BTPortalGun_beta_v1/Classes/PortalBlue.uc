class PortalBlue extends Actor;

var()	PortalBlue	Brother;
var()	Mover		MoverName;

var		bool		bTouched, bDestroyed, bCheckedMover;
var		Rotator		ExitRotation;
var		Pawn		PortalOwner;

var		Vector		AttachVec;
var		Rotator		AttachRot;
var		Rotator		MoverBaseRot;
var		int			MoverRollRot;

var		string		PortName;
var		string		CheckPortNames[16];

var enum ESoundType
{
	Destroy,
	Left
} SoundType;

var enum ESparkType
{
	Big,
	Spray
} SparkType;

Replication
{
	Reliable if ( Role == ROLE_Authority )
		Brother, PortName, PortalOwner;
}

/*##################################################################################################
##
## Spawn and Destroy Functions
##
##################################################################################################*/
Function Spawned()
{
	local PortalBlue Bro;
	local int x;

	SpawnBigSpark();
	PlaySound(Sound'Portal_Open', SLOT_Misc, 16.0);

	if(Instigator != None)
	{
		PortalOwner = Instigator;

		foreach AllActors(class'PortalBlue', Bro)
		{
			if(Bro.PortalOwner == Self.PortalOwner && Bro != Self)
			{
				Brother = Bro;
				Bro.Brother = Self;
				Bro.PlaySound(Sound'Portal_Connected', SLOT_Misc, 16.0);
			}
		}
	}

	if(Brother != None)
	{
		for(x = 0; Brother.CheckPortNames[x] != ""; x++)
			Brother.CheckPortNames[x] = "";

		CheckPortCollision();
		Brother.CheckPortCollision();
	}
}

Function CheckPortCollision()
{
	local Actor A;
	local int x;

	foreach VisibleCollidingActors(class'Actor', A, 78, Location)
	{
		if( CheckNames(string(A.Name)) && x < 17 )
		{
			Touch(A);
			Brother.CheckPortNames[x] = string(A.Name);
			x++;
		}
	}
}

Function bool CheckNames(string Str)
{
	local int x;

	for(x = 0; CheckPortNames[x] != ""; x++)
		if(CheckPortNames[x] == Str)
			return false;

	return true;
}

Function FireSoundz()
{
	if( Self.IsA('PortalYellow') )
		PortalOwner.PlaySound(Sound'PortalGun_Shoot_Yellow', SLOT_None, 16.0);
	else
		PortalOwner.PlaySound(Sound'PortalGun_Shoot_Blue', SLOT_None, 16.0);
}

Function RemovePortal(ESparkType SparkType, ESoundType SoundType)
{
	local PortalBlue_Impact Effect;

	if(!bDestroyed)
	{
		bDestroyed = true;

		if(SparkType == Spray)
			SpawnSparks();
		else if(SparkType == Big)
			SpawnBigSpark();

		if(SoundType == Destroy)
			PlaySound(Sound'Portal_Close', SLOT_Misc, 16.0);
		else if(SoundType == Left)
			PlaySound(Sound'Portal_Close2', SLOT_Misc, 16.0);

		if(MoverName != None)
			MoverName = None;
		if(Brother != None)
			Brother.Brother = None;
		Brother = None;
		Destroy();
	}
}

Function SpawnSparks()
{
	local PortalBlue_Spark Spark;
	local int NumSparks;
	local int x;

	NumSparks = FMax(Rand(16), 8);
	if( Self.IsA('PortalYellow') )
	{
		for (x = 0; x < NumSparks; x++)
		{
			Spark = Spawn(class'PortalYellow_Spark',,, Location + 8 * Vector(Rotation), Rotation);
			Spark.Velocity = (Vector(Rotation) + VRand()) * 125 * FRand();
		}
	}
	else
	{
		for (x = 0; x < NumSparks; x++)
		{
			Spark = Spawn(class'PortalBlue_Spark',,, Location + 8 * Vector(Rotation), Rotation);
			Spark.Velocity = (Vector(Rotation) + VRand()) * 125 * FRand();
		}
	}
}

Function SpawnBigSpark()
{
	local Spark3 Effect;

	if( Self.IsA('PortalYellow') )
	{
		Effect = Spawn(class'Spark34',,, Location, Rotation);
		Effect.DrawScale = 1.5;
	}
	else
	{
		Effect = Spawn(class'Spark3',,, Location, Rotation);
		Effect.DrawScale = 1.5;
	}
}

Function Destroyed()
{
	bDestroyed = true;
	Disable('Tick');
	if(MoverName != None)
		MoverName = None;
	if(Brother != None)
		Brother.Brother = None;
	Brother = None;
}

/*##################################################################################################
##
## Tick and Timer Stuff
##
##################################################################################################*/
Function Tick(float delta)
{
	local Rotator	R;
	local Vector	V;

	if(MoverName != None)
	{
		if(!bCheckedMover)
			CheckMover();
		else
		{
			R = MoverName.Rotation - MoverBaseRot - MoverName.KeyRot[0];

			V.X = (MoverName.Location + (AttachVec >> R)).X;
			V.Y = (MoverName.Location + (AttachVec >> R)).Y;
			V.Z = (MoverName.Location + (AttachVec >> R)).Z;

			SetLocation(V);

			R.Yaw = (MoverName.Rotation + AttachRot).Yaw;
			R.Pitch = (MoverName.Rotation + AttachRot).Pitch;
			if(MoverRollRot == MoverName.Rotation.Roll)
				R.Roll = Rotation.Roll;
			else
				R.Roll = (MoverName.Rotation + AttachRot).Roll;

			SetRotation(R);
		}
	}

	if(PortalOwner != None)
		if(PortalOwner.FindInventoryType(class'BTPortalGun_beta_v1.PortalGun') == None)
			RemovePortal(Big, Left);
}

Function CheckMover()
{
	AttachVec = Location - MoverName.Location;
	AttachRot = Rotation - MoverName.Rotation;
	MoverBaseRot = MoverName.Rotation;
	MoverRollRot = MoverName.Rotation.Roll;
	bCheckedMover = !bCheckedMover;
}

Simulated Function Timer()
{
	if(PortName != "")
		PortName = "";
}

/*##################################################################################################
##
## Touch
##
##################################################################################################*/
Simulated Function Touch(Actor Other)
{
	if( Brother != None && Brother.PortName != string(Other.Name) )
	{
		PortName = string(Other.Name);
		Brother.PortName = string(Other.Name);

		if( Other.IsA('PlayerPawn') )
		{
			PortEnter();
			RotatePlayer(PlayerPawn(Other));
			PortPawn(Pawn(Other));
			PortExit();
		}
		else if( Other.IsA('ScriptedPawn') || Other.IsA('NaliRabbit') || Other.IsA('Bird1') )
		{
			PortEnter();
			RotateMonster(Pawn(Other));
			PortPawn(Pawn(Other));
			PortExit();
		}
		else if( Other.IsA('Bot') )
		{
			PortEnter();
			RotateBot(Pawn(Other));
			PortPawn(Pawn(Other));
			PortExit();
		}
		else if( Other.IsA('Weapon') && Other.Instigator != None)
		{
			PortEnter();
			PortWeapon(Weapon(Other));
			PortExit();
		}
		else if( Other.IsA('Decoration') && Decoration(Other).bPushable )
		{
			PortEnter();
			PortDecoration(Decoration(Other));
			PortExit();
		}
		else if( Other.IsA('Projectile') && !Other.IsA('TranslocatorTarget') )
		{
			PortEnter();
			PortProjectile(Projectile(Other));
			PortExit();
		}

		if(PortName != "")
		{
			SetTimer(0.25, false);
			Brother.SetTimer(0.01, false);
		}
	}
}

/*##################################################################################################
##
## Port Sounds
##
##################################################################################################*/
Function PortEnter()
{
	PlaySound(Sound'Portal_Enter', SLOT_None, 16.0);
}

Function PortExit()
{
	Brother.PlaySound(Sound'Portal_Exit', SLOT_None, 16.0);
}

/*##################################################################################################
##
## Port Functions
##
##################################################################################################*/
Function PortPawn(Pawn P)
{
	local Vector V;

	V = P.Velocity;

	if(P.Region.Zone.bWaterZone)
		P.SetPhysics(PHYS_Falling);

	P.SetLocation(Brother.Location);
	if(!P.Region.Zone.bWaterZone)
		P.SetPhysics(PHYS_Falling);
	else
		P.SetPhysics(PHYS_Swimming);
	P.Velocity = Vsize(V) * Vector(Brother.Rotation);
}

Function PortWeapon(Weapon W)
{
	W.SetLocation(Brother.Location);
	W.Velocity = Vsize(W.Velocity) * Vector(Brother.Rotation);
	W.RemoteRole = ROLE_SimulatedProxy;

	if(W.Physics != PHYS_Falling)
		W.SetPhysics(PHYS_Falling);
}

Function PortDecoration(Decoration D)
{
	local Vector V;

	V = D.Velocity;
	D.SetPhysics(PHYS_None);
	D.SetLocation(Brother.Location);
	D.SetPhysics(PHYS_Falling);
	D.Velocity = Vsize(V) * Vector(Brother.Rotation);

	if(PortalOwner != None)
		D.Instigator = PortalOwner;
}

Simulated Function PortProjectile(Projectile P)
{
	local Projectile Proj;
	local Pawn GDR;

	if( P.IsA('UT_Grenade') || P.IsA('BioGlob') )
		PortSpecialProjectile(P);
	else
	{
		if(Role == ROLE_Authority)
		{
			Proj = Spawn(P.Class,,, Brother.Location, Brother.Rotation);
			PortName = string(Proj.Name);
			Proj.Instigator = P.Instigator;
			Proj.Speed = P.Speed;
			Proj.MaxSpeed = P.MaxSpeed;
			Proj.Damage = P.Damage;
			Proj.MomentumTransfer = P.MomentumTransfer;
		}
		if( Proj.IsA('GuidedWarshell') )
		{
			if(GuidedWarShell(P).Instigator != None)
			{
				GDR = GuidedWarShell(P).Instigator;

				GuidedWarShell(P).SetOwner(None);
				GuidedWarShell(P).Guider = None;
				PlayerPawn(GDR).ViewTarget = GuidedWarShell(Proj);
				GuidedWarShell(Proj).SetOwner(GDR);
				GuidedWarShell(Proj).Guider = GDR;
				WarHeadLauncher(GDR.Weapon).GuidedShell = GuidedWarShell(Proj);
				RotateGuider(GuidedWarshell(Proj), PlayerPawn(GDR));
			}
		}
		else if( Proj.IsA('Razor2') )
			Razor2(Proj).bCanHitInstigator = true;

		P.Destroy();
	}
}

Simulated Function PortSpecialProjectile(Projectile P)
{
	if( P.IsA('UT_Grenade') )
		UT_Grenade(P).bCanHitOwner = true;

	P.SetLocation(Brother.Location);
	P.Velocity = VSize(P.Velocity) * Vector(Brother.Rotation);
}

/*##################################################################################################
##
## Rotate Functions
##
##################################################################################################*/
Function RotatePlayer(PlayerPawn PP)
{
	if( Vert(Rotation.Pitch) && !Vert(Brother.Rotation.Pitch) )
	{
		ExitRotation.Yaw = PP.ViewRotation.Yaw;
		ExitRotation.Pitch = PP.ViewRotation.Pitch;
		ExitRotation.Roll = 0;
		PP.ClientSetRotation(ExitRotation);
		PP.ViewRotation = ExitRotation;
	}
	else if( !Vert(Rotation.Pitch) && Vert(Brother.Rotation.Pitch) )
	{
		ExitRotation = Brother.Rotation;
		ExitRotation.Pitch = PP.ViewRotation.Pitch;
		ExitRotation.Roll = 0;
		PP.ClientSetRotation(ExitRotation);
		PP.ViewRotation = ExitRotation;
	}
	else if( Vert(Rotation.Pitch) && Vert(Brother.Rotation.Pitch) )
	{
		ExitRotation = Brother.Rotation;
		ExitRotation.Yaw -= Rotation.Yaw - PP.ViewRotation.Yaw;
		ExitRotation.Roll = 0;
		ExitRotation = Rotator(-Vector(ExitRotation));
		ExitRotation.Pitch = PP.ViewRotation.Pitch;
		PP.ClientSetRotation(ExitRotation);
		PP.ViewRotation = ExitRotation;
	}
}

Function RotateMonster(Pawn P)
{
	if( Vert(Rotation.Pitch) && !Vert(Brother.Rotation.Pitch) )
	{
		ExitRotation.Yaw = P.ViewRotation.Yaw;
		ExitRotation.Pitch = P.ViewRotation.Pitch;
		ExitRotation.Roll = 0;
		P.SetRotation(ExitRotation);
		P.ViewRotation = ExitRotation;
	}
	else if( (!Vert(Rotation.Pitch) && Vert(Brother.Rotation.Pitch)) || (Vert(Rotation.Pitch) && Vert(Brother.Rotation.Pitch)) )
	{
		ExitRotation = Brother.Rotation;
		ExitRotation.Pitch = P.ViewRotation.Pitch;
		ExitRotation.Roll = 0;
		P.SetRotation(ExitRotation);
		P.ViewRotation = ExitRotation;
	}
}

Function RotateBot(Pawn P)
{
	if( Vert(Rotation.Pitch) && !Vert(Brother.Rotation.Pitch) )
	{
		ExitRotation.Yaw = P.ViewRotation.Yaw;
		ExitRotation.Pitch = P.ViewRotation.Pitch;
		ExitRotation.Roll = 0;
		P.SetRotation(ExitRotation);
		P.ViewRotation = ExitRotation;
	}
	else if( !Vert(Rotation.Pitch) && Vert(Brother.Rotation.Pitch) )
	{
		ExitRotation = Brother.Rotation;
		ExitRotation.Pitch = P.ViewRotation.Pitch;
		ExitRotation.Roll = 0;
		P.SetRotation(ExitRotation);
		P.ViewRotation = ExitRotation;
	}
	else if( Vert(Rotation.Pitch) && Vert(Brother.Rotation.Pitch) )
	{
		ExitRotation = Brother.Rotation;
		ExitRotation.Yaw -= Rotation.Yaw - P.ViewRotation.Yaw;
		ExitRotation.Roll = 0;
		ExitRotation = Rotator(-Vector(ExitRotation));
		ExitRotation.Pitch = P.ViewRotation.Pitch;
		P.SetRotation(ExitRotation);
		P.ViewRotation = ExitRotation;
	}
}

Function RotateGuider(GuidedWarshell G, PlayerPawn GDR)
{
	ExitRotation = Brother.Rotation;
	ExitRotation.Roll = 0;
	G.GuidedRotation = ExitRotation;
	GDR.ClientSetRotation(ExitRotation);
	GDR.ViewRotation = ExitRotation;
}

Function bool Vert(int Pitch)
{
	if(Pitch < 8192 && Pitch > -8192)
		return(true);
	else
		return(false);
}

/*##################################################################################################
##
## Default Properties
##
##################################################################################################*/
Defaultproperties
{
	AmbientGlow=255
	bUnlit=True
	DrawScale=2
	DrawType=DT_Mesh
	Mesh=LodMesh'portal'
	Style=STY_Translucent
	Skin=Texture'PortalBlue'
	AmbientSound=Sound'Portal_AmbientLoop'
	SoundRadius=32
	SoundVolume=255
	bCollideActors=True
	CollisionRadius=39.000000
	CollisionHeight=39.000000
	Physics=PHYS_Rotating
	bFixedRotationDir=True
	RotationRate=(Pitch=0,Yaw=0,Roll=-100000)
	RemoteRole=SimulatedProxy
	bMovable=True
	LightBrightness=255
	LightHue=152
	LightSaturation=32
	LightEffect=LE_Shock
	LightRadius=8
	LightType=LT_Steady
}