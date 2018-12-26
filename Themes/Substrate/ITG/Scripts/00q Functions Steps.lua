---Steps
function GetStepsType() return StepsType[table.findkey(GameNames,CurGame)][CurStyleName()] end
function GetStepsTypeString() return StepsTypeString[GetStepsType()+1] end
function GetStepsList(pn) return CurSong() and CurSong():GetStepsByStepsType(GetStepsType()) or nil end --function GetStepsList(pn) return CurSong() and CurSteps(pn) and CurSong():GetStepsByStepsType(CurSteps(pn):GetStepsType()) or nil end
function GetSortedStepsList(steps) --Replicate StepsUtil::SortNotesArrayByDifficulty() to match the sort
	--we have to sort it because GetStepsByStepsType and co returns it in whatever order the charts appear in the .sm
	local list={}
	if CurSong() then
		local st=SM_VERSION==5 and steps:GetStepsType() or GetStepsType()
		list=CurSong():GetStepsByStepsType(st)
		--list=CurSong():GetStepsByStepsType(GetStepsType()) --(steps:GetStepsType())
		local c=GetEnv("EditMode") and {"GetDifficulty"} or {"GetDifficulty","GetMeter","GetDescription"}
		table.sort(list,function(a,b)
		--table.stablesort(list,function(a,b)
			--ScreenEdit only stable_sorts by difficulty slot for F5/F6 switching.
			local i=1
			while i<table.getn(c) and Steps[c[i]](a)==Steps[c[i]](b) do i=i+1 end --skip over any equal attributes
			return Steps[c[i]](a)<Steps[c[i]](b)
		end)
	end
	return list
end
function GetNumNoteLanes() return StepsTypesNumLanes[GetStepsType()+1] end
