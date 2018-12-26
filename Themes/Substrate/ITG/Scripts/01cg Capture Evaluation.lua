Capture.Evaluation={
		Init=function(s)
			ScreenObjects={}
			local new={}
			ForeachPlayer(function(pn) new[pn]={Judge={},Stats={}} ScreenObjects[pn]={Judge={},Stats={},Song={}} end)
			table.insert(Scores,new)
		end,
		Judge={
			Marvelous=function(s,pn) ScreenObjects[pn].Judge[1]=s end,
			Perfect=function(s,pn) ScreenObjects[pn].Judge[2]=s end,
			Great=function(s,pn) ScreenObjects[pn].Judge[3]=s end,
			Good=function(s,pn) ScreenObjects[pn].Judge[4]=s end,
			Boo=function(s,pn) ScreenObjects[pn].Judge[5]=s end,
			Miss=function(s,pn) ScreenObjects[pn].Judge[Metrics.Evaluation.NumJudgeRows]=s end,
		},
		Stats={
			Jumps=function(s,pn) ScreenObjects[pn].Stats.Jumps=s end,
			Holds=function(s,pn) ScreenObjects[pn].Stats.Holds=s end,
			Mines=function(s,pn) ScreenObjects[pn].Stats.Mines=s end,
			Rolls=function(s,pn) ScreenObjects[pn].Stats.Rolls=s end,
			Hands=function(s,pn) ScreenObjects[pn].Stats.Hands=s end,
		},
		Song={
			Meter=function(s,pn) Scores[table.getn(Scores)][pn].Meter=tonumber(s:GetText()) ScreenObjects[pn].Song.Meter=s end,
			Song=function() Scores[table.getn(Scores)].Song=CurSong() end,
			Course=function() Scores[table.getn(Scores)].Course=CurCourse() end,
			BPM=function() Scores[table.getn(Scores)].BPM=GetBPM() end,
			Steps=function(pn) Scores[table.getn(Scores)][pn].Steps=CurSteps(pn) end,
			SongOptions=function(s) end,
			Percent=function(s,pn) Scores[table.getn(Scores)][pn].Percent=(s:GetText()) ScreenObjects[pn].Song.Percent=s end,
			MaxCombo=function(s,pn) Scores[table.getn(Scores)][pn].MaxCombo=tonumber(s:GetText()) ScreenObjects[pn].Song.MaxCombo=s end,
			Mods=function(s,pn) Scores[table.getn(Scores)][pn].Mods=s:GetText() ScreenObjects[pn].Song.Mods=s end,
			Failed=function(pn) Scores[table.getn(Scores)][pn].Failed=GetGrade(pn)==GRADE_FAILED end,
			Grade=function(pn) Scores[table.getn(Scores)][pn].Grade=GetGrade(pn) end,
			DQ=function(s,pn) Scores[table.getn(Scores)][pn].DQ=true end, --the DQ object only loads when the player got DQ
			Time=function(s,pn) 
				-- Can't grab the text (it's set immediately after On); get it from Statsman instead.
				local stats=STATSMAN:GetCurStageStats():GetPlayerStageStats(pNum[pn])
				Scores[table.getn(Scores)][pn].Time=stats:GetSurvivalSeconds()-stats:GetLifeRemainingSeconds() --MSSMsMsToSeconds(s:GetText())
				ScreenObjects[pn].Song.Time=s
			end,
			ScoreList=function(pn) Scores[table.getn(Scores)][pn].ScoreList=Feat.Scores[pn][table.getn(Feat.Scores[pn])].List end, --not a capture, but it's here for consistency's sake.
		},
	}
