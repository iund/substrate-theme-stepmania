
Evnt={
	Clear=function() --results load
		local mode=GetSysConfig().SaveEVNTName

		if not mode or mode==1 then --event only
			GAMESTATE:SetTemporaryEventMode(false)
		elseif mode==2 then --never (allow player to name their scores in event mode)
			if GetPref("EventMode") then --disable it, then remember to reenable it after
				Env()._Event=true
				SetPref("EventMode",false)
			end
			GAMESTATE:SetTemporaryEventMode(false)
		elseif mode==3 then --always save EVNT
			GAMESTATE:SetTemporaryEventMode(true)
		end
	end,
	Apply=function() --results after commit score
		local mode=GetSysConfig().SaveEVNTName or 1
		--if GetSysConfig().Timer then GAMESTATE:SetTemporaryEventMode(true) end
		GAMESTATE:SetTemporaryEventMode(not not (GetSysConfig().Timer))
		if Env()._Event then
			Env()._Event=nil
			SetPref("EventMode",true)
		end
	end,
}


---Scores
function LoadScores()
	if Profile.GetHighScoreList and HighScore and HighScore.GetPercentDP and HighScore.GetDate and HighScore.GetName then
		ForeachPlayer(function(pn) ScoreList[pn]=GetSortedHighScoreList(CurSong(),CurSteps(pn)) end) --TODO bugtest this 
	else
		PrepareScreen("NameEntry") DeletePreparedScreens() --do this in Screens.Evaluation
	end
end --populate Feat with the score list by loading the screen

function FormatScoreDate(str) --Takes for example "05/24" and spits out "May 24"
	local date=split("[^%d]",str)
	local month=Languages[CurLanguage()].Common.MonthNames[tonumber(date[1])] or ""
	local day=tostring(tonumber(date[2]))
	return join(" ",{month,day})
end

--SM5:
function GetSortedHighScoreList(song,steps)
	local hsl=PROFILEMAN:GetMachineProfile():GetHighScoreList(song,steps):GetHighScores()
	local c={"GetPercentDP","GetDate","GetName"}
	local getn=table.getn
	local hs=HighScore
	table.sort(hsl,function(a,b)
		local i=1
		while i<getn(c) and hs[c[i]](a)==hs[c[i]](b) do i=i+1 end --skip over any equal attributes
		return hs[c[i]](a)<hs[c[i]](b)
	end)
	return hsl
end

function GetScores()
--s	if not song or not steps or not (Profile[IsCourseMode() and "GetCourseHighScoreList" or "GetStepsHighScoreList"] and HighScore) then return "" end --upon SSM open, PaneDisplay bga calls this function with song set, but steps unset even after queuecommand.

	local envg=GetSysProfile().HighScores
	local dir=IsCourseMode() and CurCourse() and (Course.GetCourseDir and CurCourse():GetCourseDir() or CurCourse():GetDisplayFullTitle()) or CurSong():GetSongDir()
	local stype=GetStepsTypeString()
	local diffstr=IsCourseMode() and CourseDifficultyNames[1+CurTrail(pn):GetDifficulty()] or DifficultyToString(CurSteps(pn):GetDifficulty())
	envg[dir]=envg[dir] or {}
	envg[dir][stype]=envg[dir][stype] or {}
	envg[dir][stype][diffstr]=envg[dir][stype][diffstr] or {}

	local list=envg[dir][stype][diffstr]

	return list
end

--oITG w/ HighScore bindings
function GetScoreColDisplay(song,steps,hsfunc)
	if not song or not steps or not (Profile[IsCourseMode() and "GetCourseHighScoreList" or "GetStepsHighScoreList"] and HighScore) then return "" end --upon SSM open, PaneDisplay bga calls this function with song set, but steps unset even after queuecommand.
	
	local hslraw=Profile[IsCourseMode() and "GetCourseHighScoreList" or "GetStepsHighScoreList"](PROFILEMAN:GetMachineProfile(),song,steps)
	if hslraw then
		local hsl=hslraw:GetHighScores()
		local c={"GetPercentDP","GetDate","GetName"}
		local getn=table.getn
		local hs=HighScore
		table.sort(hsl,function(a,b)
			local i=1
			while i<getn(c) and hs[c[i]](a)==hs[c[i]](b) do i=i+1 end
			return hs[c[i]](a)>hs[c[i]](b)
		end)
	
		local out={}
		
		for i=1,Metrics.Summary.NumScoresDisplayed do
			out[i]=hsl[i] and (
				hsfunc=="GetDate" and FormatScoreDate(string.sub(hs[hsfunc](hsl[i]),6,10))    --"2017-09-13 17:35:01" -> "09-13" -> "Sep 13"
				or hsfunc=="GetPercentDP" and FormatPercentScore(hs[hsfunc](hsl[i]))
				or tostring(hs[hsfunc](hsl[i]))
			) or "----"
		end			
--[[			
		for i,v in next,hsl,nil do
			out[i]=
				hsfunc=="GetDate" and FormatScoreDate(string.sub(hs[hsfunc](v),6,10))    --"2017-09-13 17:35:01" -> "09-13" -> "Sep 13"
				or hsfunc=="GetPercentDP" and FormatPercentScore(hs[hsfunc](v))
				or tostring(hs[hsfunc](v))
		end
--]]
		return join("\n",out)
	else
		return ""
	end
end

--3.95:
function GetScoreCol(pn,col,numscores,i) --Gets score wheel columns from Feat. Used in evaluation.
	local getn=table.getn
	if not Feat or not Feat.Scores[pn][i or getn(Feat.Scores[pn])] then return "" end
	local insert=table.insert
	local list=Feat.Scores[pn][i or getn(Feat.Scores[pn])].List
	local out={}
	for row=1,math.min(numscores or getn(list),getn(list)) do insert(out,col~="rank" and list[row].date=="01/00" and "----" or col=="date" and FormatScoreDate(list[row][col]) or list[row][col]) end
	return join("\n",out)
end

function GetSummaryScoreCol(pn,col,numscores,i) --Same as above, except the score wheel text is read from Scores.
	local insert=table.insert
	local getn=table.getn
	local list=Scores[i][pn].ScoreList
	local out={}
	for row=1,math.min(numscores or getn(list),getn(list)) do insert(out,col~="rank" and list[row].date=="01/00" and "----" or col=="date" and FormatScoreDate(list[row][col]) or list[row][col]) end
	return join("\n",out)
end

function IsFailed(pn) return GetGrade(pn)==GRADE_FAILED end
function AllFailed() return IsFailed(1) and IsFailed(2) end

--Counterpart to OnePassed, but for 100% score
function OneQuad() return GetGrade(1)==GRADE_TIER01 or GetGrade(2)==GRADE_TIER01 end

function SaveScores() --Given that oITG is missing Profile.GetStepsHighScoreList while still having the (orphaned) HighScore functions, save a parallel Lua table with the same information.
--[[ Do this later.
	local envg=GetSysProfile().HighScores
	local dir=IsCourseMode() and CurCourse() and (Course.GetCourseDir and CurCourse():GetCourseDir() or CurCourse():GetDisplayFullTitle()) or CurSong():GetSongDir()
	local stype=GetStepsTypeString()
	envg[dir]=envg[dir] or {}
	envg[dir][stype]=envg[dir][stype] or {}

	ForeachPlayer(function(pn)
		local diffstr=IsCourseMode() and CourseDifficultyNames[1+CurTrail(pn):GetDifficulty()] or DifficultyToString(CurSteps(pn):GetDifficulty())
		envg[dir][stype][diffstr]=envg[dir][stype][diffstr] or {}
		local list=envg[dir][stype][diffstr]
		local score=Scores[table.getn(Scores)][pn]
		if not (score.Failed or score.DQ) then
			local entry={}
			table.copy(score,entry)
			--add some useful bits
			entry.Name=PlayerName(pn)
			entry.Mods=PlayerMods(pn)
			entry.Score=UnformatPercentScore(entry.Percent)
			entry.Percent=nil
			entry.Timestamp=CurTime()
			--remove unneccessary stuff
			entry.ScoreList=nil
			entry.Steps=nil
			entry.Meter=nil
			entry.MaxCombo=nil
			table.insert(list, entry)	
		end
		table.sort(list,
			function(a,b) return
				a.Percent>b.Percent
				or a.Percent==b.Percent and a.Timestamp>b.Timestamp
			end
		)
		list=table.sub(list,1,3)
	end)
--]]
end
