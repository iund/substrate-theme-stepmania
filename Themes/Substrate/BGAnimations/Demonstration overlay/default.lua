return Def.ActorFrame {
	Def.Sprite{
		Texture="../Demonstration overlay/demonstration gradient",
		OnCommand=cmd(stretchtoscreen;diffusealpha,0.8),
	},
	Def.BitmapText {
		Font="_common semibold white",
		OnCommand=cmd(shadowlength,0;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+180;pulse;effectmagnitude,1.0,0.9,0;effectclock,"beat";effectperiod,1),
		Text="Demo",
	},
	LoadActor("../Gameplay overlay")..{
	},
	LoadActor("../Attract overlay")..{
	},
}