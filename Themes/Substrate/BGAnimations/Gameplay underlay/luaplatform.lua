--NOTE: Another lazy conversion. Sorry!!

--[[
	
	This is a pad guide for novice difficulty
	
	Outlines = player's input
	Panel flash = stepchart

]]

local CurGame=GAMESTATE:GetCurrentGame():GetName()

local panels={{},{}}
local outlines={{},{}}

local hspacing=48
local vspacing=48
local vcornerspacing=CurGame=="pump" and 42 or 48

local pad=1

local function flash(s) s:stoptweening() s:diffusealpha(1) s:accelerate(.5) s:diffusealpha(0) end

local function panel(x,y,button) 
	return Def.Sprite {
		OnCommand=function(s) panels[s:getaux()][button]=s s:x(x) s:y(y) s:diffusealpha(0) end,
		Texture=THEME:GetPathG("","_platform large/"..CurGame.."/highlight"),
		NoteCrossedMessageCommand=function(s,p) if p.ButtonName==button and (not p.PlayerNumber or p.PlayerNumber==PlayerIndex[s:getaux()]) then flash(s) end end,
	}
end

local function outline(x,y,button) 
	return Def.Sprite {
		OnCommand=function(s) outlines[s:getaux()][button]=s s:x(x) s:y(y) s:visible(false) end,
		Texture="platform/"..CurGame.."/outline",
	}
end

local function cornerpanel(x,y,button) 
	return Def.Sprite {
		OnCommand=function(s) panels[s:getaux()][button]=s s:x(x) s:y(y) s:diffusealpha(0) end,
		Texture=THEME:GetPathG("","_platform large/"..(CurGame=="pump" and "pump/cornerhighlight" or CurGame.."/highlight")),
		NoteCrossedMessageCommand=function(s,p) if p.ButtonName==button and (not p.PlayerNumber or p.PlayerNumber==PlayerIndex[s:getaux()]) then flash(s) end end,
	}
end

local function corneroutline(x,y,button) 
	return Def.Sprite {
		OnCommand=function(s) outlines[s:getaux()][button]=s s:x(x) s:y(y) s:visible(false) end,
		Texture="platform/"..(CurGame=="pump" and "pump/corneroutline" or CurGame.."/outline")
	}
end

local function listener(attr)
	local button=attr.button
	local pressed=attr.DeviceInput.down
	local pi=PlayerIndex[attr.PlayerNumber]
	if pi and outlines[pi][button] then outlines[pi][button]:visible(pressed) end
end

return Def.ActorFrame {
	OnCommand=function(s) 
		local pi=s:getaux()
		s:RunCommandsOnChildren(function(c) c:aux(pi) c:finishtweening() end)

		s:xy(PlayerX(pi),SCREEN_CENTER_Y+128)
		if not GAMESTATE:IsDemonstration() then
			GetScreen():AddInputCallback(listener)
		end
	end,
	OffCommand=function(s)
		if not GAMESTATE:IsDemonstration() then
			GetScreen():RemoveInputCallback(listener)
		end
	end,

	Def.Sprite {
		InitCommand=function(s) pad=s end,
		Texture="../../Graphics/_platform large/"..CurGame.."/pad",
		OnCommand=cmd(diffusealpha,0.8) --TODO: UIColors
	},

	panel(0,-vspacing,"Up"),
	panel(0,vspacing,"Down"),
	panel(-hspacing,0,"Left"),
	panel(hspacing,0,"Right"),
	cornerpanel(-hspacing,-vcornerspacing,"UpLeft"),
	cornerpanel(hspacing,-vcornerspacing,"UpRight"),
	cornerpanel(-hspacing,vcornerspacing,"DownLeft"),
	cornerpanel(hspacing,vcornerspacing,"DownRight"),
	panel(0,0,"Center"),

	outline(0,-vspacing,"Up"),
	outline(0,vspacing,"Down"),
	outline(-hspacing,0,"Left"),
	outline(hspacing,0,"Right"),
	corneroutline(-hspacing,-vcornerspacing,"UpLeft"),
	corneroutline(hspacing,-vcornerspacing,"UpRight"),
	corneroutline(-hspacing,vcornerspacing,"DownLeft"),
	corneroutline(hspacing,vcornerspacing,"DownRight"),
	outline(0,0,"Center")
}
