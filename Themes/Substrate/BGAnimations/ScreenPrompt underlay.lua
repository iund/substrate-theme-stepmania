return Def.ActorFrame{
	OnCommand=function() SOUND:PlayOnce("TextEntry open",true) end,

	Def.Quad{
		InitCommand=cmd(stretchtoscreen;diffuse,0,0,0,0),
		OnCommand=cmd(decelerate,0.3;diffusealpha,0.5)
	},
	Def.Sprite{
		Texture=THEME:GetPathG("Prompt","box"),
		InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-8;diffusealpha,0),
		OnCommand=cmd(decelerate,0.3;diffusealpha,CommonPaneDiffuseAlpha)
	}
}
