local CurGame=GAMESTATE:GetCurrentGame():GetName()

local panels={{},{}}

local hspacing=48
local vspacing=48
local vcornerspacing=48

local function panel(x,y,button) 
	local text
	return Def.ActorFrame{
		OnCommand=cmd(x,x;y,y),

		Def.BitmapText {
			Font="Common normal",
			InitCommand=cmd(zoom,2;zbias,1;zbuffer,1),
			OnCommand=function(s) text=s end,
			Text=string.format("&%s;",button),
		},
		Def.Quad{
			InitCommand=cmd(ztestmode,"writeonfail"),

			OnCommand=function(s)
				assert(within(s:getaux(),1,2))
				panels[s:getaux()][button]=s
				s:zoomto(text:GetZoomedWidth(),text:GetZoomedHeight())
			end
		}
	}
end

local function listener(attr)
	local button=attr.GameButton
	local pressed=attr.DeviceInput.down
	local pi=PlayerIndex[attr.PlayerNumber]

	if pi and panels[pi][button] then
		panels[pi][button]:visible(pressed)
	end
end

return Def.ActorFrame {
	OnCommand=function(s) 
		local pi=s:getaux()
		s:RunCommandsOnChildren(function(c) c:aux(pi) c:finishtweening() end)
		GetScreen():AddInputCallback(listener)
	end,
	OffCommand=function(s) GetScreen():RemoveInputCallback(listener) end,

	panel(0,-vspacing,"MenuUp"), --up
	panel(0,vspacing,"MenuDown"), --down
	panel(-hspacing,0,"MenuLeft"), --left
	panel(hspacing,0,"MenuRight"), --right

	panel(0,0,"Start"), --middle
}