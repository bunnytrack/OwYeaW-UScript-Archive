class MovSync expands Actor config (MovSync);

var() config float MinTime;

event PreBeginPlay()
{
   local Mover M;

   log ("Mover Net Sync Tweaking Actor has been loaded.",'MoverSync');

   if ( MinTime == 0 ) // Generate ini or rewrite Moron type setup
   {
      MinTime = 0.2;
      SaveConfig();
   }
// Fast moving movers can be used as effects for something creative.
// We try to ignore movers moving under MinTime seconds.
// But GradualMover and other classes with multiple timers have another deal.
   foreach AllActors(class'Mover', M)
   {
      if ( M.NumKeys == 0 ) //Some maps uses these for various purposes - they won't move.
         continue;
      if ( M.Class == Class'Mover' || M.Class == Class'MixMover' || M.Class == Class'LoopMover'
      || M.Class == Class'GradualMover' || M.Class == Class'ElevatorMover' || M.Class == Class'AttachMover'|| M.Class == Class'AssertMover') //Completely excepting any RotatingMover
         FixMover(M,M.MoveTime);
   }
   if ( M == None )
   {
      log ("This Map does not have any mover...",'MoverSync');
   }
   else
      M = None;
   LifeSpan = 1.000000; //I don't think I will destroy this during Initialization
}

final function FixMover( Mover M, float Secs )
{
   local bool bInvalidMover;
   local int i;

   if ( M.bStatic || Secs >= 3600 || M == None || M.bDeleteMe ) //Not gonna be like in sh!t maps a la CryptRunners with Movers that can be deleted.
      bInvalidMover = True;

   if ( !bInvalidMover )
   {
      if ( i != 0 )
         i = 0;
      if ( M.MoveTime > MinTime ) //Not sure if GradualMover will use these but let's solve it too, never dealing with 0, it's pointless.
         M.MoveTime = ComputeTime(Secs);
      for ( i = 0 ; i < 6 ; i++ )
      {
         if ( GradualMover(M) != None )
         {
            if ( GradualMover(M).OpenTimes[i] > MinTime )
               GradualMover(M).OpenTimes[i] = ComputeTime(GradualMover(M).OpenTimes[i]);
            if ( GradualMover(M).CloseTimes[i] > MinTime )
               GradualMover(M).CloseTimes[i] = ComputeTime(GradualMover(M).CloseTimes[i]);
         }
         else if ( AssertMover(M) != None )
         {
            if ( AssertMover(M).OpenTimes[i] > MinTime )
               AssertMover(M).OpenTimes[i] = ComputeTime(AssertMover(M).OpenTimes[i]);
            if ( AssertMover(M).CloseTimes[i] > MinTime )
               AssertMover(M).CloseTimes[i] = ComputeTime(AssertMover(M).CloseTimes[i]);
         }
         else if ( MixMover(M) != None )
         {
            if ( MixMover(M).OpenTimes[i] > MinTime )
               MixMover(M).OpenTimes[i] = ComputeTime(MixMover(M).OpenTimes[i]);
            if ( MixMover(M).CloseTimes[i] > MinTime )
               MixMover(M).CloseTimes[i] = ComputeTime(MixMover(M).CloseTimes[i]);
         }
      }
      if ( i != 0 )
         i = 0;
   }
}

final function float ComputeTime(float OldMove)
{
   local float Seconds;

   Seconds = OldMove;
   Seconds = int(100.0 * FMax(0.01, (1.0 / FMax(Seconds, 0.005))));
   Seconds = 1.0 / (Seconds * 0.01);

   return Seconds;
}

DefaultProperties
{
   RemoteRole=ROLE_None
   NetUpdateFrequency=0.01
   CollisionHeight=1
   CollisionRadius=1
   bHidden=True
   DrawType=DT_None
   MinTime=0.2
}