local screenname=lua.GetThreadVariable("LoadingScreen")

return Def.ActorFrame{
	LoadActor(THEME:GetPathB(THEME:GetMetric("SelectMusic","Fallback"),"overlay")), --TODO correct fallback without hardcoding it? 

	Def.BitmapText {
		Font="_common bordered white",
		InitCommand=cmd(zoom,.75;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-88),
		OnCommand=function(s) 
--			local rate=GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
--			s:settext(rate~=1 and string.format("%1.1fx",rate) or "")
			s:settext(GAMESTATE:GetSongOptionsString())

		end
	},

	LoadActor("help popup")..{
		Condition=GAMESTATE:GetCurrentStageIndex()==0 and not GAMESTATE:IsAnyHumanPlayerUsingMemoryCard(),
		InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y)
	},
	
	Def.BitmapText {
		Font="_common white",
		OnCommand=cmd(shadowlength,0;zoom,.75;diffusealpha,0;finishtweening;
			x,SCREEN_CENTER_X;y,SCREEN_BOTTOM-12;settext,
			"&MENULEFT; Easier     &START; Change sort     &MENURIGHT; Harder"), --TODO L10n
		SelectMenuOpenedMessageCommand=cmd(stoptweening;linear,0.15;diffusealpha,1),
		SelectMenuClosedMessageCommand=cmd(stoptweening;linear,0.15;diffusealpha,0)
	}
}
