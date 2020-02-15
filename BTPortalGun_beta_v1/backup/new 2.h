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

Replication
{
	Unreliable if ( Role == ROLE_Authority )
		Brother, bTouched, PortalOwner;
}

/*##################################################################################################
##
## Spawn and Destroy Functions
##
##################################################################################################*/
Function PostBeginPlay()
{
	local PortalBlue Bro;

	Sparkz();

	if(Instigator != None)
	{
		PortalOwner = Instigator;

		foreach VisibleCollidingActors(class'PortalBlue', Bro, 78.0, Location)
		{
			if(Bro.PortalOwner == Self.PortalOwner && Bro != Self)
			{
				PortalOwner.PlayOwnedSound(sound'Portal_Fail', SLOT_None, 16.0);
				PortalOwner.Weapon.PlayAnim('Release', 1.0, 0.04);
				DeletePortal(false);
				return;
			}
		}

		foreach AllActors(class'PortalBlue', Bro)
		{
			if(Bro.PortalOwner == Self.PortalOwner && Bro != Self)
			{
				Brother = Bro;
				Bro.Brother = Self;
				Bro.PlaySound(sound'Portal_Connected', SLOT_Misc, 16.0);
			}
		}

		FireSoundz();
	}

	PlaySound(sound'Portal_Open', SLOT_Misc, 16.0);
}

Function FireSoundz()
{
	if( Self.IsA('PortalYellow') )
		PortalOwner.PlaySound(sound'PortalGun_Shoot_Yellow', SLOT_None, 16.0);
	else
		PortalOwner.PlaySound(sound'PortalGun_Shoot_Blue', SLOT_None, 16.0);
	PortalOwner.Weapon.PlayAnim('Fire', 1.0, 0.04);
}

Function DeletePortal(bool WithSparkz, optional bool WithSound)
{
	if(!bDestroyed)
	{
		bDestroyed = true;
		if(WithSparkz)
			Sparkz();
		if(WithSound)
			PlaySound(sound'Portal_Close', SLOT_Misc, 16.0);
		if(MoverName != None)
			MoverName = None;
		if(Brother != None)
			Brother.Brother = None;
		Brother = None;
		Destroy();
	}
}

function Destroyed()
{
	bDestroyed = true;
	Disable('Tick');
	MoverName = None;
	if(Brother != None)
		Brother.Brother = None;
	Brother = None;
}

Function Sparkz()
{
	local spark34 Sparkz34;
	local spark3 Sparkz3;

	if( Self.IsA('PortalYellow') )
	{
		Sparkz34 = Spawn(class'spark34',,, Location);
		Sparkz34.DrawScale = 2.0;
	}
	else
	{
		Sparkz3 = Spawn(class'spark3',,, Location);
		Sparkz3.DrawScale = 2.0;
	}
}

/*##################################################################################################
##
## Tick and Timer Stuff
##
##################################################################################################*/
Function Tick(float delta)
{
	local Rotator R;
	local Vector  V;

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
	{
		if(PortalOwner.FindInventoryType(class'BTPortalGun.PortalGun') == None)
		{
			PlaySound(sound'Portal_Close2', SLOT_Misc, 16.0);
			DeletePortal(true);
		}
	}
}

Function CheckMover()
{
	AttachVec = Location - MoverName.Location;
	AttachRot = Rotation - MoverName.Rotation;
	MoverBaseRot = MoverName.Rotation;
	MoverRollRot = MoverName.Rotation.Roll;
	bCheckedMover = !bCheckedMover;
}

Function Timer()
{
	if(bTouched)
		bTouched = !bTouched;
}

/*##################################################################################################
##
## Touch
##
##################################################################################################*/
Simulated Function Touch(Actor Other)
{
	if(!bTouched && Brother != None)
	{
		if( Other.IsA('PlayerPawn') )
		{
			bTouched = true;
			RotatePlayer(PlayerPawn(Other));
			PortPawn(Pawn(Other));
		}
		else if( Other.IsA('ScriptedPawn') || Other.IsA('NaliRabbit') || Other.IsA('Bird1'))
		{
			bTouched = true;
			RotateMonster(Pawn(Other));
			PortPawn(Pawn(Other));
		}
		else if( Other.IsA('Bot') )
		{
			bTouched = true;
			RotateBot(Pawn(Other));
			PortPawn(Pawn(Other));
		}
		else if( Other.IsA('Weapon') )
		{
			bTouched = true;
			PortWeapon(Weapon(Other));
		}
		else if( Other.IsA('Decoration') )
		{
			bTouched = true;
			PortDecoration(Decoration(Other));
		}
		else if( Other.IsA('Projectile') )
		{
			PortProjectile(Projectile(Other));
			PlayPortSoundz();
			Brother.bTouched = true;
			Brother.SetTimer(0.05, false);
		}
		if (bTouched)
		{
			SetTimer(0.05, false);
			Brother.bTouched = true;
			Brother.SetTimer(0.05, false);
			PlayPortSoundz();
		}
	}
}

Function PlayPortSoundz()
{
	PlaySound(sound'Portal_Enter', SLOT_Interact, 16.0);
	Brother.PlaySound(sound'Portal_Exit', SLOT_Pain, 16.0);
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
	P.SetPhysics(PHYS_None);
	P.SetLocation(Brother.Location);
	P.SetPhysics(PHYS_Falling);
	P.Velocity = Vsize(V) * Vector(Brother.Rotation);
}

Function PortWeapon(Weapon W)
{
	W.SetLocation(Brother.Location + Vector(Brother.Rotation) * 20 + vect(0,0,0) + Velocity * 0.01);
	W.Velocity = Vsize(W.Velocity * 1.015) * Vector(Brother.Rotation);
	W.RemoteRole = ROLE_SimulatedProxy;
}

Function PortDecoration(Decoration D)
{
	local Vector V;

	V = D.Velocity;
	D.SetPhysics(PHYS_None);
	D.SetLocation(Brother.Location);
	D.SetPhysics(PHYS_Falling);
	D.Velocity = (Vsize(V) * 1.015) * Vector(Brother.Rotation);
}

Simulated Function PortProjectile(Projectile P)
{
	local Projectile Proj;
	local Pawn GDR;

	if(Role == ROLE_Authority)
	{
		Proj = Spawn(P.Class,,, Brother.Location + Vector(Brother.Rotation) * 20 + vect(0,0,0), Brother.Rotation);
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
			RotateGuider(GuidedWarshell(Proj));
		}
	}

	else if( Proj.IsA('UT_Grenade') )
		UT_Grenade(Proj).bCanHitOwner = true;
	else if( Proj.IsA('Razor2') )
		Razor2(Proj).bCanHitInstigator = true;
	else if( Proj.IsA('Razor2Alt') )
		Razor2Alt(Proj).bCanHitInstigator = true;

	P.Destroy();
}

/*##################################################################################################
##
## Rotate Functions
##
##################################################################################################*/
Function RotateGuider(GuidedWarshell G)
{
	ExitRotation = Brother.Rotation;
	ExitRotation.Roll = 0;
	G.GuidedRotation = ExitRotation;
}

Function RotatePlayer(PlayerPawn PP)
{
	if( Vert(Rotation.Pitch) && !Vert(Brother.Rotation.Pitch) )
	{
		ExitRotation.Yaw = PP.ViewRotation.Yaw;
		ExitRotation.Pitch = PP.ViewRotation.Pitch;
		ExitRotation.Roll = 0;
		PP.ClientSetRotation(ExitRotation);
		PP.viewRotation = ExitRotation;
	}
	else if( !Vert(Rotation.Pitch) && Vert(Brother.Rotation.Pitch) )
	{
		ExitRotation = Brother.Rotation;
		ExitRotation.Pitch = PP.ViewRotation.Pitch;
		ExitRotation.Roll = 0;
		PP.ClientSetRotation(ExitRotation);
		PP.viewRotation = ExitRotation;
	}
	else if( Vert(Rotation.Pitch) && Vert(Brother.Rotation.Pitch) )
	{
		ExitRotation = Brother.Rotation;
		ExitRotation.Yaw -= Rotation.Yaw - PP.ViewRotation.Yaw;
		ExitRotation.Roll = 0;
		ExitRotation = Rotator(-Vector(ExitRotation));
		ExitRotation.Pitch = PP.ViewRotation.Pitch;
		PP.ClientSetRotation(ExitRotation);
		PP.viewRotation = ExitRotation;
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
	AmbientSound=sound'Portal_AmbientLoop'
	SoundRadius=32
	SoundVolume=255
	bCollideActors=True
	CollisionRadius=39.000000
	CollisionHeight=39.000000
	Physics=PHYS_Rotating
	bFixedRotationDir=True
	RotationRate=(Pitch=0,Yaw=0,Roll=-100000)
	RemoteRole=SimulatedProxy
	NetUpdateFrequency=100
	NetPriority=2.5
	bMovable=True
	LightBrightness=255
	LightHue=152
	LightSaturation=32
	LightEffect=LE_Shock
	LightRadius=8
	LightType=LT_Steady
}

/*
	LightBrightness=255
	LightHue=20
	LightSaturation=64
	LightEffect=LE_Shock
	LightRadius=8
	LightType=LT_Steady
*/