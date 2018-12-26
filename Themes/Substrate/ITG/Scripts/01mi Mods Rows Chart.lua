--------------------------------
-- Chart picker mods lines
--------------------------------

RowType.Steps=function(name,updaterow)
	local handler = {
		--getchoices = function() local out={} for i,step in next,GetSortedStepsList(),nil do out[i]=Languages[CurLanguage()].Difficulty[DifficultyNames[dText[step:GetDifficulty()]+1]] end return out end,
		getchoices = function() local out={} for i,step in next,GetSortedStepsList(),nil do out[i]=sprintf("%s (%d)", Languages[CurLanguage()].Difficulty[DifficultyNames[dText[step:GetDifficulty()]+1]], step:GetMeter()) end return out end,
		get = function(r,pn) local out={} for i,step in next,GetSortedStepsList(),nil do out[i]=step==CurSteps(pn) end if not CurSteps(pn) then out[1]=true end return out end,
		set = function(r,pn,i,flag) if flag then GAMESTATE:SetCurrentSteps(pNum[pn],GetSortedStepsList()[i])
			if Steps.GetRadarValues and stepsStats[pn] then
				local rv=Steps.GetRadarValues and (IsCourseMode() and CurTrail(pn) or CurSteps(pn)):GetRadarValues()
				stepsStats[pn].MaxDP=rv and
					--get step counts directly instead of reading Panedisplay
					(rv:GetValue(RADAR_CATEGORY_TAPS)*GetPref("PercentScoreWeight"..JudgeNames[1])+
					(rv:GetValue(RADAR_CATEGORY_HOLDS)+rv:GetValue(RADAR_CATEGORY_ROLLS))*GetPref("PercentScoreWeight"..JudgeNames[7])
					)
			end
			if pn~=0 and updaterow then ModsMenu.UpdateInfoLine(r,pn,updaterow) end
		end end
	}
	local r=RowType.ListBase(name,handler,false,false,false)
	if not (Steps.GetRadarValues and stepsStats[pn]) then r.EnabledForPlayers={} end --Grey out the row if the only place to get chart stats is PaneDisplay in SSM (ie, plain 3.95)
	return r
end

RowType.ChartDescription=function(name)
	local handler={ gettext=function(pn) return CurSteps(pn) and CurSteps(pn):GetDescription() or "" end }
	return RowType.Info(name,handler)
end

RowType.Breakdown=function(name,updaterow)
	local handler = {
		getchoices = function()
			local out={}
			for i,m in next,MeasureTypes,nil do out[i]=IsNumber(m) and ordinal(m).."s" or m end --"8ths" "16ths" "32nds" etc	
			return out
		end, --return MeasureTypes end,		
		get = function(r,pn) local mt=table.findkey(MeasureTypes,GetProfile(pn).MeasureType) local out={} for i=1,table.getn(MeasureTypes) do out[i]=i==mt end return out end,
		set = function(r,pn,i,flag) GetProfile(pn).MeasureType=flag and MeasureTypes[i] or false if updaterow then ModsMenu.UpdateInfoLine(r,pn,updaterow) end end
	}
	local r=RowType.ListBase(name,handler,false,true,false)
	return r
end

RowType.BreakdownInfo=function(name)
	local handler={
		gettext=function(pn)
			if not CurSong() then return "" end
			local StreamCache=GetSysProfile().StreamCache
			local dir=CurSong():GetSongDir()
			local stype=StepsTypeString[stText[GetStepsType()]+1]
			local diff=DifficultyNames[dText[CurSteps(pn):GetDifficulty()]+1]
			local mt=GetProfile(pn).MeasureType
			return StreamCache[dir] and StreamCache[dir][stype] and StreamCache[dir][stype][diff] and StreamCache[dir][stype][diff][mt] and Stream.GetBreakdown(StreamCache[dir][stype][diff][mt]) or "no data"
		end
	}
	return RowType.Info(name,handler)
end

-- Course:

RowType.TrailInfo=function(name)
	local handler={
		gettext=function(pn)
			return Languages[CurLanguage()].CourseDifficultyNames[CurTrail(pn):GetDifficulty()]
		end
	}
	return RowType.Info(name,handler)
end


RowType.Trail=function(name,updaterow)
	--this crashes (GameCommand::ApplySelf bitches when trying to change trail by itself); help?
	local handler = {
		getchoices = function()
			local out={}
			for i,trail in next,SelectableCourseDifficulties,nil do out[i]=Languages[CurLanguage()].CourseDifficultyNames[i+1] end
			return out
		end,
		get = function(r,pn)
			local out={}
			local flag=false
			local diffnums=table.invert(CourseDifficultyNames)
			for i,diff in next,SelectableCourseDifficulties,nil do out[i]=CurTrail(pn):GetDifficulty()==(diffnums[diff]-1) flag=true end
			assert(flag,sprintf("RowType.Trail() couldn't find a trail pn=%d traildiff=%d",pn,CurTrail(pn):GetDifficulty()))
			return out
		end,
		set = function(r,pn,i,flag)
			if flag and pn~=0 then
				local gc="style,"..CurStyleName()..";trail,"..SelectableCourseDifficulties[i]
--				GameCommand(gc,pn)
			end
		end
	}
	local r=RowType.ListBase(name,handler,false,false,false)
	if not Steps.GetRadarValues then r.EnabledForPlayers={} end --for whatever reason, this isn't changing course difficulty. Grey out for now.
	return r
end
