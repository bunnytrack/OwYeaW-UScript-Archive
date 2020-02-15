//=============================================================================
// AttachMover.
//=============================================================================
class AntiPortalAttachMover extends Mover;

// This is just a renamed AttachMover

var() name AttachTag;

// Immediately after mover enters gameplay.
function PostBeginPlay()
{
	local Actor Act;
	local Mover Mov;

	Super.PostBeginPlay();

	// Initialize all slaves.
	if ( AttachTag != '' )
		foreach AllActors( class 'Actor', Act, AttachTag )
		{
			Mov = Mover(Act);
			if (Mov == None) {

				Act.SetBase( Self );
			}
			else if (Mov.bSlave) {
			
				Mov.GotoState('');
				Mov.SetBase( Self );
			}
		}
}