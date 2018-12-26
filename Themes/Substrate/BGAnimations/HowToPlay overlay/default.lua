-- NOTE: Yet another auto-conversion with some fixes.

return Def.ActorFrame {
	Def.Sprite{
		Texture="../Demonstration overlay/demonstration gradient",
		OnCommand=cmd(stretchtoscreen;diffusealpha,0.8),
	},
	Def.BitmapText {
		Font="_common semibold white",
		OnCommand=cmd(shadowlength,0;x,SCREEN_CENTER_X+SCREEN_WIDTH/4+10;y,SCREEN_CENTER_Y;zoom,2;diffusealpha,0;sleep,5;linear,0.5;diffusealpha,1;sleep,5;linear,0.3;diffusealpha,0),
		Text="Arrows\nmove up\nthe screen\nin time to\nmusic.",
	},
	Def.Sprite {
		Texture="arrows border",
		OnCommand=cmd(x,GetScreen():GetChild("PlayerP1"):GetX();y,SCREEN_CENTER_Y+56;diffuseblink;effectperiod,0.5;diffusealpha,0;sleep,6;linear,0.3;diffusealpha,1;sleep,4;linear,0.3;diffusealpha,0),
	},
	Def.BitmapText {
		Font="_common semibold white",
		OnCommand=cmd(shadowlength,0;x,SCREEN_CENTER_X+SCREEN_WIDTH/4+10;y,SCREEN_CENTER_Y;zoom,2;diffusealpha,0;sleep,11;linear,0.5;diffusealpha,1;sleep,5;linear,0.3;diffusealpha,0),
		Text="Step when\nan arrow\noverlaps\nits target\nat the top.",
	},
	Def.Sprite {
		Texture="targets border",
		OnCommand=cmd(x,GetScreen():GetChild("PlayerP1"):GetX();
			y,THEME:GetMetric("Player","ReceptorArrowsYStandard")+SCREEN_CENTER_Y;
			diffuseblink;effectperiod,0.5;diffusealpha,0;sleep,12;linear,0.3;diffusealpha,1;sleep,4;linear,0.3;diffusealpha,0),
	},
	Def.BitmapText {
		Font="_common semibold white",
		OnCommand=cmd(shadowlength,0;x,SCREEN_CENTER_X+SCREEN_WIDTH/4+10;y,SCREEN_CENTER_Y;zoom,2;diffusealpha,0;sleep,17;linear,0.5;diffusealpha,1;sleep,5;linear,0.3;diffusealpha,0),
		Text="The\nTraffic Light\nhelps you\nunderstand\nthe timing.",
	},
	Def.Sprite {
		Texture="lights border",
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-48;diffuseblink;effectperiod,0.5;diffusealpha,0;sleep,18;linear,0.3;diffusealpha,1;sleep,4;linear,0.3;diffusealpha,0),
	},
	Def.BitmapText {
		Font="_common semibold white",
		OnCommand=cmd(shadowlength,0;x,SCREEN_CENTER_X+SCREEN_WIDTH/4+10;y,SCREEN_CENTER_Y;zoom,2;diffusealpha,0;sleep,23;linear,0.5;diffusealpha,1;sleep,5;linear,0.3;diffusealpha,0),
		Text="The direction\nof the arrow\nsays which\nPanel\nto step on.",
	},
	Def.BitmapText {
		Font="_common semibold white",
		OnCommand=cmd(shadowlength,0;x,SCREEN_CENTER_X+SCREEN_WIDTH/4+10;y,SCREEN_CENTER_Y;zoom,2;diffusealpha,0;sleep,29;linear,0.5;diffusealpha,1;sleep,5;linear,0.3;diffusealpha,0),
		Text="Fill your\nLife Bar by\nstepping\ncorrectly\nin time.",
	},
	Def.Sprite {
		Texture="lifebar border",
		OnCommand=cmd(
		x,THEME:GetMetric(GetScreen():GetName(),"LifeP1X");
		y,THEME:GetMetric(GetScreen():GetName(),"LifeP1Y");
		diffuseblink;effectperiod,0.5;diffusealpha,0;sleep,35;linear,0.3;diffusealpha,1;sleep,4;linear,0.3;diffusealpha,0),
	},
	Def.BitmapText {
		Font="_common semibold white",
		Text="The game\nends early if\nyour Life Bar\nbecomes empty.",
		OnCommand=cmd(shadowlength,0;x,SCREEN_CENTER_X+SCREEN_WIDTH/4+10;y,SCREEN_CENTER_Y;zoom,2;diffusealpha,0;sleep,35;linear,0.5;diffusealpha,1;sleep,5;linear,0.3;diffusealpha,0)
	},
	LoadActor("../Gameplay overlay")..{
	},
	Def.Quad {
		InitCommand=cmd(draworder,110),
		OnCommand=cmd(stretchtoscreen;diffuse,0,0,0,1;sleep,3.5;linear,0.5;diffusealpha,0),
	},
	Def.BitmapText {
		InitCommand=cmd(draworder,110),
		Font="_common semibold white",
		OnCommand=cmd(shadowlength,0;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;zoom,2.5;diffusealpha,0;linear,1;diffusealpha,1;sleep,2;decelerate,0.5;zoom,1;y,SCREEN_TOP+24),
		Text="How to Play",
	},
	LoadActor("../Attract overlay")..{
	},
}
