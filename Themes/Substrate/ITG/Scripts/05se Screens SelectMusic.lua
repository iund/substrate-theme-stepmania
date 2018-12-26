Screens.SelectMusic={
		Init=function(s)
			FitScreenToAspect(s)
			LoadProfile() --I'd do it in PlayersFinalized but that message gets fired *before* profile loading happens.
			-- Was Capture.MusicWheel.WheelOn(), but SM5 doesn't run that til after.
			mwItems={} mwSprites={} mwTexts={}
			mwState={}

			PaneItemObjects={}
			stepsStats={}
			playerMeter={}
			s:effectclock("music") --for live tempo display
			Env().ResultsMusic=1 --prevent an unlikely crash

			Capture.ModsMenu.Off() --in case we backed out from ScreenPlayerOptions
			ForeachPlayer(Capture.Player.Off) --in case we backed out from ScreenGameplay

			--If a previously selected long song is no longer selectable, select the default song instead:
			--This overrides [GameState] DefaultSong= (which is read on boot, not screen load)
			GAMESTATE:SetCurrentSong(not IsCourseMode() and (
				AllSongsBy.Dir[GetSysConfig().DefaultSong] or
				SONGMAN:FindSong(string.gsub(THEME:GetMetric('GameState','DefaultSong'),'/Songs/',''))
				or SONGMAN:GetAllSongs()[1])
				or nil
			)

			if not Env().FullMode and not IsNetwork() then GameCommand("sort,preferred") end

			--Not needed for sort,Preferred, needed for the other sorts.
			SetPref("MusicWheelUsesSections", (Env().FullMode or IsNetwork()) and 1 or 0) --{ NEVER, ALWAYS, ABC_ONLY };
		end,
		On=function(s)
			diff={}

			--Beta 3 resets ratemod. Re-apply it.
			if OPENITG then ApplyMod(string.format('%1.1fxmusic',Env().SongMods.Rate)) end
			if SM_VERSION==5 then s:queuemessage("CurrentSongChanged") ForeachPlayer(function(pn) s:queuemessage("CurrentStepsP"..pn.."Changed") s:queuemessage("CurrentTrailP"..pn.."Changed") end) end
		end,
		FirstUpdate=function(s)
			if IsCourseMode() then CourseContentsList.Refresh() end
			Screens.SelectMusic.SongChanged()
			ForeachPlayer(function(pn)
				Screens.SelectMusic.StepsChanged(pn)

				if not IsNetwork() then
					--doesn't load in network
					DiffList[pn].self:visible(Bool[not IsCourseMode()])
					CourseList[pn].self:visible(Bool[IsCourseMode()])
				end
			end)
		end,
		SongOptionsText=function(s)
			--Put ratemod here?
		end,
		InputEvent=function()
			--every time we get an input event, this is run
			--also run on screen open
			Broadcast("InputEvent")
		end,
		MoveWheel=function(wheel)
			--self explanatory, hooked from MusicWheelCurrentSongChangedMessageCommand
		end,

		SongChosen=function()
			--1st start hit
		end,
		EnterModsMenu=function()
			--2nd start hit
			Broadcast("EnterModsMenu")
			Env().SelectedTab=2 --which tab the top menu opens onto. TODO move to menu layout tables
		end,

		SongChanged=function()
			Broadcast("SongChanged")
			if CurSong() or CurCourse() then
				if Song.GetDisplayBpms then
					Env().SongBPM=CurSong():GetDisplayBpms()
				elseif THEME:GetMetric('BPMDisplay','Cycle')==false then
					Capture.BPM(BPMText)
				end
				--Capture.SongTime(GetScreen():GetChild("TotalTime"))
				LoadSpeedMod() --only run on profile load, to import X-Mods.

				--folder/artist display
				if GetScreen():GetChild("MachineRank") then
					GetScreen():GetChild("MachineRank"):settext(
						CurSong() and 
						(--Env().SongMods.ShowFolder and 
							GetFolder(CurSong()) or 
							CurSong():GetDisplayArtist()
						) or CurCourse() and
						Course.GetCourseDir and GetCourseFolder(CurCourse())
						or ""
					)
				end
			end
		end,
		NetDifficultyChanged=function(s,pn)
			--Detect if difficulty changed (network)
			local cachedDiff=s
			local diff=GAMESTATE:GetPreferredDifficulty(pNum[pn])

			--refresh wheel
			if diff~=cachedDiff:getaux() and mwTexts then
				cachedDiff:aux(diff)
				Capture.MusicWheel.SetAllMeterText(pn)
				PlaySound("NetSelectMusic change difficulty",true)
			end
		end,
		StepsChanged=function(pn)
			if IsNetwork() then
--[[
				--Detect if difficulty changed (network)
				local cachedDiff=GetScreen():GetChild("MeterP"..pn)
				local diff=GAMESTATE:GetPreferredDifficulty(pNum[pn])

				--refresh wheel
				if diff~=cachedDiff:getaux() then
					cachedDiff:aux(diff)
					Capture.MusicWheel.SetAllMeterText(pn,GetScreen():GetChild('MusicWheel'))
				end
--]]
			return end --todo. netselectmusic has nothing on screen.

			--In 3.95 this is always run on both players, even when only one side changes difficulty. (because its hooked from DifficultyList MoveCursor, which runs after all objects write text)
		
			--this is also fired when you scroll through the song wheel
			if not IsPlayerEnabled(pn) then return end
			if CurSteps(pn) or CurTrail(pn) then
				stepsStats[pn]=Capture.SongStats(pn)
				playerMeter[pn]=Capture.Meter(pn)
				if SM_VERSION==3.95 then
					Capture.Score(pn)
--[[					
					local rv=Steps.GetRadarValues and (IsCourseMode() and CurTrail(pn) or CurSteps(pn)):GetRadarValues()
					stepsStats[pn].MaxDP=rv and
						--get step counts directly instead of reading Panedisplay
						(rv:GetValue(RADAR_CATEGORY_TAPS)*GetPref("PercentScoreWeight"..JudgeNames[1])+
						(rv:GetValue(RADAR_CATEGORY_HOLDS)+rv:GetValue(RADAR_CATEGORY_ROLLS))*GetPref("PercentScoreWeight"..JudgeNames[7])
						)
					or Ghost.GetMaxDP(stepsStats[pn]) --Vanilla 3.95/Rxx needs to read PaneDisplay.
--]]
					assert(stepsStats and stepsStats[pn])
					stepsStats[pn].MaxDP=Ghost.GetMaxDP(stepsStats[pn]) --Vanilla 3.95/Rxx needs to read PaneDisplay.
				else
					--TODO: SM5
				end
				if IsCourseMode() and GetScreen():GetChild("ArtistDisplay") then --It should belong in SongChanged, but the course artist display shows afterward.
					local artists=({GetScreen():GetChild("ArtistDisplay"):gettips()})[1]
					Env().CourseLengthSongs=table.getn(artists)
				end
--[[
--debug start
if not IsCourseMode() then	
			--DEBUG radar values, in the hope to figure out why the radar disappears


			--it disappears because some values get cached as -nan (divide by zero?)

			local cs=CurSteps(pn)
			local rv=cs:GetRadarValues()

			local rvt={}
			for r=1,5 do
				rvt[r]=rv:GetValue(r-1)
			end

			ScreenMessage(sprintf("%s\n%s %s %s",
				CurSong():GetSongDir(),
				StepsTypeString[cs:GetStepsType()+1],
				DifficultyToString(cs:GetDifficulty()),
				table.dump(rvt)
			),true)
end
--debug end

--]]
			end
			CustomDifficultyList.Set(pn)

			--put the steps description in the box
			if GetScreen():GetChild('PaneDisplayP'..pn) then
			GetScreen():GetChild('PaneDisplayP'..pn):GetChild(''):GetChild(IsCourseMode() and 'CourseMachineHighNameLabel' or 'MachineHighNameLabel'):settext(
				IsCourseMode() and CurTrail(pn) and Languages[CurLanguage()].CourseDifficultyNames[CurTrail(pn):GetDifficulty()] or
				CurSteps(pn) and CurSteps(pn):GetDescription() or '')
			end			
			if IsCourseMode() then CourseContentsList.Refresh() end

			Broadcast("StepsChangedP"..pn)
		end,
		CheckSort=function(sort)
		--[[ Commented out because it always goes to marathon mode when menu timer runs out with a folder highlighted.
		DumpActor(GetScreen():GetChild("Timer"),"menu timer")
			if sort==SORT_ROULETTE and 
			not (GetScreen():GetChild("Timer") and GetScreen():GetChild("Timer"):GetChild("Text1"):GetText()=="0")
			 then --GetScreen():GetChild("MusicWheel"):hidden(1)
			 SetScreen(Branch.EnterCourseMode()) end --enter Nonstop mode via a renamed Roulette wheelitem
		--]]
		end,
		Alarm=function()
			if not CurSong() then GAMESTATE:SetCurrentSong(SONGMAN:GetRandomSong()) end --force a song, if alarm fired when hovering over a folder
			if IsCourseMode() and not CurCourse() then GAMESTATE:SetCurrentCourse(SONGMAN:GetRandomCourse()) end --force a song, if alarm fired when hovering over a folder
			--SetScreen(Branch.SelectMusicNext())
		end
	}
