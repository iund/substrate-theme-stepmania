return Def.ActorFrame {
	Def.BitmapText {
		Font="_common bordered white",
		OnCommand=cmd(zoom,0.5;shadowlength,0;y,-12;diffusealpha,0;addy,-20;sleep,4.25;accelerate,.2;diffusealpha,1;addy,20),
		Text="Barely",
	},
	LoadActor("arrow")..{
		OnCommand=cmd(y,6;diffuseshift;effectoffset,.5;diffusealpha,0;sleep,3.5;addy,-20;accelerate,.3;diffusealpha,1;addy,20;decelerate,.3;addy,-10;accelerate,.3;addy,10),
	},
}
