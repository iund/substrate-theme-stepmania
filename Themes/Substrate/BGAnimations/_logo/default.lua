return Def.ActorFrame{
	Def.Sprite{
		Texture="penta",
		InitCommand=cmd(zoom,1.5;diffusealpha,0.5;y,-24)
	},
	Def.BitmapText{
		Font="_common semibold white",
		Text=THEME:GetThemeDisplayName(),
		OnCommand=cmd(y,-64;zoom,2;shadowlength,0)
	},
	Def.BitmapText{
		Font="_common white",
		Text=ThemeVersionString(),
		OnCommand=cmd(y,-28;zoom,0.75;shadowlength,0)
	}
}
