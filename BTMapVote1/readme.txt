//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\\
//		   BunnyTrack MapVote version 1			\\
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\\

INSTALLATION:

- Place the installation files in the system directory
- Open your server UT.ini and add: ServerPackages=BTMapVote1
- Add to your server Mutators: BTMapVote1.BDBMapVote
- Open BTMapVote1.ini and change the settings to your preference

EXPLANATION BTMapVote1.ini:

[BTMapVote1.BDBMapVote]
BunnyTrackTournamentIP	: BunnyTrack Tournament Server IP
BTGameType		: BunnyTrack GameType
bResetIfNotVoted	: When the game ends and no player voted
ResetMap		: The Server will then switch to this map
MidGameVotePercent	: Percentage needed to start MidGameVoting
VoteTimeLimit		: At game end - Vote time limit
ScoreBoardDelay		: At game end - Time before mapvote opens
NotVoteTime		: At game start - Time to wait before vote
UpdateKey		: Your UpdateKey for loading the maplist
MapsCacheCount		: Amount of maps inside the Maplist
MapCacheList[0]		: Mapname - CTF-BT-MountainBase

- This MapVote supports any MapName with any prefix
