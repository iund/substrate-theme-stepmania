return Def.ActorFrame{
	Def.Sprite {
		Texture=GetCurSong() and GetCurSong():GetBackgroundPath() or THEME:GetPathG("Common","fallback background"),
		InitCommand=function(s) s:stretchtoscreen() s:diffuse(0,0,0,0) end,
		CurrentSongChangedMessageCommand=cmd(LoadBackground,GetCurSong() and GetCurSong():GetBackgroundPath() or THEME:GetPathG("Common","fallback background");
			stretchtoscreen),
		StartTransitioningCommand=function(s) s:sleep(0.3) s:linear(0.3) s:diffusealpha(GetPref("BGBrightness")) end,
		BeforeLoadingNextCourseSong=cmd(LoadBackground,GetCurSong() and GetCurSong():GetBackgroundPath() or THEME:GetPathG("Common","fallback background"))
	}
}