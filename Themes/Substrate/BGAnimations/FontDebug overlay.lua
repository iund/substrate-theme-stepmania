local fontname="_common white"

local grid=Def.ActorFrame{}

local gridwidth=12
local gridspacing=32
for i=32,127 do
		local box
		local text

		local x=math.mod(i-8,gridwidth)*gridspacing-(gridwidth*gridspacing/2)
		local y=math.floor((i-8)/gridwidth)*gridspacing-(gridwidth*gridspacing/2)

		local letter=string.char(i)
		grid[i-31]=Def.ActorFrame{
			InitCommand=cmd(x,x;y,y),
			OnCommand=function(s)
				box:zoomto(text:GetZoomedWidth(),text:GetZoomedHeight())
			end,
			Def.Quad {
				InitCommand=function(s) box=s s:diffuse(0,1,1,.5) end,
			},
			Def.BitmapText{
				Font=fontname,
				Text=letter,
				InitCommand=function(s) text=s end,
			}
		}
end
local box
return Def.ActorFrame{
	OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y),
	Def.ActorFrame{
		InitCommand=cmd(y,-SCREEN_HEIGHT/2+48),
		Def.Quad {
			InitCommand=function(s) box=s s:diffuse(0,1,1,.5) end,
		},
		Def.BitmapText{
			Font=fontname,
			InitCommand=cmd(zoom,4),
			OnCommand=function(s)
				box:zoomto(s:GetZoomedWidth(),s:GetZoomedHeight())
			end,
			Text="HaH",
		}
	},
	--grid,
	-- [[
	Def.BitmapText{
		Font=fontname,
		OnCommand=cmd(zoom,1),


		Text="HAHBHCHDHEHFHGHHIHJHKHLHMH\n"..
		     "HNHOHPHQHRHSHTHUHVHWHXHYHZH\n"..
			 "HaHbHcHdHeHfHgHhHiHjHkHlHmH\n"..
			 "HnHoHpHqHrHsHtHuHvHwHxHyHzH\n"..
			 "GOQOGOSOHSOVOKVMOCOB\n"..
			 "oceanaceous oboe him xex ixi\n"..
			 "difficulty little beijing gj Canoe Way"

			"Press Player Hillbilly Walking\n"..
			"VerTex Fantastic!"

--[[
	
	letter shape alys


--round/straight left
		BDPRbhp
--round/straight right
		Jadgjq
--round
		CGOQSceos
--straight left+right
		HIMNUimnu
--straight left
		EFKLklr
--straight right
	
--straight middle
		Tft
--angled
		AVWXYZvwxyz

--]]
-- round to round letters
--[[	Text="oceanaceous \n"..

-- round/straight letters

	"HONOUR OF GENOA honourable spicy\n"..
	"porridge Henley Disconnected\n"..

-- round/angled letters

	"Ways in Wyoming Aesop Xanax Yaw Valley Vying Zoo\n"..

-- straight to straight letters

	"Hilly Milly\n"..

-- round to straight letters
-- angled letters

	"Why Willi$ Yvette Ren Rin\n"
--]]

--[[
			Text="The quick brown fox jumps over the lazy dog\n"..
			 "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG\n"..
			 "0123456789 $123.45 99.97% #kerning\n"..
			 "Jump! \"Hanoi\" ROM-eo & Juli8 (derp derp)\n"..
			 "Overhead, cel, N/A ~speedy mix~ ?The Riddle?\n"..
			 "VerTex² [brackets] {brackets} V^3 C:\\derp\n"..
			 "foo=bar M<N N>M today; derp: M+M MSM Mj qj fi fl MwM\n"..
			 "Beijing Waiter Dixie HRM Why Me Little Wit\n"..
			 "David'll\n"..


			 "iljtfr fa stiffing WAVES HAVANA PLYWOODBD"
--]]
	}
	--]]
}