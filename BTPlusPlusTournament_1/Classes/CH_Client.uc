class CH_Client extends Info config(CCHS3);

var config float scale;

replication
{
	reliable if(Role == ROLE_Authority)
		SetScaleClient;
}

function Tick(float DeltaTime)
{
	if(owner == None)
		Destroy();
}

simulated function SetScaleClient(float newScale)
{
	scale = newScale;
	if(ROLE < ROLE_Authority)
		SaveConfig();
}