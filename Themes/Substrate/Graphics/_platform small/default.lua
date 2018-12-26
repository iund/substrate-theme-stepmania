local CurGame=GAMESTATE:GetCurrentGame():GetName()

local panels={{},{}}

local hspacing=32
local vspacing=32
local vcornerspacing=CurGame=="pump" and 28 or 32

local pad=1

local function panel(x,y,button) 
	return Def.Sprite {
		OnCommand=function(s) panels[s:getaux()][button]=s s:x(x) s:y(y) s:visible(false) end,
		Texture=CurGame.."/highlight",
	}
end

local function cornerpanel(x,y,button) 
	return Def.Sprite {
		OnCommand=function(s) panels[s:getaux()][button]=s s:x(x) s:y(y) s:visible(false) end,
		Texture=CurGame=="pump" and "pump/cornerhighlight" or CurGame.."/highlight",
	}
end

local function listener(attr)
	local button=attr.button
	local pressed=attr.DeviceInput.down
	local pi=PlayerIndex[attr.PlayerNumber]
	if pi and panels[pi][button] then panels[pi][button]:visible(pressed) end
end

return Def.ActorFrame {
	OnCommand=function(s) 
		local pi=s:getaux()
		s:RunCommandsOnChildren(function(c) c:aux(pi) c:finishtweening() end)
		GetScreen():AddInputCallback(listener)
	end,
	OffCommand=function(s) GetScreen():RemoveInputCallback(listener) end,

	PanelsHideCommand=function(s) for i,p in next,panels[s:getaux()],nil do p:stoptweening() p:decelerate(0.3) p:diffusealpha(0) end end,
	PanelsHideDelayedCommand=function(s) for i,p in next,panels[s:getaux()],nil do p:stoptweening() p:decelerate(0.3) p:diffusealpha(0) end end,
	PanelsShowCommand=function(s) for i,p in next,panels[s:getaux()],nil do p:stoptweening() p:accelerate(0.3) p:diffusealpha(1) end end,
	PanelsShowDelayedCommand=function(s) for i,p in next,panels[s:getaux()],nil do p:stoptweening() p:sleep(0.3) p:accelerate(0.3) p:diffusealpha(1) end end,

	PadFadeInDelayedCommand=function(s) pad:stoptweening() pad:sleep(0.3) pad:decelerate(0.3) pad:diffusealpha(1) end,
	PadFadeOutDelayedCommand=function(s) pad:stoptweening() pad:sleep(0.3) pad:accelerate(0.3) pad:diffusealpha(0) end,
	PadFadeOutCommand=function(s) pad:stoptweening() pad:accelerate(0.3) pad:diffusealpha(0) end,
	PadFadeInCommand=function(s) pad:stoptweening() pad:decelerate(0.3) pad:diffusealpha(1) end,

	Def.Sprite {
		InitCommand=function(s) pad=s end,
		Texture=CurGame.."/pad",
		PlayerEntrySetActiveColourCommand=cmd(diffusecolor,unpack(UIColors["PlayerEntryPanePlatformActive"])),
	},

	panel(0,-vspacing,"Up"), --up
	panel(0,vspacing,"Down"), --down
	panel(-hspacing,0,"Left"), --left
	panel(hspacing,0,"Right"), --right

	cornerpanel(-hspacing,-vcornerspacing,"UpLeft"), --upleft
	cornerpanel(hspacing,-vcornerspacing,"UpRight"), --upright
	cornerpanel(-hspacing,vcornerspacing,"DownLeft"), --downleft
	cornerpanel(hspacing,vcornerspacing,"DownRight"), --downright

	panel(0,0,"Center"), --middle
}