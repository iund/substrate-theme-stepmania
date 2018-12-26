return Def.ActorFrame {
	OnCommand=cmd(RunCommandsOnChildren,function(c) c:aux(self:getaux()) end),
	LoadActor(THEME:GetPathB(THEME:GetMetric("Menu","Fallback"),"overlay")),

	--style icon:
	Def.Sprite {
		Condition=GAMESTATE:GetCurrentStyle() and not THEME:GetMetric("Common","AutoSetStyle"),
		Texture=GAMESTATE:GetCurrentStyle() and 
		THEME:GetPathG("MenuElements icon",GAMESTATE:GetCurrentStyle():GetName()) or "",
		InitCommand=cmd(x,SCREEN_LEFT+28;y,SCREEN_TOP+12),
		PlayerJoinedMessageCommand=cmd(Load,"MenuElements icon "..GAMESTATE:GetCurrentStyle():GetName())
	},

	--stage:
	Def.BitmapText {
		Font="_common semibold white",
		InitCommand=cmd(vertalign,"top";x,SCREEN_CENTER_X;y,SCREEN_TOP+4;zoom,0.75),
		OnCommand=cmd(settext,GetStageText(self:getaux())),
		CurrentSongChangedMessageCommand=cmd(settext,GetStageText()),
		CurrentCourseChangedMessageCommand=cmd(settext,GetStageText()),
	}
}
