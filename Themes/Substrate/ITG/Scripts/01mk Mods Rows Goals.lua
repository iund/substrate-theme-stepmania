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

RowType.GoalType=function(name,updaterow)
	local list={"Calories","Time","Off"}
	local handler = {
		getchoices = function() return RowType.ListNames(list,Languages[CurLanguage()].Mods.Names.SpeedModType) end,
		get = function(r,pn)
			local type_=PROFILEMAN:GetProfile(pNum[pn]):GetGoalType()+1
			local out={}
			for i=1,table.getn(list) do out[i] = type_==i end
			return out,type_
		end,
		set = function(r,pn,i,flag)
			if pn~=0 then
				if flag then PROFILEMAN:GetProfile(pNum[pn]):SetGoalType(i-1) end
				if updaterow then ModsMenu.UpdateInfoLine(r,pn,updaterow) end
			end
		end
	}
	local r=RowType.ListBase(name,handler,false)
	r.handler=handler
	return r
end

RowType.GoalNumber=function(name,step,range,simple,updaterow)
	local handler = {
		get = function(r,pn)
			local profile=PROFILEMAN:GetProfile(pNum[pn])
			local type_=profile:GetGoalType()
			return type_==GOAL_CALORIES and profile:GetGoalCalories()
				or type_==GOAL_TIME and profile:GetGoalSeconds()
				or 0
		end,
		set = function(r,pn,val)
			local profile=PROFILEMAN:GetProfile(pNum[pn])
			local type_=profile:GetGoalType()
			if type_==GOAL_CALORIES then profile:SetGoalCalories(val)
				elseif type_==GOAL_TIME then profile:SetGoalSeconds(val)
			end
			if pn~=0 and updaterow then ModsMenu.UpdateInfoLine(r,pn,updaterow) end
		end,
		format = function(r,pn,val)
			local type_=PROFILEMAN:GetProfile(pNum[pn]):GetGoalType()

			return type_==GOAL_CALORIES and val.." cals"
				or type_==GOAL_TIME and SecondsToMSS(val)
				or "-"
		end,
	}
	return RowType.Slider(name,handler,step,range,false)
end
