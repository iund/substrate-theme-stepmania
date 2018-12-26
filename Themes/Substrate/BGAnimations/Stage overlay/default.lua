return Def.ActorFrame {
	Def.Sprite {
		Texture=IsCourseMode() and GetCurCourse() and GetCurCourse():GetBackgroundPath()
			or not IsCourseMode() and GetCurSong() and GetCurSong():GetBackgroundPath()
			or THEME:GetPathG("Common","fallback background"),
		BeforeLoadingNextCourseSongMessageCommand=function(s)
			s:LoadBackground(
				GetCurCourse():GetCourseEntry(GAMESTATE:GetLoadingCourseSongIndex()):GetSong():GetBackgroundPath()
				or THEME:GetPathG("Common fallback background"))
			s:stretchtoscreen() s:diffusealpha(0) s:finishtweening()
			end,
		StartCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,1),
		FinishCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,0),
		OnCommand=cmd(stretchtoscreen),
	},
	LoadActor("box")..{
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-(IsCourseMode() and 80 or 0)),
	},

	Def.Sprite{
		Texture="course progress box",
		Condition=IsCourseMode(),
		InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+136),	
		BeforeLoadingNextCourseSongMessageCommand=cmd(finishtweening;diffusealpha,0),
		FinishCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,0),
		StartCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,1),
	},
	LoadActor("../_course progress")..{
		Condition=IsCourseMode(),
	},
}
