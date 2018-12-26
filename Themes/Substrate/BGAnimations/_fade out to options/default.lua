return Def.ActorFrame {
	LoadActor("../_fade out slow"),

	--NOTE: This transition plays for both backing out (to title or name entry) and for selecting a song.
	Def.BitmapText {
		Condition=STATSMAN:GetStagesPlayed()>0,
		InitCommand=function(s) s:x(SCREEN_CENTER_X) s:y(SCREEN_CENTER_Y) s:zoom(2) s:shadowlength(0) s:diffusealpha(0) end,
		SongChosenMessageCommand=cmd(visible,false),
		StartTransitioningCommand=function(s) s:linear(0.3) s:diffusealpha(1) end,
		Text="Loading", --TODO L10n
		Font="_common semibold white",
	},
	Def.BitmapText {
		Condition=THEME:GetMetric("SelectMusic","OptionsMenuAvailable"),
		Text="Press &START; again to\nopen options menu", --TODO L10n
		Font="_common semibold white",

		InitCommand=cmd(visible,false;shadowlength,0;zoom,1.5;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;diffusealpha,0),
		SongChosenMessageCommand=cmd(visible,true;finishtweening;diffusealpha,0;linear,0.3;diffusealpha,1;
			sleep,tonumber(THEME:GetMetric("SelectMusic","ShowOptionsMessageSeconds"))-0.6;linear,0.3;diffusealpha,0),
		ShowEnteringOptionsCommand=cmd(stoptweening;sleep,0.075;linear,0.15;diffusealpha,0)
	},
	Def.BitmapText {
		Font="_common semibold white",
		Text="Opening options menu", --TODO l10n

		InitCommand=cmd(shadowlength,0;zoom,1.5;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;diffusealpha,0;finishtweening),
		ShowEnteringOptionsCommand=cmd(stoptweening;decelerate,0.3;diffusealpha,1)
	},
}
