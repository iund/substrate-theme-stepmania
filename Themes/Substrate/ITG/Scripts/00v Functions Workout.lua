function GetRandomSongAndStepsByMeter(min,max)
	local stepstype=GetStepsType()

	local song
	local steps
	
	local i=table.getn(SONGMAN:GetAllSongs()) --prevent infinite loop if theres no song with charts within the difficulty range

	repeat
		song=SONGMAN:GetRandomSong()
	
		for _,s in next,song:GetStepsByStepsType(stepstype),nil do
			if within(s:GetMeter(),min,max) then
				steps=s
			end
		end
		i=i-1
	until steps and within(steps:GetMeter(),min,max) or i<=0

	return song,steps
end

Goal={
	GetSeconds=function(pn)
		local p=pNum[pn]
		return STATSMAN:GetAccumStageStats():GetGameplaySeconds()+STATSMAN:GetCurStageStats():GetGameplaySeconds()
	end,
	GetCalories=function(pn)
			local p=pNum[pn]
		return STATSMAN:GetAccumStageStats():GetPlayerStageStats(p):GetCaloriesBurned()+STATSMAN:GetCurStageStats():GetPlayerStageStats(p):GetCaloriesBurned()
	end,
	GetPercent=function(pn)
		return PROFILEMAN:GetProfile(pNum[pn]):GetGoalType()==GOAL_TIME and Goal.GetPercentSeconds(pn)
			or PROFILEMAN:GetProfile(pNum[pn]):GetGoalType()==GOAL_CALORIES and Goal.GetPercentCalories(pn)
			or 0
	end,
	GetPercentSeconds=function(pn)
		local p=pNum[pn]
		local actual=STATSMAN:GetAccumStageStats():GetPlayerStageStats(p):GetCaloriesBurned()+STATSMAN:GetCurStageStats():GetPlayerStageStats(p):GetCaloriesBurned()
		local goal=PROFILEMAN:GetProfile(p):GetGoalCalories()
		return goal>0 and actual/goal or 0
	end,
	GetPercentCalories=function(pn)
		local p=pNum[pn]
		local actual=STATSMAN:GetAccumStageStats():GetGameplaySeconds()+STATSMAN:GetCurStageStats():GetGameplaySeconds()
		local goal=PROFILEMAN:GetProfile(p):GetGoalSeconds()
		return goal>0 and actual/goal or 0
	end,
}
