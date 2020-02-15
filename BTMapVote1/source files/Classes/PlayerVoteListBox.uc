//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GOD™
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class PlayerVoteListBox expands UWindowListBox;

var 	color 					TeamColor[4];
var		bool					bGoldTheme;	

function Created()
{
	Super.Created();
	VertSB.Close();
	
	if (Root.LookAndFeelClass != "UMenu.UMenuBlueLookAndFeel" )
		bGoldTheme = True;
}
//-----------------------------------------------------------------------------
function Paint(Canvas C, float MouseX, float MouseY)
{
	C.DrawColor.r = 0;
	C.DrawColor.g = 0;
	C.DrawColor.b = 0;

	DrawStretchedTexture(C, 0, 0,WinWidth, WinHeight, Texture'UWindow.WhiteTexture');
	Super.Paint(C, MouseX, MouseY);
}

//-----------------------------------------------------------------------------
function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if (bGoldTheme)
	{
		if (PlayerVoteListItem(Item).bSelected)
		{
			C.DrawColor.r = 0;
			C.DrawColor.g = 0;
			C.DrawColor.b = 0;

			DrawStretchedTexture(C, X, Y, W, H - 1, Texture'UWindow.WhiteTexture');

			C.DrawColor.r = 255;
			C.DrawColor.g = 115;
			C.DrawColor.b = 0;
		}
		else
		{
			C.DrawColor.r = 0;
			C.DrawColor.g = 0;
			C.DrawColor.b = 0;

			DrawStretchedTexture(C, X, Y, W, H - 1, Texture'UWindow.WhiteTexture');

			C.DrawColor.r = 255;
			C.DrawColor.g = 115;
			C.DrawColor.b = 0;
		}
	}
	else
	{
		if (PlayerVoteListItem(Item).bSelected)
		{
			C.DrawColor.r = 0;
			C.DrawColor.g = 0;
			C.DrawColor.b = 0;

			DrawStretchedTexture(C, X, Y, W, H - 1, Texture'UWindow.WhiteTexture');

			C.DrawColor.r = 0;
			C.DrawColor.g = 140;
			C.DrawColor.b = 255;
		}
		else
		{
			C.DrawColor.r = 0;
			C.DrawColor.g = 0;
			C.DrawColor.b = 0;

			DrawStretchedTexture(C, X, Y, W, H - 1, Texture'UWindow.WhiteTexture');

			C.DrawColor.r = 0;
			C.DrawColor.g = 140;
			C.DrawColor.b = 255;
		}
	}
	
	C.Font = Root.Fonts[F_Normal];
	ClipText(C, X + 2, Y, Mid(PlayerVoteListItem(Item).PlayerName, 4));
}

//-----------------------------------------------------------------------------
function KeyDown(int Key, float X, float Y)
{
	local int i;
	local UWindowListBoxItem ItemPointer;
	local PlayerPawn P;

	P = GetPlayerOwner();

	if (Key == P.EInputKey.IK_MouseWheelDown || Key == P.EInputKey.IK_Down)
	{
		if (SelectedItem != None && SelectedItem.Next != None)
		{
			SetSelectedItem(UWindowListBoxItem(SelectedItem.Next));
			MakeSelectedVisible();
		}
	}

	if (Key == P.EInputKey.IK_MouseWheelUp || Key == P.EInputKey.IK_Up)
	{
		if (SelectedItem != None && SelectedItem.Prev != None && SelectedItem.Sentinel != SelectedItem.Prev)
		{
			SetSelectedItem(UWindowListBoxItem(SelectedItem.Prev));
			MakeSelectedVisible();
		}
	}

	if (Key == P.EInputKey.IK_PageDown)
	{
		if (SelectedItem != None)
		{
			ItemPointer = SelectedItem;
			for (i = 0; i < 7; i++)
			{
				if (ItemPointer.Next == None)
					return;
				ItemPointer = UWindowListBoxItem(ItemPointer.Next);
			}

			SetSelectedItem(ItemPointer);
			MakeSelectedVisible();
		}
	}

	if (Key == P.EInputKey.IK_PageUp)
	{
		if (SelectedItem != None)
		{
			ItemPointer = SelectedItem;
			for (i = 0; i < 7; i++)
			{
				if (ItemPointer.Prev == None || ItemPointer.Prev == SelectedItem.Sentinel)
					return;
				ItemPointer = UWindowListBoxItem(ItemPointer.Prev);
			}

			SetSelectedItem(ItemPointer);
			MakeSelectedVisible();
		}
	}

	ParentWindow.KeyDown(Key, X, Y);
}

//-----------------------------------------------------------------------------
function SelectPlayer(string PlayerName)
{
	local PlayerVoteListItem PlayerItem;
	local string PlayerID;

	PlayerID = left(PlayerName, 3);

	for (PlayerItem = PlayerVoteListItem(Items); PlayerItem != None; PlayerItem = PlayerVoteListItem(PlayerItem.Next))
	{
		if (PlayerID == right(left(PlayerItem.PlayerName, 4), 3))
		{
			SetSelectedItem(PlayerItem);
			MakeSelectedVisible();
			break;
		}
	}
}

//-----------------------------------------------------------------------------
function DoubleClickItem(UWindowListBoxItem I)
{
	UWindowDialogClientWindow(ParentWindow).Notify(self, DE_DoubleClick);
}

//-----------------------------------------------------------------------------

defaultproperties
{
    ItemHeight=13.000000
    ListClass=Class'BTMapVote1.PlayerVoteListItem'
}