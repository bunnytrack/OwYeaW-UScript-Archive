//=============================================================================
// FurryMover.
// Go to next state by different triggers. Optionally, an event can be triggered
// when next state has been reached.
// When opening stage is complete, mover will return to key 0. Or, if player
// failed to complete the sequence in either OpenTime, it will return aswell.
//
// Note:
// A future trigger cannot immediately activate Key 2 of the mover, it has
// to do its full sequence.
//
// Made by -=(FBT)=-furry <3
// If you use this, lemme know :P
//
// DO NOT USE THIS CODE TO CREATE YOUR OWN MOVER. BORROWING IDEAS IS FINE,
// BUT DON'T CREDIT YOURSELF WITH IT!
//=============================================================================
class AntiPortalFurryMover4 expands Mover;

// This is just a renamed FurryMover4

var(FurryMover) float OpenTimes[20];	// The time the player has to active next trigger for next key
var(FurryMover) bool  bImmediateReturn;	// Immediately return to key 0 (true) or return 

var(FurryMover) float FailWaitTime;		// time to wait on failure
var(FurryMover) float ReturnTime;		// time it takes the mover to return to key 0
var(FurryMover) float FinalOpenTime;	// time before mover returns on last key
var(FurryMover) float MoveTimes[20];	// move time to next key
var(FurryMover) name Tags[20];			// each tag it should respond to
var(FurryMover) name Events[20];		// each event it should trigger
var(FurryMover) name FailEvents[20];	// each event it should trigger
var(FurryMover) name AttachTags[20];	// attach tags to this mover
var(FurryMover) bool bAutomate;			// moves the mover automagically to the next key
var(FurryMover) bool bLoop;				// loop from last key to the first key

var int  LastKeyNum;
var bool bIsFullyOpen;
var int	 PreviousKey;
var bool hasFailed;						// true if player has failed. For future use
var actor A;

function PostBeginPlay()
{
	local Actor Act;
	local Mover Mov;
	local int i;

	Super.PostBeginPlay();

	// Initialize all slaves.
	for (i=0; i<20; i++)
	{
		if (AttachTags[i] != '')
		{
			foreach AllActors( class 'Actor', Act, AttachTags[i])
			{
				Mov = Mover(Act);
				if (Mov == None)
				{
					Act.SetBase( Self );
				}
				else if (Mov.bSlave)
				{
					Mov.GotoState('');
					Mov.SetBase( Self );
				}
			}
		}
	}
}

function BeginPlay()
{
	Tag   = Tags[0];
	Event = Events[0];
	MoveTime = MoveTimes[0];
	KeyNum = 0;
	bIsFullyOpen = false;
	Super.BeginPlay();
	hasFailed = false;
}

function DoOpen() 
{
	bOpening = true;
	bDelaying = false;
	LastKeyNum = KeyNum;
	InterpolateTo (KeyNum+1, MoveTimes[Keynum]);
	PlaySound (OpeningSound);
	AmbientSound = MoveAmbientSound;
}

// Close the mover.
function DoClose()
{
	bOpening = false;
	bDelaying = false;
	if (bImmediateReturn && KeyNum == 0)
		InterpolateTo( Max(0,KeyNum-1), ReturnTime );
	else
		InterpolateTo( Max(0,KeyNum-1), MoveTimes[Max(0,KeyNum-1)] );
	PlaySound( ClosingSound, SLOT_None );
	AmbientSound = MoveAmbientSound;
}

state() FurryTriggerControl
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (!hasFailed)
		{
			PreviousKey = KeyNum;
			SavedTrigger = Other;
			Instigator = EventInstigator;
			if ( SavedTrigger != None )
				SavedTrigger.BeginEvent();
			GotoState( 'FurryTriggerControl', 'Open' );
		}
	}

	function InterpolateEnd(actor Other) {}

	function BeginState()
	{
		bOpening = false;
	}

Open:
	Disable ('Trigger');
	DoOpen();
	FinishInterpolation();
	FinishedOpening();

	// Check if this is the fully opened position,
	// for which a delay is necessary.
	if (KeyNum == NumKeys-1) // Note: NumKeys=0 means one key frame
	{
		AmbientSound = None;
		if( bTriggerOnceOnly ) // Stays in this position forever
			GotoState ('');
		else
			GotoState ('FurryTriggerControl', 'Close');
	}
	
	if (Tags[KeyNum] == Tags[LastKeyNum])
		GotoState ('FurryTriggerControl', 'Open');

	Tag   = Tags[KeyNum];		// Change the next open conditions
	Event = Events[KeyNum];
	MoveTime = MoveTimes[KeyNum];
	Enable ('Trigger');

	Sleep(OpenTimes[KeyNum]);

	// Player has failed!
	if (bAutomate)
	{
		hasFailed = false;
		Trigger(SavedTrigger, Instigator);
	}
	else if (PreviousKey+1 == KeyNum )
	{
		hasFailed = true;

		// Check if we have a FailEvent in this key
		if ( FailEvents[KeyNum-1] != '' && !bAutomate)
		{
			foreach AllActors( class 'Actor', A, FailEvents[KeyNum-1] )
				A.Trigger( SavedTrigger, Instigator );
			// Wait a bit before we return on failure (allows player to stay in place while some events occur)
			Sleep(FailWaitTime);
		}
		GotoState ('FurryTriggerControl', 'ImmediateClose');
	}

	Stop;

Close:
	// Player has successfully reached the last key
	Sleep(FinalOpenTime);

ImmediateClose:
	Event = '';
	if (bImmediateReturn == true)
		KeyNum = 0;
	Disable ('Trigger');
	DoClose();
	FinishInterpolation();
	FinishedClosing();

	if (KeyNum > 0 && bImmediateReturn == false)
	{
		Sleep(OpenTimes[KeyNum]);
		GotoState ('FurryTriggerControl', 'ImmediateClose');
	}

	hasFailed = false;
	Tag   = Tags[0];
	Event = Events[0];
	PreviousKey = 0;
	AmbientSound = None;
	Enable ('Trigger');
	if (bLoop && KeyNum == 0)
	{
		Trigger(SavedTrigger, Instigator);
	}
}