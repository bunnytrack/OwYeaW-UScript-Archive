//==================================================================
// FWS_Handler made by OwYeaW
//==================================================================
class FWS_Handler extends Actor;

var float WeaponSwitchSpeed;
var Weapon LastDown, LastSelect;

replication
{
	reliable if(Role == ROLE_Authority)
		WeaponSwitchSpeed;
}

simulated function Tick(float delta)
{
    local Pawn P;
    local Weapon W;

    P = Pawn(Owner);
	if(P != None)
	{
		if(P.Weapon != None)
		{
			W = P.Weapon;
			if(W.AnimSequence == 'Down' && LastDown != W)
			{
				W.PlayAnim(W.AnimSequence, WeaponSwitchSpeed);
				LastDown = W;
			}
			else if(W.AnimSequence == 'Select' && LastSelect != W)
			{
				W.PlayAnim(W.AnimSequence, WeaponSwitchSpeed);
				LastSelect = W;
			}
		}
    }
	else
		Destroy();
}

defaultproperties
{
	bHidden=True
	NetUpdateFrequency=4.000000
    bNetTemporary=True
}