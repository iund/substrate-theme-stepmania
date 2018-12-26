
--[[
	GetText = function(pn,rowdata,state)
		if not CurSong() then return "" end
		local dir=CurSong():GetSongDir()
		local diff=DifficultyIndex[rowdata:GetDifficulty()]+1
		local stype=StepsTypeString[stText[rowdata:GetStepsType()]+1]
		local StreamCache=GetSysProfile().StreamCache
		return
			state==1 and Languages[CurLanguage()].Difficulty[DifficultyNames[diff] ] --DifficultyToThemedString(diff)
			or state==2 and rowdata:GetDescription()
			or state==3 and (function(mt) if not mt then return "" else
				local diffstr=DifficultyNames[diff]
				local streamentry=StreamCache[dir] and 
					StreamCache[dir][stype] and
					StreamCache[dir][stype][diffstr] and
					StreamCache[dir][stype][diffstr][mt]
				
				local bd=streamentry and Stream.GetBreakdown(streamentry) or ""
				return bd
			end end)(GetProfile(pn).MeasureType)
			

--			GetProfile(pn).MeasureType and 
--				StreamCache[dir] and 
--				StreamCache[dir][stype] and
--				StreamCache[dir][stype][DifficultyNames[diff] ] and
--				StreamCache[dir][stype][DifficultyNames[diff] ][GetProfile(pn).MeasureType] and
--				StreamCache[dir][stype][DifficultyNames[diff] ][GetProfile(pn).MeasureType].breakdown

			or (state==6 or state==4 and not UsingUSB(pn)) and (function(rd)
				local h=PROFILEMAN:GetMachineProfile():GetStepsHighScoreList(CurSong(),rd)
				if h then local hsl=h:GetHighScores()
					if table.getn(hsl)==0 then return "" else
						return hsl[1]:GetName().." "..FormatPercentScore(hsl[1]:GetPercentDP())
					end
				else
					return ""
				end
			end)(rowdata)

			or state==4 and UsingUSB(pn) and (Rival.GetScore(pn,rowdata) or "no data")
			or state==5 and UsingUSB(pn) and (Rival.GetScoreSelf(pn,rowdata) or "no data")
			
--			or state==6 and Steps.GetRadarValues and (function() local out={} for i=5,10 do out[i]=rowdata:GetRadarValues():GetValue(i) end return join(",",out) end)()
			or ""
	end,
	CycleDifficultyDisplay = function(pn,dir) --cycles between bar, difficulty name, chart description, steps (oITG+) via pad code.
		--page order:
		--
		--	0	bar
		--	1	difficulty name
		--	2	chart description
		--	3	measures:
		--			4
		--			8
		--			16
		--			32
		--	4	machine top score
		--	5	rival best
		--	6	best
		--	
		--	4,5,6 vary depending on sm features and usb present

		local env=GetProfile(pn)
		local max=(Profile.GetStepsHighScoreList and 1 or 0)+(UsingUSB(pn) and GetSysProfile("Rivals") and 6 or 4) --Steps.GetRadarValues and 7 or 6
		
		if env.StepsListPage==3 and env.MeasureType and
		(dir>0 and env.MeasureType~=MeasureTypes[table.getn(MeasureTypes)] or
		dir<0 and env.MeasureType~=MeasureTypes[1]) then
			local i=table.findkey(MeasureTypes,env.MeasureType)
			env.MeasureType=MeasureTypes[i+dir]
			--cycle through measure counter types
		else
			env.StepsListPage=math.mod(env.StepsListPage+dir+max,max)
			if env.StepsListPage==3 then
				--if not env.MeasureType then env.StepsListPage=1 else
				env.MeasureType=
					dir<0 and MeasureTypes[table.getn(MeasureTypes)] or
					dir>0 and MeasureTypes[1]
					or false
				--end
			else
				env.MeasureType=false
			end
		end
		CustomDifficultyList.Set(pn)
	end
--]]

--objects:
local rows={}
local rowdata={}

local selectionbar
local infotext

--metrics:

--[[ with style icon (wide)
local spacingy=28
local meterx=-92
local barx=-74
local barblockwidth=8 --enough space for up to 18
local descriptionx=-74
local descriptionmaxwidth=192
local debugx=-74
local styleiconx=92
local infotexty=136
--]]

local numrows=5

-- [[ --original w/o style icon
local spacingy=28
local meterx=-80
local barx=-56
local barblockwidth=8
local descriptionx=-56
local descriptionmaxwidth=192
local infotexty=136
--]]

local function set(pn)
	local ceil=math.ceil
	local remove=table.remove
	local getn=table.getn
	local insert=table.insert
	local env={}--GetProfile(pn)

	local currow=DifficultyIndex[GetCurDifficulty(pn) or GAMESTATE:GetPreferredDifficulty(pn)]
	for i,row in next,rows,nil do row.self:visible(false) end --hide the existing rows

	if GetCurSong() and GetCurSteps(pn) then --On steps changed.
		local steps=GetCurSteps(pn)
		
		local stepslist=SongUtil.GetPlayableSteps(GetCurSong()) or {}
--		local stepslist=SortStepsList(SongUtil.GetPlayableSteps(GetCurSong())) or {}
--		local stepslist=GetSortedStepsList(steps)
		rowdata=stepslist

		local firstrow=DifficultyIndex[stepslist[1]:GetDifficulty()]+1

		--initialise rows
		local outrows={}
		for i=1,math.min(getn(rows)-1,firstrow-1) do insert(outrows,line) end --move rows down: itg generally only allows 1 chart per difficulty (except edit); one safely assume each slot can only take 1 chart.

		-- make internal row table, to figure out where the bottom row is
		local lastrow=1
		local tmprows={}
		for i,line in next,stepslist,nil do --getn returns 0 on non-contiguously indexed tables
			local row=DifficultyIndex[line:GetDifficulty()]+1
			while tmprows[row] do row=row+1 end
			tmprows[row]=line
			lastrow=row
		end
		
		--find row with current steps
		for i,row in next,tmprows,nil do if row==steps then currow=i end end

		local shiftuprows=clamp(currow-ceil(getn(rows)/2),0,lastrow-getn(rows))

		--prepare an output table, keep the highlighted row towards the middle 
		for r,row in next,tmprows,nil do
			local i=r-shiftuprows
			if i>0 and i<=getn(rows) then --keep within bounds
				outrows[i]=row
			end
		end

		--populate
		for i,rowdata in next,outrows,nil do
			if rowdata==steps then currow=i-1 end --highlight the correct row; there can be multiple charts in the Edit slot
			local row=rows[i]
			local textstate=0 --env.StepsListPage
			row.self:visible(true)
			row.self:y(spacingy*(i-1))

			row.meter:settext(rowdata:GetMeter())

			row.bar:playcommand("Resize")
			row.bar:zoomtowidth(textstate~=0 and 0 or rowdata:GetMeter()*barblockwidth)

--			row.description:settext(CustomDifficultyList.GetText(pn,rowdata,textstate))

			row.self:diffuse(unpack(DifficultyColors[rowdata:GetDifficulty()]))

			--debug:
--			row.bar:visible(false)
--			row.description:settext("Description Description")
--			row.debug:settext(tostring(rowdata:GetStepsType()))
		end
		
		--Must match whatever GetText has.
		local state=env.StepsListPage
		infotext:settext(
			state==1 and "Difficulty"
			or state==2 and "Chart Description"
			or state==3 and (env.MeasureType and ordinal(env.MeasureType) or "").." Streams"
			or (state==6 or state==4 and not UsingUSB(pn)) and "Machine Top Score"
			or state==4 and UsingUSB(pn) and (CurRival[pn] and CurRival[pn].Name or "Rival").."'s Best"
			or state==5 and UsingUSB(pn) and "My Best"
			or ""
		)
--[[
		DiffList[pn].infotext:settext(({
			"Difficulty",
			"Chart Description",
			(env.MeasureType and ordinal(env.MeasureType) or "").." Streams",
			(CurRival[pn] and CurRival[pn].Name or "Rival").."'s Best",
			"Best",
			"Steps",
		})[env.StepsListPage] or "")
--]]
	end

	selectionbar:stoptweening() selectionbar:decelerate(0.2)
	selectionbar:y(spacingy*(currow or 0))
end

local out=Def.ActorFrame {

	CurrentSongChangedMessageCommand=function(s) if not GetCurSong() then set(pn==1 and PLAYER_1 or PLAYER_2) end end,
	CurrentStepsP1ChangedMessageCommand=function(s) if s:getaux()==1 and selectionbar then set(PLAYER_1) end end,
	CurrentStepsP2ChangedMessageCommand=function(s) if s:getaux()==2 and selectionbar then set(PLAYER_2) end end,

	--PreferredDifficultyP1ChangedMessageCommand=function(s) if s:getaux()==1 and selectionbar then set(PLAYER_1) end end,
	--PreferredDifficultyP2ChangedMessageCommand=function(s) if s:getaux()==2 and selectionbar then set(PLAYER_2) end end,

	Def.Sprite { --Selection bar
		Texture="highlight",
		InitCommand=function(s) selectionbar=s end,
		MoveCommand=cmd(stoptweening;decelerate,0.2)
	},
	Def.BitmapText { --Bottom legend
		Font="DifficultyMeter meter",
		InitCommand=function(s) infotext=s end,
		OnCommand=cmd(y,infotexty;zoom,.75)
	}
}

for i=1,numrows do
	rows[i]={}
	out[#out+1]=Def.ActorFrame {
		InitCommand=function(s) rows[i].self=s end,
		Def.BitmapText {
			InitCommand=function(s) rows[i].meter=s end,
			OnCommand=cmd(x,meterx;shadowlength,0),
			Font="DifficultyMeter meter",
		},
		Def.Quad {
			InitCommand=function(s) rows[i].bar=s end,
			OnCommand=cmd(x,barx;horizalign,"left";zoomtoheight,16),
			ResizeCommand=cmd(stoptweening;linear,0.05)
		},
		Def.BitmapText {
			InitCommand=function(s) rows[i].description=s end,
			OnCommand=cmd(x,descriptionx;shadowlength,0;horizalign,"left";zoom,0.75;maxwidth,descriptionmaxwidth),
			Font="DifficultyMeter meter",
		},

		--Debug:
--[[
		Def.BitmapText {
			InitCommand=function(s) rows[i].debug=s end,
			OnCommand=cmd(x,debugx;shadowlength,0;horizalign,"left";zoom,0.75;maxwidth,descriptionmaxwidth),
			Font="_common white",
		},
		
		Def.Quad { --TODO: Put style icon here. Quad is a placeholder to get positioning figured out
			InitCommand=function(s) rows[i].debugquad=s end,
			OnCommand=cmd(x,styleiconx;zoomto,32,16),
		}
--]]
	}
end

return out