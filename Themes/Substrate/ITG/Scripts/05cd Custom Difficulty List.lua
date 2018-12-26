CustomDifficultyList = {
	Capture = function(s,pn)
		local insert=table.insert
		local raw=Capture.ActorFrame.GetChildren(s)
		local rows={}
		local bar=raw.children[1].children and raw.children[1].children[1] or raw.children[1]
		local infotext=raw.children[table.getn(raw.children)].children[1]
		if raw.children[1].children then
			--itg
			for i=2,table.getn(raw.children)-1 do
				local child=raw.children[i].children[1]
				insert(rows,{
					self=child.self,
					meter=child.children[1].children[1],
					bar=child.children[2].children[1],
					description=child.children[3].children[1],
				})
			end
		else
			--sm5
			for i=2,table.getn(raw.children)-1 do
				local child=raw.children[i]
				insert(rows,{
					self=child.self,
					meter=child.children[1],
					bar=child.children[2],
					description=child.children[3],
				})
			end
		end
		DiffList=DiffList or {}
		DiffList[pn]={self=s,bar=bar,rows=rows,infotext=infotext}
	end,

	GetText = function(pn,rowdata,state)
		if not CurSong() then return "" end
		local dir=CurSong():GetSongDir()
		local diff=dText[rowdata:GetDifficulty()]+1
		local stype=StepsTypeString[stText[rowdata:GetStepsType()]+1]
		--printf("CustomDifficultyList.GetText(%s,%s,%d,%s,%d)",dir,stype,dText[diff]+1,DifficultyNames[dText[diff]+1],GetProfile(pn).MeasureType)
		local StreamCache=GetSysProfile().StreamCache
		return
			state==1 and Languages[CurLanguage()].Difficulty[DifficultyNames[diff]] --DifficultyToThemedString(diff)
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
			
--[[
			GetProfile(pn).MeasureType and 
				StreamCache[dir] and 
				StreamCache[dir][stype] and
				StreamCache[dir][stype][DifficultyNames[diff] ] and
				StreamCache[dir][stype][DifficultyNames[diff] ][GetProfile(pn).MeasureType] and
				StreamCache[dir][stype][DifficultyNames[diff] ][GetProfile(pn).MeasureType].breakdown
--]]

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
		--[[page order:
		
			0	bar
			1	difficulty name
			2	chart description
			3	measures:
					4
					8
					16
					32
			4	machine top score
			5	rival best
			6	best
			
			4,5,6 vary depending on sm features and usb present
		--]]
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
	end,
	
	SetDifficultyDisplay=function(pn,page)
		local env=GetProfile(pn)
	
	

		CustomDifficultyList.Set(pn)
	end,

	Set = function(pn)
		if not (DiffList and DiffList[pn] and DiffList[pn].bar) then return end --got a crash so plugging it up.
		local ceil=math.ceil
		local remove=table.remove
		local getn=table.getn
		local insert=table.insert
		local env=GetProfile(pn)
		local selectionbar=DiffList[pn].bar
		local currow=dText[CurDifficulty(pn)]
		local rows=DiffList[pn].rows
		for i,row in next,rows,nil do row.self:visible(Bool[false]) end --hide the existing rows

		if CurSong() and CurSteps(pn) then --On steps changed.
			local steps=CurSteps(pn)
			
			local stepslist=GetSortedStepsList(steps)
			DiffList[pn].steps=stepslist

			local firstrow=dText[stepslist[1]:GetDifficulty()]+1

			--initialise rows
			local outrows={}
			for i=1,math.min(getn(rows)-1,firstrow-1) do insert(outrows,line) end --move rows down: itg generally only allows 1 chart per difficulty (except edit); one safely assume each slot can only take 1 chart.

			-- make internal row table, to figure out where the bottom row is
			local lastrow=1
			local tmprows={}
			for i,line in next,stepslist,nil do --getn returns 0 on non-contiguously indexed tables
				local row=dText[line:GetDifficulty()]+1
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
				local textstate=env.StepsListPage
				row.self:visible(Bool[true])
				row.self:y(Metrics.SelectMusic.PaneDisplay.DifficultyList.SpacingY*(i-1))

				row.meter:settext(rowdata:GetMeter())

				row.bar:stoptweening() row.bar:linear(0.05) --TODO: move to Tweens.lua
				row.bar:zoomtowidth(textstate~=0 and 0 or rowdata:GetMeter()*Metrics.SelectMusic.PaneDisplay.DifficultyList.BarBlockWidth)
				--row.bar:visible(Bool[textstate==0])

				row.description:horizalign("left") row.description:zoom(15/20) --TODO: move to tweens
				row.description:settext(CustomDifficultyList.GetText(pn,rowdata,textstate))

				row.self:diffuse(unpack(difficultyColors[dText[rowdata:GetDifficulty()]]))
			end
			
			--Must match whatever GetText has.
			local state=env.StepsListPage
			DiffList[pn].infotext:settext(
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

		--TODO move to Tweens.lua
		selectionbar:stoptweening() selectionbar:decelerate(0.2)
		selectionbar:y(Metrics.SelectMusic.PaneDisplay.DifficultyList.SpacingY*(currow or 0)) --currow gets unset when you quit out of the editor
	end,
	
	Off = function(pn)
		DiffList[pn]=nil
	end,
}
