--[[Profileman:
		ADD_METHOD( GetWeightPounds )
		ADD_METHOD( SetWeightPounds )
		ADD_METHOD( GetGoalType )
		ADD_METHOD( SetGoalType )
		ADD_METHOD( GetGoalCalories )
		ADD_METHOD( SetGoalCalories )
		ADD_METHOD( GetGoalSeconds )
		ADD_METHOD( SetGoalSeconds )
		ADD_METHOD( GetCaloriesBurnedToday )

goaltypes:
	GOAL_CALORIES, 
	GOAL_TIME, 
	GOAL_NONE,
--]]

RowType.CaloriesBurnedInfo=function(name)
	local handler={ gettext=function(pn) return PROFILEMAN:GetProfile(pNum[pn]):GetCaloriesBurnedToday() or "" end }
	return RowType.Info(name,handler)
end

RowType.TotalSongsPlayedInfo=function(name)
	local handler={ gettext=function(pn) return PROFILEMAN:GetProfile(pNum[pn]):GetTotalNumSongsPlayed() or "" end }
	return RowType.Info(name,handler)
end

RowType.Weight=function(name,step,range)
        local handler = {
                get = function(r,pn)
			return PROFILEMAN:GetProfile(pNum[pn]):GetWeightPounds()
                end,
                set = function(r,pn,val)
			PROFILEMAN:GetProfile(pNum[pn]):SetWeightPounds(val)
                end,
                format = function(r,pn,val)
			return (val or 0).." lb"
                end,
        }
        return RowType.Slider(name,handler,step,range,false)
end

RowType.Color=function(name,list,mode,addOff) --same as EnvList but fires UIColorChangedPn
	--return single selection from table
	--mode: true = use names, false = use id
	local handler = {
		getchoices = function() return RowType.ListNames(list,Languages[CurLanguage()].Mods.Names[name]) end,
		get = function(r,pn)
			local out={}
			for i=1,table.getn(list) do out[i] = (mode and list[i] or i)==(GetProfile(pn)[name] or nil) end
			return out
		end,
		set = function(r,pn,i,flag)
			GetProfile(pn)[name] = flag and (mode and list[i] or i) or false
			if flag then Broadcast("UIColorChangedP"..tostring(pn)) end
		end
	}
	return RowType.ListBase(name,handler,false,addOff)
end
