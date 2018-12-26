Screens.Evaluation={
		Init=function(s)
			FitScreenToAspect(s)
			ForeachPlayer(ApplyStageSpeedMod)
			
--[[
			--Don't DQ for using Hide BG.
			-----Commented out because for whatever reason Cover gets applied in super-marathon mode here
			Env()._HideBG={}
			ForeachPlayer(function(pn)
				Env()._HideBG[pn]=UsingModifier(pn,"Cover")
				ApplyModifier(pn,"Cover",0)
			end)
--]]
		end,
		SetDQ=function(pn) --Re set hide bg (applied on PlayerOptionsPnOnCommand, just before DQ sprite loads.)
--[[
			ApplyModifier(pn,"Cover",Env()._HideBG[pn])
			Env()._HideBG[pn]=nil
--]]
		end,
		On=function(_) local s=GetScreen()
			Evnt.Clear()
		end,
		AfterSave=function(pn)
			SaveModifiers(pn)
		end,
		AfterCommitScores=function() --hooked from TimeLabelOn (unused), before TimeNumberPnOn.
			Evnt.Apply()
			if not GetEnv("Alarm") then
				LoadScores()

				if IsCourseMode() then Capture.Evaluation.Song.Course() end
				--Put song stats data into table
				Capture.Evaluation.Song.Song()
				Capture.Evaluation.Song.BPM()
				ForeachPlayer(function(pn)
					--Put player stats data into table
					Capture.Evaluation.Song.Steps(pn)
					Capture.Evaluation.Song.Failed(pn)
					Capture.Evaluation.Song.ScoreList(pn)
					Capture.Evaluation.Song.Grade(pn)
					
					-- Remove whitespace
					for j=1,table.getn(ScreenObjects[pn].Judge) do ScreenObjects[pn].Judge[j]:settext(string.gsub(ScreenObjects[pn].Judge[j]:GetText()," ","")) end
					for _,st in next,ScreenObjects[pn].Stats,nil do st:settext(string.gsub(st:GetText()," ","")) end
					if ScreenObjects[pn].Song.MaxCombo then ScreenObjects[pn].Song.MaxCombo:settext(string.gsub(ScreenObjects[pn].Song.MaxCombo:GetText()," ","")) end

					for _,y in next,{"Judge","Stats"},nil do
						--Put player scores into table
						for i,s in next,ScreenObjects[pn][y],nil do
							local v=s:GetText()
							Scores[table.getn(Scores)][pn][y][i]=tonumber(v) or v
						end
					end
					
					local dq=Scores[table.getn(Scores)][pn].DQ==true and " (DQ)" or ""
					if ScreenObjects[pn].Song.Mods then
						ScreenObjects[pn].Song.Mods:settext(PlayerMods(pn,true)..dq)
					end
				end)
			else
				--ITG BUG? The scores don't get committed by SGP's Finish Stage; jump directly to name entry.
				SetScreen("NameEntry")
			end
			Ghost.Save()
			SaveScores()
		end,
		FirstUpdate=function(s,final)
			if not (GetEnv("Alarm") or GetEnv("SuperMarathon") or GetEnv("WorkoutMode")) then
				ForeachPlayer(function(pn)
					--Get Time object that got missed earlier
					ScreenObjects[pn].Song.Time:settext(SecondsToMSS(Scores[table.getn(Scores)][pn].Time)) --SecondsToMSS(MSSMsMsToSeconds(ScreenObjects[pn].Time:GetText())))
				end)
			end

			--TODO:: Bad idea to put a crash-preventer in a first update. Find somewhere else for this.
			--a score row gets populated for the summary (which I don't want). Removing it here is easier than going to every other place in the code
			if final then table.remove(Scores) end

			Env().NumStagesPlayed=Env().NumStagesPlayed+1 --delay this so stage counter doesn't increment prematurely on this screen in event mode

			--TODO: score readout?
			--SOUND:DimMusic(0,0) --DimMusic is hardcoded to fade out for 0.3s, and fade back in for 1.5s
		end,
		Alarm=function()
			--SetScreen(Branch.EvaluationNext()) --Let this screen stay
		end,
	}
