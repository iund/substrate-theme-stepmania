return Def.ActorFrame {
	LoadActor("bg")..{
		OnCommand=function(s) s:x(SCREEN_CENTER_X) s:y(SCREEN_CENTER_Y) end,
	},
	LoadActor("../../Graphics/_CustomDifficultyList")..{
		InitCommand=function(s) s:x(SCREEN_CENTER_X+320) s:y(SCREEN_TOP+32) CustomDifficultyList.Capture(s,1) CustomDifficultyList.Set(1) end,
		CurrentStepsP1ChangedMessageCommand=function(s) CustomDifficultyList.Set(1) end,
		CaptureCommand=function(self,param) Capture.ActorFrame.CaptureInternal(self,param) end,
	},
	Def.BitmapText {
		Font="_common white",
		GetCommand=function(s) local titles=Screens.Edit.InfoGetTitles(Screen():GetChild("Info")) s:settext(titles) if titles=="" then s:sleep(0.1) s:queuecommand("Get") end end,
		OnCommand=function(s) s:horizalign("right") s:zoom(15/20) s:vertalign("bottom") s:shadowlength(0) s:x(SCREEN_RIGHT-8) s:y(SCREEN_BOTTOM-8) s:queuecommand("Get") end,
	},
	Def.BitmapText {
		Font="_common white",
		GetCommand=function(s) s:settext(Screens.Edit.InfoGetValues(Screen():GetChild("Info"))) s:sleep(0.05) s:queuecommand("Get") end,
		OnCommand=function(s) s:horizalign("left") s:zoom(15/20) s:vertalign("bottom") s:shadowlength(0) s:x(SCREEN_CENTER_X+224) s:y(SCREEN_BOTTOM-8) s:queuecommand("Get") end,
	},
}