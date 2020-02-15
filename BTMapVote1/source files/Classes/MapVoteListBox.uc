//-----------------------------------------------------------
// MapVote Mutator By BDB (Bruce Bickar)
//-----------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BT MapVote made by OwYeaW				  		  BT-GODЩ
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class MapVoteListBox expands UWindowListBox;

var 	UMenuMapvoteList 		ListItems[4096];
var 	int 					CountFindItems;
var 	string 					CurrentMapName;
var		bool					bGoldTheme;		
  //-----------------------------------------------------------------------------
function Paint(Canvas C, float MouseX, float MouseY)
{
	C.DrawColor.r = 0;
	C.DrawColor.g = 0;
	C.DrawColor.b = 0;

	// textura fona boxa s kartamy
	DrawStretchedTexture(C, 0, 0,WinWidth, WinHeight, Texture'UWindow.WhiteTexture');
	Super.Paint(C, MouseX, MouseY);
}

//-----------------------------------------------------------------------------
function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local string MapName;
	
	if (Root.LookAndFeelClass != "UMenu.UMenuBlueLookAndFeel")
		bGoldTheme = True;
	
	if (bGoldTheme)
	{
		if (UMenuMapVoteList(Item).bSelected)
		{
			C.DrawColor.r = 255;
			C.DrawColor.g = 77;
			C.DrawColor.b = 0;

			// texture  kogda videlaetsia item
			DrawStretchedTexture(C, X, Y, W, H - 1, Texture'UWindow.WhiteTexture');
			C.DrawColor.r = 0;
			C.DrawColor.g = 0;
			C.DrawColor.b = 0;
		}
		else
		{
			C.DrawColor.r = 0;
			C.DrawColor.g = 0;
			C.DrawColor.b = 0;
			DrawStretchedTexture(C, X, Y, W, H - 1, Texture'UWindow.WhiteTexture');
			C.DrawColor.r = 255;
			C.DrawColor.g = 255;
			C.DrawColor.b = 255;
		}
		C.Font = Root.Fonts[F_Normal];
		MapName = UMenuMapVoteList(Item).MapName;
		ClipText(C, X + 2, Y, MapName);
	}
	else
	{
		if (UMenuMapVoteList(Item).bSelected)
		{
			C.DrawColor.r = 0;
			C.DrawColor.g = 77;
			C.DrawColor.b = 255;

			// texture  kogda videlaetsia item
			DrawStretchedTexture(C, X, Y, W, H - 1, Texture'UWindow.WhiteTexture');
			C.DrawColor.r = 0;
			C.DrawColor.g = 0;
			C.DrawColor.b = 0;
		}
		else
		{
			C.DrawColor.r = 0;
			C.DrawColor.g = 0;
			C.DrawColor.b = 0;
			DrawStretchedTexture(C, X, Y, W, H - 1, Texture'UWindow.WhiteTexture');
			C.DrawColor.r = 255;
			C.DrawColor.g = 255;
			C.DrawColor.b = 255;
		}
		C.Font = Root.Fonts[F_Normal];
		MapName = UMenuMapVoteList(Item).MapName;
		ClipText(C, X + 2, Y, MapName);
	}
}

//-----------------------------------------------------------------------------
function KeyDown(int Key, float X, float Y)
{
	local int i;
	local UWindowListBoxItem ItemPointer;
	local UMenuMapVoteList MapItem;
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
				if(ItemPointer.Prev == None || ItemPointer.Prev == SelectedItem.Sentinel)
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
function SelectMap(string MapName)
{
	local UMenuMapVoteList MapItem;

	for (MapItem = UMenuMapVoteList(Items); MapItem != None; MapItem = UMenuMapVoteList(MapItem.Next))
	{
		if (MapName ~= MapItem.MapName)
		{
			SetSelectedItem(MapItem);
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
function Find(string SearchText)
{
	local UWindowListBoxItem ItemPointer;
	local UMenuMapVoteList MapItem;

	if (CAPS(SearchText) == "CTF" || CAPS(SearchText) == "CTF-" || CAPS (SearchText)=="CT" || CAPS(SearchText) == "CTF+")
		return;

	if (CAPS(SearchText) == "CTF-B" || CAPS(SearchText) == "CTF-BT" || CAPS(SearchText) == "CTF-BT-" || CAPS(SearchText) == "CTF-BT+")
		return;

	if (CAPS(SearchText) == "BT-" || CAPS(SearchText) == "BT" || CAPS(SearchText) == "BT+")
		return;

	// цикл очистки списка от предыдущего
	for (CountFindItems = 0; CountFindItems <= 4095; CountFindItems++)
		ListItems[CountFindItems] = None;

	CountFindItems = 0;
	for (MapItem = UMenuMapVoteList(Items); MapItem != None; MapItem = UMenuMapVoteList(MapItem.Next))
	{
		if (InStr(Caps(MapItem.MapName), Caps(SearchText)) != -1)
		{
			ListItems[CountFindItems + 1] = MapItem;
			CountFindItems++;
		}
	}

	if (ListItems[1] !=None) 
	{
		SetSelectedItem(ListItems[1]);
		MakeSelectedVisible();
	}
}

//-----------------------------------------------------------------------------
function NextMap(int CountItems)
{
	if (ListItems[CountItems] !=None) 
	{
		SetSelectedItem(ListItems[CountItems]);
		MakeSelectedVisible(); 
		CurrentMapName = ListItems[CountItems].MapName;
	}
}

function SetMapByIndex(int mapIndex)
{
	local UMenuMapVoteList MapItem;
	// Cleaning cycle from the previous list
	for(CountFindItems = 0; CountFindItems <=4095; CountFindItems++ )
	{
		ListItems[CountFindItems] = None;
	}

	CountFindItems = 0;
	for(MapItem=UMenuMapVoteList(Items); MapItem!=None; MapItem=UMenuMapVoteList(MapItem.Next) )
	{
		ListItems[CountFindItems]=MapItem;
		CountFindItems++;
	}

	if(ListItems[mapIndex] != None)
	{
		SetSelectedItem(ListItems[mapIndex]);
		MakeSelectedVisible(); 
		CurrentMapName = ListItems[mapIndex].MapName;
	} 
}

//-----------------------------------------------------------------------------

defaultproperties
{
    ItemHeight=13.000000
    ListClass=Class'BTMapVote1.UMenuMapVoteList'
}