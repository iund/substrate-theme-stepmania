return Def.ActorFrame {
	LoadActor("../_fade out slow"),
	Def.BitmapText {
		InitCommand=function(s) s:x(SCREEN_CENTER_X) s:y(SCREEN_CENTER_Y) s:zoom(2) s:shadowlength(0) s:diffusealpha(0) end,
		StartTransitioningCommand=function(s) s:linear(0.3) s:diffusealpha(1) end,
		Text="Saving", --TODO L10n
		Font="_common semibold white",
	},

	Def.BitmapText {
		Condition=GAMESTATE:IsAnyHumanPlayerUsingMemoryCard(),
		Font="_common white",
		Text="Do not remove your USB yet", --TODO L10n
		InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+100;shadowlength,0;diffusealpha,0),
		StartTransitioningCommand=function(s) s:linear(0.3) s:diffusealpha(1) end,
	}
}
