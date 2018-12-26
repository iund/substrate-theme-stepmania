--[[
	return Def.ActorFrame {
	Def.Actor {
		PollCommand=%function(s) InputTest.Poll(Env()._InputTestState.MK6InputState) end,
		OffCommand=%function(s) Env()._InputTestState=nil s:stopeffect() end,
		OnCommand=%function(s) Env()._InputTestState={} Env()._InputTestState.MK6InputState={} InputTest.Init(Env()._InputTestState.MK6InputState) if OPENITG and MK6_GetSensors and GetInputType()=="PIUIO" then s:luaeffect("Poll") end end,
		CaptureCommand=%Capture.ActorFrame.CaptureInternal,
	},
	Def.BitmapText {
		Font="_common semibold white",
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_TOP+24;shadowlength,0),
		Text="Input Test",
	},
	LoadActor("side")..{
		InitCommand=cmd(aux,1),
	},
	LoadActor("servicebuttons")..{
		InitCommand=cmd(aux,1),
		OnCommand=function(s) Capture.ActorFrame.ApplyPNToChildren(s,s:getaux()) Actor.xy(s,SCREEN_CENTER_X,SCREEN_CENTER_Y-128) end,
		Condition=OPENITG and GetInputType()~="PIUIO" and GAMESTATE:GetEnv("ServiceMenu"),
	},
	LoadActor("side")..{
		InitCommand=cmd(aux,2),
	},
	LoadActor("mk6servicebuttons")..{
		PollCommand=function(s) InputTest.Update.MK6ServiceButtons(s:getaux(),Env()._InputTestState.MK6ServiceButtons,Env()._InputTestState.MK6InputState) end,
		OffCommand=cmd(stopeffect),
		Condition=OPENITG and GetInputType()=="PIUIO" and GAMESTATE:GetEnv("ServiceMenu"),
		OnCommand=function(s) Env()._InputTestState.MK6ServiceButtons=InputTest.Capture.MK6ServiceButtons(s) Actor.xy(s,SCREEN_CENTER_X,SCREEN_CENTER_Y-128) end,
	},
}
local text
local textblink=function() text:UpdateDiffuseCos(.5) end
--]]
local padspacing=80
local buttonsy=SCREEN_CENTER_Y-140
local pady=SCREEN_CENTER_Y+140

return Def.ActorFrame {

	LoadActor("buttons")..{
		InitCommand=cmd(aux,1;x,SCREEN_CENTER_X-padspacing;y,buttonsy),
	},
	LoadActor("buttons")..{
		InitCommand=cmd(aux,2;x,SCREEN_CENTER_X+padspacing;y,buttonsy),
	},


	LoadActor("../../Graphics/_platform large")..{
		InitCommand=cmd(aux,1;x,SCREEN_CENTER_X-padspacing;y,pady),
	},
	LoadActor("../../Graphics/_platform large")..{
		InitCommand=cmd(aux,2;x,SCREEN_CENTER_X+padspacing;y,pady),
	},
}

