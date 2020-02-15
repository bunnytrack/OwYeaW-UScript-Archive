//=============================================================================
// BT_UWindowCheckbox made by OwYeaW
//=============================================================================
class BT_UWindowCheckbox extends UWindowButton;

var bool bChecked;

function BeforePaint(Canvas C, float X, float Y)
{
	Checkbox_SetupSizes(C);
	Super.BeforePaint(C, X, Y);
}

function LMouseUp(float X, float Y)
{
	if(!bDisabled)
	{
		bChecked = !bChecked;
		Notify(DE_Change);
	}
	Super.LMouseUp(X, Y);
}

function Checkbox_SetupSizes(Canvas C)
{
	local float TW, TH;

	TextSize(C, Text, TW, TH);
	WinHeight = Max(TH+1, 16);
	
	switch(Align)
	{
	case TA_Left:
		ImageX = WinWidth - 16;
		TextX = 0;
		break;
	case TA_Right:
		ImageX = 0;
		TextX = WinWidth - TW;
		break;
	case TA_Center:
		ImageX = (WinWidth - 16) / 2;
		TextX = (WinWidth - TW) / 2;
		break;
	}

	ImageY = 0;
	TextY = 2;

	if(bChecked)
	{
		UpTexture = Texture'ChkChecked';
		DownTexture = Texture'ChkChecked';
		OverTexture = Texture'ChkChecked';
		DisabledTexture = Texture'ChkCheckedDisabled';
	}
	else
	{
		UpTexture = Texture'ChkUnchecked';
		DownTexture = Texture'ChkUnchecked';
		OverTexture = Texture'ChkUnchecked';
		DisabledTexture = Texture'ChkUncheckedDisabled';
	}
}