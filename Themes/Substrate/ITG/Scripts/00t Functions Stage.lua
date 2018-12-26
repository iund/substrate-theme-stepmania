---Stage
function StageIndex() return GameState.GetCurrentStageIndex and GAMESTATE:GetCurrentStageIndex() or GAMESTATE:StageIndex() end
function FinalStage() return not IsCourseMode() and IsFinalStage() or GAMESTATE:StageIndex()+1>=GetPref('SongsPerPlay') end --since Stepmania's builtin IsFinalStage() always returns true in course mode, and returns false if stageindex is past final stage (Allowing extra stage 'bug')

function TitleMenuStageText()
	--[[ returns one of the ofllowing examples:
		max 4 stages
		event mode
		10:00 timer
	--]]
	return
		GetPref('EventMode') and Languages[CurLanguage()].ScreenTitleJoin.EventMode
		or GetSysConfig().Timer and sprintf(Languages[CurLanguage()].ScreenTitleJoin.Timer,SecondsToMSS(GetSysConfig().TimerSeconds))
		or sprintf(Languages[CurLanguage()].ScreenTitleJoin.Stages,GetPref('SongsPerPlay'))
end

function StageText(s) --This is run on Stage objects load in SWME.
	local st=GetScreen():GetChild('Stage') --first Stage object; use as a counter lol
	local i=st and st:getaux()+1 or 1
	if st then st:aux(math.mod(i,table.getn(StageNames))) end

	if GetEnv("WorkoutMode") then
		return string.format("Workout Stage %d/%d",Env().WorkoutState and Env().WorkoutState.Stage or 1,GetSysConfig().WorkoutSongsToPlay)
	elseif GetEnv("SuperMarathon") then
		return string.format("Stage %d/%d",Env().SuperMarathon.Stage or 1,table.getn(Env().SongQueue or {}))
	elseif IsCourseMode() and Env().CourseLengthSongs and CourseSongIndex()<Env().CourseLengthSongs then
--		s:settext("") --s:settext("Song "..CourseSongIndex()+1)
		return string.format("Stage %d/%d", CourseSongIndex()+1, Env().CourseLengthSongs)
	elseif IsCourseMode() and Env().CourseLengthSongs and CourseSongIndex()>Env().CourseLengthSongs then
		return string.format("%d stages",Env().CourseLengthSongs)
	elseif not IsCourseMode() and not IsDemonstration() and not GetPref("EventMode") then
		return string.format("Stage %d/%d",StageIndex()+1, GetPref('SongsPerPlay'))-- -(GetScreen():GetChild('NumSongs') and tonumber(GetScreen():GetChild('NumSongs'):GetText()) or 0) --XXX: Fix this
	elseif GetPref("EventMode") then
		return string.format("Stage %d",IsCourseMode() and CourseSongIndex()+1 or (Env().NumStagesPlayed or 0)+1) --StageIndex()+1)
	else
		return StageNames[i]
	end
end
