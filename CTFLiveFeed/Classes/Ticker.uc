class Ticker expands Actor;

var LiveFeedHUDItem HUDItem;

function Tick(float deltatime)
{
	super.tick(deltatime);
	if(HUDItem != None)
		HUDItem.Ticking(deltatime);
}
