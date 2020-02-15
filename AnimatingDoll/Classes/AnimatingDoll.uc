//=============================================================================
// AnimatingDoll made by OwYeaW
//=============================================================================
class AnimatingDoll extends Decoration;

var enum EAnimType
{
	All,
	BackRun,
	Breath1,
	Breath1L,
	Breath2,
	Breath2L,
	Chat1,
	Chat2,
	CockGun,
	CockGunL,
	Death1,
	Death11,
	Death2,
	Death3,
	Death4,
	Death7,
	Death8,
	Death9,
	Death9B,
	DuckWlkL,
	DuckWlkS,
	Flip,
	Look,
	LookL,
	RunLg,
	RunLgFr,
	RunSm,
	RunSmFr,
	StillFrRp,
	StillLgFr,
	StillSmFr,
	StrafeL,
	StrafeR,
	SwimLg,
	SwimSm,
	Taunt1,
	Thrust,
	TreadLg,
	TreadSm,
	Victory1,
	Walk,
	WalkLg,
	WalkLgFr,
	WalkSm,
	WalkSmFr,
	Wave,
	WaveL
} AnimType;

var() EAnimType AnimationType;
var() float AnimationSpeed;

function PostBeginPlay()
{
	if(AnimationType == All)
		LoopAnim('All', AnimationSpeed);
	else if(AnimationType == Taunt1)
		LoopAnim('Taunt1', AnimationSpeed);
	else if(AnimationType == Breath1)
		LoopAnim('Breath1', AnimationSpeed);
	else if(AnimationType == Breath2)
		LoopAnim('Breath2', AnimationSpeed);
	else if(AnimationType == CockGun)
		LoopAnim('CockGun', AnimationSpeed);
	else if(AnimationType == CockGunL)
		LoopAnim('CockGunL', AnimationSpeed);
	else if(AnimationType == DuckWlkL)
		LoopAnim('DuckWlkL', AnimationSpeed);
	else if(AnimationType == DuckWlkS)
		LoopAnim('DuckWlkS', AnimationSpeed);
	else if(AnimationType == Look)
		LoopAnim('Look', AnimationSpeed);
	else if(AnimationType == LookL)
		LoopAnim('LookL', AnimationSpeed);
	else if(AnimationType == RunLg)
		LoopAnim('RunLg', AnimationSpeed);
	else if(AnimationType == RunLgFr)
		LoopAnim('RunLgFr', AnimationSpeed);
	else if(AnimationType == RunSm)
		LoopAnim('RunSm', AnimationSpeed);
	else if(AnimationType == RunSmFr)
		LoopAnim('RunSmFr', AnimationSpeed);
	else if(AnimationType == StillFrRp)
		LoopAnim('StillFrRp', AnimationSpeed);
	else if(AnimationType == StillLgFr)
		LoopAnim('StillLgFr', AnimationSpeed);
	else if(AnimationType == StillSmFr)
		LoopAnim('StillSmFr', AnimationSpeed);
	else if(AnimationType == SwimLg)
		LoopAnim('SwimLg', AnimationSpeed);
	else if(AnimationType == SwimSm)
		LoopAnim('SwimSm', AnimationSpeed);
	else if(AnimationType == TreadLg)
		LoopAnim('TreadLg', AnimationSpeed);
	else if(AnimationType == TreadSm)
		LoopAnim('TreadSm', AnimationSpeed);
	else if(AnimationType == Victory1)
		LoopAnim('Victory1', AnimationSpeed);
	else if(AnimationType == WalkLg)
		LoopAnim('WalkLg', AnimationSpeed);
	else if(AnimationType == WalkLgFr)
		LoopAnim('WalkLgFr', AnimationSpeed);
	else if(AnimationType == WalkSm)
		LoopAnim('WalkSm', AnimationSpeed);
	else if(AnimationType == WalkSmFr)
		LoopAnim('WalkSmFr', AnimationSpeed);
	else if(AnimationType == Wave)
		LoopAnim('Wave', AnimationSpeed);
	else if(AnimationType == WaveL)
		LoopAnim('WaveL', AnimationSpeed);
	else if(AnimationType == Walk)
		LoopAnim('Walk', AnimationSpeed);
	else if(AnimationType == Breath1L)
		LoopAnim('Breath1L', AnimationSpeed);
	else if(AnimationType == Breath2L)
		LoopAnim('Breath2L', AnimationSpeed);
	else if(AnimationType == Chat1)
		LoopAnim('Chat1', AnimationSpeed);
	else if(AnimationType == Chat2)
		LoopAnim('Chat2', AnimationSpeed);
	else if(AnimationType == Thrust)
		LoopAnim('Thrust', AnimationSpeed);
	else if(AnimationType == Flip)
		LoopAnim('Flip', AnimationSpeed);
	else if(AnimationType == Death1)
		LoopAnim('Death1', AnimationSpeed);
	else if(AnimationType == Death2)
		LoopAnim('Death2', AnimationSpeed);
	else if(AnimationType == Death3)
		LoopAnim('Death3', AnimationSpeed);
	else if(AnimationType == Death4)
		LoopAnim('Death4', AnimationSpeed);
	else if(AnimationType == Death7)
		LoopAnim('Death7', AnimationSpeed);
	else if(AnimationType == Death8)
		LoopAnim('Death8', AnimationSpeed);
	else if(AnimationType == Death9)
		LoopAnim('Death9', AnimationSpeed);
	else if(AnimationType == Death9B)
		LoopAnim('Death9B', AnimationSpeed);
	else if(AnimationType == Death11)
		LoopAnim('Death11', AnimationSpeed);
	else if(AnimationType == BackRun)
		LoopAnim('BackRun', AnimationSpeed);
	else if(AnimationType == StrafeL)
		LoopAnim('StrafeL', AnimationSpeed);
	else if(AnimationType == StrafeR)
		LoopAnim('StrafeR', AnimationSpeed);
}

defaultproperties
{
	AnimationType=Taunt1
	AnimationSpeed=1
	AnimSequence=CockGunL
	CollisionHeight=39
	CollisionRadius=17
	bBlockActors=true
	bBlockPlayers=true
	bCollideActors=true
	bCollideWorld=true
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.Soldier'
	Texture=Texture'Engine.S_Pawn'
	bNoDelete=false
	bStatic=false
	bCollideActors=true
}