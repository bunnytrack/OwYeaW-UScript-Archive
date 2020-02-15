class PortalBlue extends pickup;

#exec MESH IMPORT MESH=portal ANIVFILE=MODELS\portal_a.3d DATAFILE=MODELS\portal_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=portal X=-8 Y=0 Z=0

#exec MESH SEQUENCE MESH=portal SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=portal SEQ=portal STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=portal MESH=portal
#exec MESHMAP SCALE MESHMAP=portal X=0.1 Y=0.1 Z=0.2

var() PortalBlue brother;
var bool btouched;
var rotator rot,comerot,enterrot;
var vector locate;
var() playerpawn lastplayer;

replication
{
	unreliable if ( Role == ROLE_Authority )
		brother, btouched,rot,locate,enterrot,comerot,lastplayer;
}

function postbeginplay()
{
	drawscale = 0;
	Playsound(sound'Portal_Open',SLOT_None,16.0);
}

auto state pickup
{
	function tick(float delta)
	{
		rot = rotation;
		rot.roll = 0;

		if(drawscale < default.drawscale)
			drawscale += 0.3;

		if(instigator.health <= 0)// || instigator == None)
			RemovePortal();

		locate = location;
	}

	simulated function Timer()
	{
		if(btouched == true)
			btouched = false;

		if(lastplayer != none)
		{
			lastplayer.desiredfov = lastplayer.defaultfov;
			lastplayer = none;
		}
	}

	function bump(actor Other)
	{
		if( brother != none && Other != none && !Other.isa('PortalBlue') && btouched == false && !Other.isa('pawn') && !Other.isa('brush') )
		{
			brother.btouched = true;
			brother.settimer(0.7,false);
			Other.setlocation(brother.locate+Vector(brother.rot)*20+vect(0,0,0)+Velocity*0.01);
			Other.setrotation(brother.rot);
			Other.velocity = vsize(Other.velocity) * vector(brother.rotation);
		}
	}

	simulated function Touch (Actor Other)
	{
		local rotator s;
		local vector v;
		local int yaw, pitch;

		//if ( ValidTouch(Other) )
		//{
			work(Other);
			settimer(0.01,false);
		//}
	}

	simulated function work(actor other)
	{
		local rotator s;
		local vector v;
		local int yaw;
		local int pitch;

		v = Other.velocity;
		if( btouched == false && brother != none && Other.isa('PlayerPawn') )
		{	
			Playsound(sound'Portal_Enter',SLOT_None,16.0);

			btouched = true;
			Yaw = rotation.yaw - pawn(Other).viewrotation.yaw;
			pitch = rotation.pitch - pawn(Other).viewrotation.pitch;
			Other.setphysics(phys_none);
			Other.setlocation(brother.locate);
			Other.setphysics(phys_falling);
			Other.velocity = (vsize(v) * 1.07) * vector(brother.rot);
			enterrot = brother.rotation;
			enterrot.yaw -= yaw;
			enterrot.pitch = pawn(Other).viewrotation.pitch;
			enterrot.roll = 0;
			enterrot = rotator(-vector(enterrot));
			pawn(Other).viewrotation = enterrot;
			pawn(Other).setrotation(enterrot);
			PlayerTurn(pawn(Other),enterrot);

			brother.Playsound(sound'Portal_Exit',SLOT_None,16.0);
		}
	}

	simulated function playerturn(pawn p, rotator rot)
	{
		p.setrotation(rot);
		p.viewrotation = rot;
	}
}

function RemovePortal()
{
	Playsound(sound'Portal_Close',SLOT_None,16.0);

	destroy();
}
	
function BecomePickup()
{}

function Becomeitem()
{}

defaultproperties
{
	CollisionRadius=39.000000
	CollisionHeight=39.000000
	Physics=PHYS_Rotating
	RotationRate=(Pitch=0,Yaw=0,Roll=-100000)
	DrawType=DT_Mesh
	Mesh=LodMesh'portal'
	bUnlit=True
	DrawScale=2
	Style=STY_Translucent	
	Skin=Texture'PortalBlue'
	AmbientSound=sound'Portal_AmbientLoop'
	SoundRadius=32
	SoundVolume=255
}


/*
	LightBrightness=255
	LightHue=20
	LightSaturation=64
	LightEffect=LE_Shock
	LightRadius=8
	LightType=LT_Steady
*/