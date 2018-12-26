return Def.ActorFrame {
	LoadActor("stage box")..{
		BeforeLoadingNextCourseSongMessageCommand=cmd(finishtweening;diffusealpha,0),
		FinishCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,0),
		StartCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,1),
	},
	Def.Sprite {
		Texture=IsCourseMode() and GetCurCourse() and GetCurCourse():GetBannerPath()
			or not IsCourseMode() and GetCurSong() and GetCurSong():GetBannerPath()
			or THEME:GetPathG("Common","fallback background"),
		CurrentSongChangedMessageCommand=cmd(LoadBanner,GetCurSong():GetBannerPath() or THEME:GetPathG("Common","fallback banner")),
		BeforeLoadingNextCourseSongMessageCommand=
			cmd(LoadBanner,
				GetCurCourse():GetCourseEntry(GAMESTATE:GetLoadingCourseSongIndex()):GetSong():GetBannerPath()
				or THEME:GetPathG("Common fallback banner");
			finishtweening;diffusealpha,0),
		StartCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,1),
		FinishCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,0),
		OnCommand=cmd(scaletoclipped,418,164),
	},
	Def.BitmapText {
		StartCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,1),
		FinishCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,0),
		OnCommand=cmd(y,-98;shadowlength,0),
		Font="_common white",
		StartCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,1),
		BeforeLoadingNextCourseSongMessageCommand=cmd(finishtweening;diffusealpha,0;
			settext,GetCurCourse():GetCourseEntry(GAMESTATE:GetLoadingCourseSongIndex()):GetSong():GetDisplayFullTitle()),
		Text=GetCurSong() and GetCurSong():GetDisplayFullTitle() or GetCurCourse() and GetCurCourse():GetDisplayFullTitle() or "",
		CurrentSongChangedMessageCommand=function(s) s:settext(GetCurSong():GetDisplayFullTitle()) end,
	},
	Def.BitmapText {
		FinishCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,0),
		OnCommand=cmd(y,98;shadowlength,0),
		Font="_common white",
		Text=GetStageText(),
		StartCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,1),
		FinishCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,0),
		BeforeLoadingNextCourseSongMessageCommand=cmd(finishtweening;diffusealpha,0),
		CurrentSongChangedMessageCommand=function(s) s:settext(GetStageText()) end,
	},
}