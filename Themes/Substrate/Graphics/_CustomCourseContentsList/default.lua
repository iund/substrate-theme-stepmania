--metrics:
local numrows=7

local spacingy=24
local meterx=-80
local titlex=-56
local titlemaxwidth=192

local rows={}

local function set(pn)
	if GetCurTrail(pn) then

		--Populate list
		local te=GetCurTrail(pn):GetTrailEntries()
		for i,row in next,rows,nil do
			row.self:visible(not not te[i])
			row.self:y(spacingy*(i-1))
			if te[i] then
				row.meter:settext(te[i]:GetSteps():GetMeter())
				row.title:settext(te[i]:GetSong():GetDisplayFullTitle())
				row.meter:diffusecolor(unpack(DifficultyColors[GetCurTrail(pn):GetDifficulty()]))
			end
		end
	end
end

local out=Def.ActorFrame {
	CurrentTrailP1ChangedMessageCommand=function(s) set(PLAYER_1) end,
	CurrentTrailP2ChangedMessageCommand=function(s) set(PLAYER_2) end,
}

for i=1,numrows do
	rows[i]={}
	out[#out+1]=Def.ActorFrame {
		InitCommand=function(s) rows[i].self=s end,
		Def.BitmapText {
			InitCommand=function(s) rows[i].meter=s end,
			OnCommand=cmd(x,meterx),
			Font="DifficultyMeter meter",
		},
		Def.BitmapText {
			InitCommand=function(s) rows[i].title=s end,
			OnCommand=cmd(x,titlex;horizalign,"left";zoom,0.75;maxwidth,titlemaxwidth),
			Font="DifficultyMeter meter",
		}
	}
end

return out