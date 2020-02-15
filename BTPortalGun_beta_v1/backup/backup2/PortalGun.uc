class PortalGun extends TournamentWeapon;

#exec MESH IMPORT MESH=port ANIVFILE=MODELS\port_a.3d DATAFILE=MODELS\port_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=port X=0 Y=0 Z=0 

#exec MESH SEQUENCE MESH=port SEQ=All  STARTFRAME=0 NUMFRAMES=7
#exec MESH SEQUENCE MESH=port SEQ=fire STARTFRAME=0 NUMFRAMES=2 rate=1
#exec MESH SEQUENCE MESH=port SEQ=select STARTFRAME=4 NUMFRAMES=4 rate=4
#exec MESH SEQUENCE MESH=port SEQ=down STARTFRAME=1 NUMFRAMES=2 rate=1

#exec MESHMAP NEW   MESHMAP=port MESH=port
#exec MESHMAP SCALE MESHMAP=port X=0.1 Y=0.1 Z=0.2

#exec audio import file=Sounds\Portal_AmbientLoop.wav
#exec audio import file=Sounds\Portal_Open.wav
#exec audio import file=Sounds\Portal_Close.wav
#exec audio import file=Sounds\Portal_Enter.wav
#exec audio import file=Sounds\Portal_Exit.wav
#exec audio import file=Sounds\PortalGun_Shoot_Blue.wav
#exec audio import file=Sounds\PortalGun_Shoot_Yellow.wav

#exec TEXTURE IMPORT FILE=Textures\Black.pcx
#exec TEXTURE IMPORT FILE=Textures\gray.pcx

#exec texture import file=Textures\PortalBlue.pcx	FLAGS=2
#exec texture import file=Textures\PortalYellow.pcx	FLAGS=2

var PortalBlue cc,cc2;
var rotator roty, oldrot, olrot;
var float SwayLastTime;

replication
{
	reliable if ( Role <= ROLE_Authority )
		cc, cc2,roty;
}

simulated function PostBeginPlay()
{
	settimer(0.3,false);
	Super.PostBeginPlay();
}

simulated event RenderOverlays(Canvas C)
{
	local float DT;
	local rotator zerorot,newrot;
	local bool bPlayerOwner;
	local int Hand;
	local PlayerPawn PlayerOwner;

	if ( bHideWeapon || (Owner == None) )
		return;

	PlayerOwner = PlayerPawn(Owner);

	if ( PlayerOwner != None )
	{
		if ( PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV )
			return;
		bPlayerOwner = true;
		Hand = PlayerOwner.Handedness;

		if (  (Level.NetMode == NM_Client) && (Hand == 2) )
		{
			bHideWeapon = true;
			return;
		}
	}

	if ( !bPlayerOwner || (PlayerOwner.Player == None) )
		Pawn(Owner).WalkBob = vect(0,0,0);

	if ( (bMuzzleFlash > 0) && bDrawMuzzleFlash && Level.bHighDetailMode && (MFTexture != None) )
	{
		MuzzleScale = Default.MuzzleScale * c.ClipX/640.0;
		if ( !bSetFlashTime )
		{
			bSetFlashTime = true;
			FlashTime = Level.TimeSeconds + FlashLength;
		}
		else if ( FlashTime < Level.TimeSeconds )
			bMuzzleFlash = 0;
		if ( bMuzzleFlash > 0 )
		{
			if ( Hand == 0 )
				c.SetPos(c.ClipX/2 - 0.5 * MuzzleScale * FlashS + c.ClipX * (-0.2 * Default.FireOffset.Y * FlashO), c.ClipY/2 - 0.5 * MuzzleScale * FlashS + c.ClipY * (FlashY + FlashC));
			else
				c.SetPos(c.ClipX/2 - 0.5 * MuzzleScale * FlashS + c.ClipX * (Hand * Default.FireOffset.Y * FlashO), c.ClipY/2 - 0.5 * MuzzleScale * FlashS + c.ClipY * FlashY);

			c.Style = 3;
			c.DrawIcon(MFTexture, MuzzleScale);
			c.Style = 1;
		}
	}
	else
		bSetFlashTime = false;

	SetLocation( Owner.Location + CalcDrawOffset() );

	if ( Hand == 0 )
		newRot.Roll = -2 * Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll * Hand;

	C.DrawActor(self, false);

	newrot = oldrot;
	setrotation(newrot);
	DT = Level.TimeSeconds - SwayLastTime;
	swayLastTime = Level.TimeSeconds;
	oldrot = pawn(owner).viewrotation;
}

function fire(float value)
{
	bPointing = True;
	bCanClientFire = true;
	ClientFire(value);
	//Pawn(Owner).PlayRecoil(FiringSpeed);

	if(owner.isa('playerpawn'))
		tracefire(0);
}

function altfire(float value)
{
	bPointing = True;
	bCanClientFire = true;
	ClientaltFire(value);
	//Pawn(Owner).PlayRecoil(FiringSpeed);

	if(owner.isa('playerpawn'))
		tracefire2(0);
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z; 
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000 + Accuracy * (FRand() - 0.5 ) * Z * 1000;

	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
	EndTrace += (10000 * vector(AdjustedAim));

	Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
}

function TraceFire2( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z; 
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000 + Accuracy * (FRand() - 0.5 ) * Z * 1000;

	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
	EndTrace += (10000 * vector(AdjustedAim));

	Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit2(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
}

simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local UT_Shellcase s;
	local vector realLoc;
	local spark3 s1;

	if(other == level)
	{
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		s1 = spawn(class'spark3',,,hitlocation);
		s1.drawscale = 2.0;

		if ( PlayerPawn(Owner) != None )
		{
			PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(650, 450, 190));
			if ( PlayerPawn(Owner).DesiredFOV == PlayerPawn(Owner).DefaultFOV )
				bMuzzleFlash++;
		}

		if(cc != none)
		{
			s1 = spawn(class'spark3',,,cc.location);
			s1.drawscale = 2.0;
			cc.destroy();
			cc = none;
		}

		cc = Spawn(class'PortalBlue',,, HitLocation + HitNormal, Rotator(HitNormal));
		cc.setrotation(rotator(hitnormal));
		if(cc2 != none)
		{
			cc.brother = cc2;
			cc2.brother = cc;
		}
	}
}

simulated function ProcessTraceHit2(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local UT_Shellcase s;
	local vector realLoc;
	local spark34 s2;

	if(other == level)
	{
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		s2 = spawn(class'spark34',,,hitlocation);
		s2.drawscale=2.0;
		if ( PlayerPawn(Owner) != None )
		{
			PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(650, 450, 190));
			if ( PlayerPawn(Owner).DesiredFOV == PlayerPawn(Owner).DefaultFOV )
				bMuzzleFlash++;
		}

		if(cc2 != none)
		{
			s2 = spawn(class'spark34',,,cc2.location);
			s2.drawscale = 2.0;
			cc2.destroy();
			cc2 = none;
		}

		if(!other.isa('PortalBlue'))
		{
			cc2 = Spawn(class'PortalYellow',,, HitLocation + HitNormal, Rotator(HitNormal));
			cc2.setrotation(rotator(hitnormal));
		}

		if(cc != none)
		{
			cc.brother = cc2;
			cc2.brother = cc;
		}
	}
}

simulated function PlayFiring()
{
	if(owner.isa('playerpawn'))
		PlayOwnedSound(FireSound, SLOT_None, 16.0);
	PlayAnim('fire',0.9,0.1);
}

simulated function PlayAltFiring()
{
	if(owner.isa('playerpawn'))
		PlayOwnedSound(altFireSound, SLOT_None, 16.0);
	PlayAnim('fire',0.9,0.1);
}

defaultproperties
{
	ItemName="Portal Gun"
	StatusIcon=Texture'Botpack.Icons.UseTrans'
	Icon=Texture'Botpack.Icons.UseTrans'
	Skin=Texture'BTPortalGun.Black'
	Mesh=LodMesh'BTPortalGun.port'
	PlayerViewMesh=LodMesh'BTPortalGun.port'
	PlayerViewOffset=(X=1.500000,Y=-2.000000,Z=-1.000000)
	PlayerViewScale=0.16
	ThirdPersonMesh=LodMesh'BTPortalGun.port'
	PickupViewMesh=LodMesh'BTPortalGun.port'
	PickupMessage="You got the Portal Gun"
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	FireSound=sound'PortalGun_Shoot_Blue'
	AltFireSound=sound'PortalGun_Shoot_Yellow'
}