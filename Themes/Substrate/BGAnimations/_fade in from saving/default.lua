return Def.ActorFrame {
	Def.Quad {
		InitCommand=function(s) s:stretchtoscreen() s:diffuse(0,0,0,1) end,
		StartTransitioningCommand=function(s) s:linear(0.3) s:diffusealpha(0) end
	},
	Def.BitmapText {
		InitCommand=function(s) s:x(SCREEN_CENTER_X) s:y(SCREEN_CENTER_Y) s:zoom(2) s:shadowlength(0) end,
		StartTransitioningCommand=function(s) s:linear(0.3) s:diffusealpha(0) end,
		Text="Saving", --TODO l10n
		Font="_common semibold white",
	},
	Def.BitmapText {
		Condition=GAMESTATE:IsAnyHumanPlayerUsingMemoryCard(),
		Font="_common white",
		Text="Do not remove your USB yet", --TODO L10n
		InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+100),
		StartTransitioningCommand=function(s) s:linear(0.3) s:diffusealpha(0) end,
	}
}