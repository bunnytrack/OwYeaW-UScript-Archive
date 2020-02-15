//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MatchVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class MapStatusListBox expands UWindowListBox;

var		bool					bGoldTheme;
var		color					BlackColor;
var		color					OrangeColor;
var		color					BlueColor;
var		color					ThemeColor;
//-----------------------------------------------------------------------------
function Created()
{
	Super.Created();
	VertSB.Close();

	if (Root.LookAndFeelClass == "UMenu.UMenuBlueLookAndFeel")
	{
		bGoldTheme = false;
		ThemeColor = BlueColor;
	}
	else
	{
		bGoldTheme = true;
		ThemeColor = OrangeColor;
	}
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	if(bGoldTheme)
	{
		// right outer line
		DrawStretchedTexture(C, 	265, 		0, 					2, 				WinHeight, 			Texture'BorderOrange');
		// rank divider line
		DrawStretchedTexture(C, 	20, 		0, 					1, 				WinHeight, 			Texture'BorderOrange');
	}
	else
	{
		// right outer line
		DrawStretchedTexture(C, 	265, 		0, 					2, 				WinHeight, 			Texture'BorderBlue');
		// rank divider line
		DrawStretchedTexture(C, 	20, 		0, 					1, 				WinHeight, 			Texture'BorderBlue');
	}
	Super.Paint(C, MouseX, MouseY);
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if (MapStatusListItem(Item).bSelected)
	{
		// draw orange background
		C.DrawColor = ThemeColor;
		DrawStretchedTexture(C, 	X, 		Y + 1, 				265, 			H - 2, 				Texture'UWindow.WhiteTexture');
		// draw black outer bouder lines
		C.DrawColor = BlackColor;
		// bottom line
		DrawStretchedTexture(C, 	X, 		Y + H - 1, 			265, 			1, 					Texture'UWindow.WhiteTexture');
		// rank divider line
		DrawStretchedTexture(C, 	20, 	Y, 					1, 				H, 					Texture'UWindow.WhiteTexture');
		// left line
		DrawStretchedTexture(C, 	0, 		Y, 					1, 				H, 					Texture'UWindow.WhiteTexture');
		// right line
		DrawStretchedTexture(C, 	264, 	Y, 					1, 				H, 					Texture'UWindow.WhiteTexture');
	}
	else
	{
		C.DrawColor = ThemeColor;
		DrawStretchedTexture(C, 	X, 		Y + H - 1, 			265, 			1, 					Texture'UWindow.WhiteTexture');
	}
	C.Font = Root.Fonts[F_Normal];
	TextSize(C, "xxxxxxxxxxxxxxxxxxXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", W, H);
	ClipText(C, X + 25, Y, MapStatusListItem(Item).MapName);
	TextSize(C, "xxxxxxxxxxxxxxxxxxXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", W, H);
	ClipText(C, X + 5, Y, MapStatusListItem(Item).VoteCount);
}

function SelectMap(string MapName)
{
	local MapStatusListItem MapItem;

	for (MapItem = MapStatusListItem(Items); MapItem != None; MapItem = MapStatusListItem(MapItem.Next))
	{
		if (MapName ~= MapItem.MapName)
		{
			SetSelectedItem(MapItem);
			MakeSelectedVisible();
			break;
		}
	}
}

function DoubleClickItem(UWindowListBoxItem I)
{
	UWindowDialogClientWindow(ParentWindow).Notify(self, DE_DoubleClick);
}

defaultproperties
{
	OrangeColor=(R=255,G=77)
    BlueColor=(B=255,G=77)
	ItemHeight=13.000000
	ListClass=Class'BTMatchVote2.MapStatusListItem'
}