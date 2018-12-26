-- This is the tail end of the "entering mods menu" transition from SSM. Accordingly, ensure the text positioning etc matches that in _fade out to options.
return Def.ActorFrame{
	LoadActor("../_fade in normal"),

	Def.BitmapText{
		Font="_common semibold white",
		Text="Opening options menu", --TODO l10n

		OnCommand=cmd(shadowlength,0;zoom,1.5;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y),
		StartTransitioningCommand=cmd(linear,0.15;diffusealpha,0)
	}
}
