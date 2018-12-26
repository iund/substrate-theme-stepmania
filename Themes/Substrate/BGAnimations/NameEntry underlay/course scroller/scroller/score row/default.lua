return Def.ActorFrame {
	Def.Quad {
		OnCommand=function(s) s:visible(Bool[false]) Screen():aux(math.mod(Screen():getaux(),4)+1) end,
	},
	LoadActor("p1 frame")..{
		OnCommand=function(s) s:horizalign("right") end,
		Condition=Player(1),
	},
	LoadActor("player")..{
		OnCommand=function(s) Capture.ActorFrame.ApplyPNToChildren(s,1) end,
		Condition=Player(1),
		CaptureCommand=function(self,param) Capture.ActorFrame.CaptureInternal(self,param) end,
	},
	LoadActor("p2 frame")..{
		OnCommand=function(s) s:horizalign("left") end,
		Condition=Player(2),
	},
	LoadActor("player")..{
		OnCommand=function(s) Capture.ActorFrame.ApplyPNToChildren(s,2) end,
		Condition=Player(2),
		CaptureCommand=function(self,param) Capture.ActorFrame.CaptureInternal(self,param) end,
	},
	LoadActor("banner frame")..{
	},
	Def.Sprite {
		OnCommand=function(s) s:Load(Scores[Screen():getaux()].Song:GetBannerPath()) s:scaletoclipped(192,75) end,
	},
	Def.BitmapText {
		Font="_common white",
		TextCommand=function(s) s:settext(GetSongName(Scores[Screen():getaux()].Song)) end,
		OnCommand=function(s) s:y(-46) s:shadowlength(0) s:zoom(10/20) s:playcommand("Text") end,
	},
	Def.BitmapText {
		Font="_common white",
		TextCommand=function(s) s:settext(GetBPMString(GetEnv("Rate") or 1,Scores[Screen():getaux()].BPM).." bpm") end,
		OnCommand=function(s) s:y(46) s:shadowlength(0) s:zoom(10/20) s:playcommand("Text") end,
	},
}