//=============================================================================
// Trigger: senses things happening in its proximity and generates 
// sends Trigger/UnTrigger to actors whose names match 'EventName'.
//=============================================================================
class ItemTrigger extends Triggers;

//-----------------------------------------------------------------------------
// Trigger variables.

// Trigger type.
var() enum ETriggerType
{
	TT_PlayerProximity,	// Trigger is activated by player proximity.
	TT_Shoot,		    // Trigger is activated by player shooting it.
} TriggerType;

// Human readable triggering message.
var() localized string Message;

// Only trigger once and then go dormant.
var() bool bTriggerOnceOnly;

// For triggers that are activated/deactivated by other triggers.
var() bool bInitiallyActive;

var() float	RepeatTriggerTime; //if > 0, repeat trigger message at this interval is still touching other
var() float ReTriggerDelay; //minimum time before trigger can be triggered again
var	  float TriggerTime;
var() float DamageThreshold; //minimum damage to trigger if TT_Shoot

var() string ItemName;

// AI vars
var	actor TriggerActor;	// actor that triggers this trigger
var actor TriggerActor2;

//=============================================================================
// AI related functions

function PostBeginPlay()
{
	if ( !bInitiallyActive )
		FindTriggerActor();
	if ( TriggerType == TT_Shoot )
	{
		bHidden = false;
		bProjTarget = true;
		DrawType = DT_None;
	}

	Super.PostBeginPlay();
}

function FindTriggerActor()
{
	local Actor A;

	TriggerActor = None;
	TriggerActor2 = None;
	ForEach AllActors(class 'Actor', A)
		if ( A.Event == Tag)
		{
			if ( Counter(A) != None )
				return; //FIXME - handle counters
			if (TriggerActor == None)
				TriggerActor = A;
			else
			{
				TriggerActor2 = A;
				return;
			}
		}
}

function Actor SpecialHandling(Pawn Other)
{
	local int i;

	if ( bTriggerOnceOnly && !bCollideActors )
		return None;

	if ( (TriggerType == TT_PlayerProximity) && !Other.bIsPlayer )
		return None;

	if ( !bInitiallyActive )
	{
		if ( TriggerActor == None )
			FindTriggerActor();
		if ( TriggerActor == None )
			return None;
		if ( (TriggerActor2 != None) 
			&& (VSize(TriggerActor2.Location - Other.Location) < VSize(TriggerActor.Location - Other.Location)) )
			return TriggerActor2;
		else
			return TriggerActor;
	}

	// is this a shootable trigger?
	if ( TriggerType == TT_Shoot )
	{
		if ( !Other.bCanDoSpecial || (Other.Weapon == None) )
			return None;

		Other.Target = self;
		Other.bShootSpecial = true;
		Other.FireWeapon();
		Other.bFire = 0;
		Other.bAltFire = 0;
		return Other;
	}

	// can other trigger it right away?
	if ( IsRelevant(Other) )
	{
		for (i=0;i<4;i++)
			if (Touching[i] == Other)
				Touch(Other);
		return self;
	}

	return self;
}

// when trigger gets turned on, check its touch list
function CheckTouchList()
{
	local int i;

	for (i=0;i<4;i++)
		if ( Touching[i] != None )
			Touch(Touching[i]);
}

//=============================================================================
// Trigger logic.

//
// See whether the other actor is relevant to this trigger.
//
function bool IsRelevant( actor Other )
{
	if( !bInitiallyActive )
		return false;
	switch( TriggerType )
	{
		case TT_PlayerProximity:
			return Pawn(Other)!=None && Pawn(Other).bIsPlayer;
		case TT_Shoot:
			return ( (Projectile(Other) != None) && (Projectile(Other).Damage >= DamageThreshold) );
	}
}
//
// Called when something touches the trigger.
//
function Touch( actor Other )
{
	local actor A;

	if( IsRelevant( Other ) )
	{
		if ( ReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
				return;
			TriggerTime = Level.TimeSeconds;
		}
		// Broadcast the Trigger message to all matching actors.
		if( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				A.Trigger( Other, Other.Instigator );

		if ( Other.IsA('Pawn') && (Pawn(Other).SpecialGoal == self) )
			Pawn(Other).SpecialGoal = None;

		if( Message != "" )
			// Send a string message to the toucher.
			Other.Instigator.ClientMessage( Message );

		if( bTriggerOnceOnly )
			// Ignore future touches.
			SetCollision(False);
		else if ( RepeatTriggerTime > 0 )
			SetTimer(RepeatTriggerTime, false);

		//	ITEM TRIGGER STUFF	<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		//	FOR SPAM REASONS IVE SET ReTriggerDelay=0.01 AS DEFAULT
		if(Other.IsA('Pawn') && Pawn(Other).bIsPlayer)
			GiveItemTo(Pawn(Other));
	}
}

function Timer()
{
	local bool bKeepTiming;
	local int i;

	bKeepTiming = false;

	for (i=0;i<4;i++)
		if ( (Touching[i] != None) && IsRelevant(Touching[i]) )
		{
			bKeepTiming = true;
			Touch(Touching[i]);
		}

	if ( bKeepTiming )
		SetTimer(RepeatTriggerTime, false);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	local actor A;

	if ( bInitiallyActive && (TriggerType == TT_Shoot) && (Damage >= DamageThreshold) && (instigatedBy != None) )
	{
		if ( ReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
				return;
			TriggerTime = Level.TimeSeconds;
		}
		// Broadcast the Trigger message to all matching actors.
		if( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				A.Trigger( instigatedBy, instigatedBy );

		if( Message != "" )
			// Send a string message to the toucher.
			instigatedBy.Instigator.ClientMessage( Message );

		if( bTriggerOnceOnly )
			// Ignore future touches.
			SetCollision(False);

		//	ITEM TRIGGER STUFF	<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		if(instigatedBy.bIsPlayer)
			GiveItemTo(instigatedBy);
	}
}

//
// When something untouches the trigger.
//
function UnTouch( actor Other )
{
	local actor A;
	if( IsRelevant( Other ) )
	{
		// Untrigger all matching actors.
		if( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				A.UnTrigger( Other, Other.Instigator );
	}
}

//	ITEM TRIGGER STUFF	<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
//	Supported Items are either subclasses from 'Weapon', 'Ammo' or 'Pickup'
//	Unsupported Items should still be a subclass from 'Inventory', these will be spawned and go via <if(!bSupportedItem)> at the end of this function
//	FOR SPAM REASONS IVE SET ReTriggerDelay=0.01 AS DEFAULT
function GiveItemTo(Pawn P)
{
	local int OldAmmo;
	local int HealMax;
	local bool bSupportedItem;
	local Inventory hasInv;
	local Inventory newInv;
	local Class<Inventory> InvClass;

	if(P.bIsPlayer)
	{
		InvClass = Class<Inventory>(DynamicLoadObject(ItemName, Class'Class',true));
		hasInv = P.FindInventoryType(InvClass);
		newInv = Spawn(InvClass, P,, P.Location);

		//	WEAPON
		if(ClassIsChildOf(InvClass, class'Weapon'))
		{
			bSupportedItem = true;
			if(hasInv == None)
			{
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogPickup(newInv, P);
				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogPickup(newInv, P);
				if (newInv.PickupMessageClass == None)
					P.ClientMessage(newInv.PickupMessage, 'Pickup');
				else
					P.ReceiveLocalizedMessage( newInv.PickupMessageClass, 0, None, None, newInv.Class );

				newInv.GiveTo(P);
				newInv.PlaySound(newInv.PickupSound);
				Weapon(newInv).AmmoType = Ammo(P.FindInventoryType(Weapon(newInv).AmmoName));
				if(Weapon(newInv).AmmoType == None)
				{
					Weapon(newInv).AmmoType = Spawn(Weapon(newInv).AmmoName, P,, P.Location);
					P.AddInventory(Weapon(newInv).AmmoType);
					Weapon(newInv).AmmoType.BecomeItem();
					Weapon(newInv).AmmoType.AmmoAmount = 0; 
					Weapon(newInv).AmmoType.GotoState('Idle2');
				}
				Weapon(newInv).SetSwitchPriority(P);
				Weapon(newInv).Instigator = P;
				Weapon(newInv).AmbientGlow = 0;

				if (Weapon(newInv).AmmoType != None)
				{
					OldAmmo = Weapon(newInv).AmmoType.AmmoAmount;
					if ( Weapon(newInv).AmmoType.AddAmmo(Weapon(newInv).PickupAmmoCount) && (OldAmmo == 0) && (P.Weapon.class != newInv.class) && !P.bNeverSwitchOnPickup)
							Weapon(newInv).WeaponSet(P);
				}
			}
			else
				newInv.Destroy();
		}
		//	AMMO
		else if(ClassIsChildOf(InvClass, class'Ammo'))
		{
			bSupportedItem = true;
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(newInv, P);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(newInv, P);
			if (newInv.PickupMessageClass == None)
				P.ClientMessage( newInv.PickupMessage, 'Pickup' );
			else
				P.ReceiveLocalizedMessage( newInv.PickupMessageClass, 0, None, None, newInv.Class );

			if(hasInv != None)
			{
				if(Ammo(hasInv).AmmoAmount != Ammo(hasInv).MaxAmmo)
				{
					Ammo(hasInv).AddAmmo(Ammo(newInv).AmmoAmount);
					newInv.PlaySound(newInv.PickupSound);
				}
				newInv.Destroy();
			}
			else
			{
				newInv.PlaySound(newInv.PickupSound);
				newInv.GiveTo(P);
			}
		}
		//	PICKUP ITEMS
		else if(ClassIsChildOf(InvClass, class'Pickup'))
		{
			bSupportedItem = true;
			//	HEALTH ITEMS
			if(ClassIsChildOf(InvClass, class'TournamentHealth'))
			{
				HealMax = P.default.health;
				if (TournamentHealth(newInv).bSuperHeal)
					HealMax = Min(199, HealMax * 2.0);
				if (P.Health < HealMax) 
				{
					if (Level.Game.LocalLog != None)
						Level.Game.LocalLog.LogPickup(newInv, P);
					if (Level.Game.WorldLog != None)
						Level.Game.WorldLog.LogPickup(newInv, P);

					P.Health += TournamentHealth(newInv).HealingAmount;
					if (P.Health > HealMax)
						P.Health = HealMax;

					TournamentHealth(newInv).PlayPickupMessage(P);
					newInv.PlaySound(TournamentHealth(newInv).PickupSound,,2.5);
					P.MakeNoise(0.2);
				}
				newInv.Destroy();
			}
			//	OTHER ITEMS -> BOOTS, UDAMAGE, FLASHLIGHTS
			else
			{
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogPickup(newInv, P);
				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogPickup(newInv, P);
				if ( newInv.PickupMessageClass == None )
					P.ClientMessage(newInv.PickupMessage, 'Pickup');
				else
					P.ReceiveLocalizedMessage( newInv.PickupMessageClass, 0, None, None, newInv.Class );

				if(hasInv == None)
				{
					newInv.GiveTo(P);
					newInv.PlaySound(newInv.PickupSound,,2.0);
					Pickup(newInv).PickupFunction(P);
					if (Pickup(newInv).bActivatable && P.SelectedItem == None) 
						P.SelectedItem = newInv;
					if (Pickup(newInv).bActivatable && Pickup(newInv).bAutoActivate && P.bAutoActivate)
						newInv.Activate();
				}
				else if (Pickup(hasInv).bCanHaveMultipleCopies) 
				{
					Pickup(hasInv).NumCopies++;
					newInv.PlaySound(newInv.PickupSound,,2.0);
					newInv.Destroy();
				}
				else if (Pickup(hasInv).bDisplayableInv) 
				{
					if (hasInv.Charge < newInv.Charge)
						hasInv.Charge = newInv.Charge;
					newInv.PlaySound(newInv.PickupSound,,2.0);
					newInv.Destroy();
				}
			}
		}
		if(!bSupportedItem)
		{
			if(newInv != None)
			{
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogPickup(newInv, P);
				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogPickup(newInv, P);
				if ( newInv.PickupMessageClass == None )
					P.ClientMessage(newInv.PickupMessage, 'Pickup');
				else
					P.ReceiveLocalizedMessage( newInv.PickupMessageClass, 0, None, None, newInv.Class );

				newInv.GiveTo(P);
				newInv.PlaySound(newInv.PickupSound,,2.0);
				newInv.Destroy();
			}
		}
	}
}
//	FOR SPAM REASONS IVE SET ReTriggerDelay=0.01 AS DEFAULT
defaultproperties
{
	ReTriggerDelay=0.01
	bEdShouldSnap=True
	bInitiallyActive=True
	Texture=Texture'Engine.S_Trigger'
}