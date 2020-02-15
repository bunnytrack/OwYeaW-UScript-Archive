//=============================================================================
// BT_CollisionData made by OwYeaW
//=============================================================================
class BT_CollisionData expands Actor;

#exec texture IMPORT NAME=BT_Kicker_SIDE 		FILE=BTE_Files\BT_CylinderTexture_Kicker_SIDE.BMP
#exec texture IMPORT NAME=BT_Kicker_TOP			FILE=BTE_Files\BT_CylinderTexture_Kicker_TOP.BMP

#exec texture IMPORT NAME=BT_Touch_SIDE			FILE=BTE_Files\BT_CylinderTexture_Touch_SIDE.BMP
#exec texture IMPORT NAME=BT_Touch_TOP			FILE=BTE_Files\BT_CylinderTexture_Touch_TOP.BMP

#exec texture IMPORT NAME=BT_Other_SIDE			FILE=BTE_Files\BT_CylinderTexture_Other_SIDE.BMP
#exec texture IMPORT NAME=BT_Other_TOP			FILE=BTE_Files\BT_CylinderTexture_Other_TOP.BMP

#exec texture IMPORT NAME=BT_Shoot_SIDE			FILE=BTE_Files\BT_CylinderTexture_Shoot_SIDE.BMP
#exec texture IMPORT NAME=BT_Shoot_TOP			FILE=BTE_Files\BT_CylinderTexture_Shoot_TOP.BMP

#exec texture IMPORT NAME=BT_Death_SIDE			FILE=BTE_Files\BT_CylinderTexture_Death_SIDE.BMP
#exec texture IMPORT NAME=BT_Death_TOP			FILE=BTE_Files\BT_CylinderTexture_Death_TOP.BMP

#exec texture IMPORT NAME=BT_Teleport_SIDE		FILE=BTE_Files\BT_CylinderTexture_Teleport_SIDE.BMP
#exec texture IMPORT NAME=BT_Teleport_TOP		FILE=BTE_Files\BT_CylinderTexture_Teleport_TOP.BMP

#exec texture IMPORT NAME=BT_Block_SIDE			FILE=BTE_Files\BT_CylinderTexture_Block_SIDE.BMP
#exec texture IMPORT NAME=BT_Block_TOP			FILE=BTE_Files\BT_CylinderTexture_Block_TOP.BMP

#exec texture IMPORT NAME=BT_Flag_SIDE			FILE=BTE_Files\BT_CylinderTexture_Flag_SIDE.BMP
#exec texture IMPORT NAME=BT_Flag_TOP			FILE=BTE_Files\BT_CylinderTexture_Flag_TOP.BMP

struct DataStruct
{
	var Vector		L;
	var int			H;
	var int			W;
	var	Texture		T1;
	var	Texture		T2;
	var Actor		AA;
	var Vector		AV;
};
var DataStruct DS[256];
var int ForEachCount;

Replication
{
	Reliable if(Role == ROLE_Authority)
		DS;
}

event Spawned()
{
	local int i;
	local Actor A;
	local Mover M;
	local AttachMover AM;

	Foreach AllActors(class'Actor', A)
	{
		ForEachCount++;
		if(i == 255)
		{
			Spawn(class'BT_CollisionData', Self);
			break;
		}
		if(Owner != None)
			if(ForEachCount <= BT_CollisionData(Owner).ForEachCount)
				continue;

		if(Trigger(A) != None && TimedTrigger(A) == None)
		{
			if(Trigger(A).TriggerType == TT_Shoot)
			{
				DS[i].T1 = Texture'BT_Shoot_TOP';
				DS[i].T2 = Texture'BT_Shoot_SIDE';
			}
			else if(Trigger(A).TriggerType == TT_PlayerProximity)
			{
				DS[i].T1 = Texture'BT_Touch_TOP';
				DS[i].T2 = Texture'BT_Touch_SIDE';
			}
			else
			{
				DS[i].T1 = Texture'BT_Other_TOP';
				DS[i].T2 = Texture'BT_Other_SIDE';
			}
		}
		else if(Kicker(A) != None)
		{
			DS[i].T1 = Texture'BT_Kicker_TOP';
			DS[i].T2 = Texture'BT_Kicker_SIDE';
		}
		else if(TriggeredDeath(A) != None)
		{
			DS[i].T1 = Texture'BT_Death_TOP';
			DS[i].T2 = Texture'BT_Death_SIDE';
		}
		else if(Teleporter(A) != None)
		{
			if(A.IsA('swJumpPad') && Teleporter(A).URL != "")
			{
				DS[i].T1 = Texture'BT_Kicker_TOP';
				DS[i].T2 = Texture'BT_Kicker_SIDE';
			}
			else
			{
				DS[i].T1 = Texture'BT_Teleport_TOP';
				DS[i].T2 = Texture'BT_Teleport_SIDE';
			}
		}
		else if(KeyPoint(A) != None && A.bBlockPlayers && A.bCollideActors)
		{
			DS[i].T1 = Texture'BT_Block_TOP';
			DS[i].T2 = Texture'BT_Block_SIDE';
		}
		else if(CTFFlag(A) != None)
		{
			DS[i].T1 = Texture'BT_Flag_TOP';
			DS[i].T2 = Texture'BT_Flag_SIDE';
		}
		else
			continue;

		if(A.AttachTag != '')
		{
			Foreach AllActors(class'Mover', M, A.AttachTag)
			{
				DS[i].AA = M;
				break;
			}
			if(DS[i].AA != None)
				DS[i].AV = A.Location - DS[i].AA.Location;
		}
		else if(A.Tag != '')
		{
			Foreach AllActors(class'AttachMover', AM)
			{
				if(AM.AttachTag == A.Tag)
				{
					DS[i].AA = AM;
					break;
				}
			}
			if(DS[i].AA != None)
				DS[i].AV = A.Location - DS[i].AA.Location;
		}
		DS[i].L = A.Location;
		DS[i].H = A.CollisionHeight;
		DS[i].W = A.CollisionRadius;
		i++;
	}
}

simulated function DrawCollisionActors(PlayerPawn PP)
{
	local int i;
	local BT_CollisionActor CA;

	for(i = 0; i < ArrayCount(DS); i++)
	{
		if(DS[i].T1 != None)
		{
			CA						= Spawn(class'BT_CollisionActor', , , DS[i].L);
			CA.LocalPlayer			= PP;
			CA.CentralLoc			= DS[i].L;
			CA.Skin					= DS[i].T1;
			CA.MultiSkins[0]		= DS[i].T2;
			if(DS[i].AA != None)
			{
				CA.AttachActor		= DS[i].AA;
				CA.AttachVec		= DS[i].AV;
			}
			CA.Initialize(DS[i].W, DS[i].H);
		}
		else
			break;
	}
}
//=============================================================================
// Default Properties
//=============================================================================
defaultproperties
{
	DrawType=DT_None
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=9.000000
}