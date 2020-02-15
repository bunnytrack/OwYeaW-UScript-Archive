//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MatchVote made by OwYeaW				  		  BT-GODЩ
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class TempMapList expands ReplicationInfo config (MapVoteDatabase);
  
var 	config string 			UpdateKey;
var 	config string 			MapList[4096];
var 	string 					serverUpdateKey;
var 	string 					TempList1[257];
var 	string 					TempList2[257];
var 	string 					TempList3[257];
var 	string 					TempList4[257];
var 	string 					TempList5[257];
var 	string 					TempList6[257];
var 	string 					TempList7[257];
var 	string 					TempList8[257];
var 	string 					TempList9[257];
var 	string 					TempList10[257];
var 	string 					TempList11[257];
var 	string 					TempList12[257];
var 	string 					TempList13[257];
var 	string 					TempList14[257];
var 	string 					TempList15[257];
var 	string 					TempList16[257];

var 	PlayerPawn 				ActorOwner;
var 	int 					MapsCacheCount;
var 	bool 					TransferDone;
var 	bool 					ClientHasData;
 
//-----------------------------------------------------------------------------
replication
{
	reliable if (Role == ROLE_Authority)
    MapsCacheCount,
    ActorOwner,
    serverUpdateKey;

	// передаЄм серверу переменную TransferDone через функцию TransferEnd
	reliable if (Role < ROLE_Authority)
    TransferEnd;

	reliable if( Role == ROLE_Authority)
    TempList1,TempList2,TempList3,TempList4,TempList5,TempList6,TempList7,TempList8,
    TempList9,TempList10,TempList11,TempList12,TempList13,TempList14,TempList15,
    TempList16;
}

//-----------------------------------------------------------------------------
simulated function tick(float DeltaTime)
{
	if (Owner == None)
		Destroy();
}

//-----------------------------------------------------------------------------
simulated event PostNetBeginPlay ()
{ 
	local int countmap;
	local int x, i;
	local int pos, next, prev, long;

	for (x = 0; x <= 4095; x++)
	{
		if (MapList[x] != "")
			countmap++;
	}

	log("ServerKey=" @ serverUpdateKey @ "MapsOnServer=" @ MapsCacheCount);
	log("ClientKey=" @ UpdateKey @ "MapsOnClient=" @ countmap);
	log("You join as" @ ActorOwner);

	if (countmap == MapsCacheCount && serverUpdateKey == UpdateKey)
	{
		ClientHasData = True;
		TransferEnd();
	}

	if (Owner != None && Level.NetMode != NM_DedicatedServer)
		settimer(1, false); 
}

//-----------------------------------------------------------------------------
simulated event timer()
{
	local int i;
	local int TempCounting;

	if (!TransferDone)
	{   
		for (i = 1; TempList1[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList2[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList3[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList4[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList5[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList6[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList7[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList8[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList9[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList10[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList11[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList12[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList13[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList14[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList15[i] != "" && i < 256; i++) TempCounting++;
		for (i = 1; TempList16[i] != "" && i < 256; i++) TempCounting++;

		if (TempCounting != MapsCacheCount && !ClientHasData)
		{
			settimer(1, false);
			// log("Maps saved="@TempCounting$"/"$MapsCacheCount);
			return;
		}
		if (TempCounting == MapsCacheCount)
		{ 
			for (i = 0; i <= 4095; i++)
				MapList[i] = "" ;

			for (i = 1; i <= MapsCacheCount; i++)
			{
				if (i < 256)               MapList[i - 1] =  TempList1[i];  
				if (i >= 256 && i < 511)   MapList[i - 1] =  TempList2[i - 255];  
				if (i >= 511 && i < 766)   MapList[i - 1] =  TempList3[i - 510];  
				if (i >= 766 && i < 1021)  MapList[i - 1] =  TempList4[i - 765]; 
				if (i >= 1021 && i < 1276) MapList[i - 1] =  TempList5[i - 1020]; 
				if (i >= 1276 && i < 1531) MapList[i - 1] =  TempList6[i - 1275]; 
				if (i >= 1531 && i < 1786) MapList[i - 1] =  TempList7[i - 1530]; 
				if (i >= 1786 && i < 2041) MapList[i - 1] =  TempList8[i - 1785]; 
				if (i >= 2041 && i < 2296) MapList[i - 1] =  TempList9[i - 2040]; 
				if (i >= 2296 && i < 2551) MapList[i - 1] =  TempList10[i - 2295]; 
				if (i >= 2551 && i < 2806) MapList[i - 1] =  TempList11[i - 2550]; 
				if (i >= 2806 && i < 3061) MapList[i - 1] =  TempList12[i - 2805]; 
				if (i >= 3061 && i < 3316) MapList[i - 1] =  TempList13[i - 3060]; 
				if (i >= 3316 && i < 3571) MapList[i - 1] =  TempList14[i - 3315];  
				if (i >= 3571 && i < 3826) MapList[i - 1] =  TempList15[i - 3570];   
				if (i >= 3826)             MapList[i - 1] =  TempList16[i - 3825];       
			} 
			if (!ClientHasData)
			{
				ActorOwner.ClientMessage("[BT-MatchVote] Download Completed");
				TransferEnd();
				UpdateKey = serverUpdateKey;
				TransferDone = True;
			}
			saveconfig();
		}
	}
}

//-----------------------------------------------------------------------------
simulated function TransferEnd()
{ 
	TransferDone = True; 
}

//-----------------------------------------------------------------------------
defaultproperties
{
	UpdateKey="33mp31337"
	RemoteRole=ROLE_SimulatedProxy
}