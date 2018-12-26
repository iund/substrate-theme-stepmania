Screens.Gameplay={
		Init=function(s) --s=screen
			JudgeComboInit.Init()
			DangerState={}
			DeathState={}
			GameCommand("stopmusic") --fix bug where the course menu music continues playing when starting gameplay from mods menu exit
			
			--LifeMeterTime will crash without a course set. Set a survival course with a nonzero gain-life-seconds time.
			--I disabled it because OptionRow assert fails on "pTrail != NULL" in PlayerOptionsBPM.
			--if GAMESTATE:GetPlayMode()==PLAY_MODE_REGULAR and not CurCourse() then GAMESTATE:SetCurrentCourse(SONGMAN:FindCourse("Blinker")) end
			
			--Useful for LifeMeterTime. STATSMAN:GetCurStageStats():GetPlayerStageStats(pNum[pn]):GetLifeRemainingSeconds()
			s:effectclock("music")
		end,
		On=function(s) --s=helptext
			Ghost.Init(s)
			if not IsDemonstration() then ForeachPlayer(SaveModifiers) end

			ApplyModifier(nil,"FailEndOfSong")
		end,
		AfterModsSave=function(s,pn) --s=OniGameOverPn --also run on LoadNextSong after setting m_pCurSong
			if not (IsDemonstration() or IsNovice(pn)) then ApplyStageSpeedMod(pn) end --this overrides forced novice mods.

			if not IsCourseMode() and CurSong() then --starting a song
				Ghost.Load(pn)
			elseif IsCourseMode() and not CurSong() then --starting a course
				Ghost.LoadCourse(pn)
			elseif IsCourseMode() and CurSong() then --next song in course
				Ghost.NextCourseSong(pn)
			end

			--Record some general play stats: (playcount+=2 if both sides played a song versus)
			if not IsDemonstration() and Player(pn) and CurSong() then
				GetSysProfile().PlayStats=GetSysProfile().PlayStats or {}

				local dir=CurSong():GetSongDir()
				local steps=CurSteps(pn)
				local stype=StepsTypeString[steps:GetStepsType()+1]
				local diffstr=DifficultyToString(steps:GetDifficulty())

				local p=GetSysProfile().PlayStats
			
				p[dir]=p[dir] or {}
				p[dir][stype]=p[dir][stype] or {}
				p[dir][stype][diffstr]=p[dir][stype][diffstr] or {}
				local entry=p[dir][stype][diffstr]

				entry.PlayCount=(entry.PlayCount or 0)+1
				entry.LastPlayedTime=CurTime()
			end
			
			--Only clears m_textPlayerOptions[p] on the next course song. Look in Ghost.InitText() to clear text on first/individual song.
			--if GhostDisplayText and GhostDisplayText[pn] then GhostDisplayText[pn]:settext("") end
		end,

		--First song:
		Ready=function() --hooked from tween on screen, after first LoadNextSong()
--[[
			CourseSongStats={}
			ForeachPlayer(function(pn)
				CourseSongStats[pn]={}
				local judge={}
				for j=1,9 do judge[j]=0 end
				table.insert(CourseSongStats[pn],judge)
			end)
--]]

			if tonumber(string.sub(_VERSION,5,7))<5.1 then
				--Get rid of lag spikes in gameplay. Lua 5.0's garbage collector runs all at once and blocks everything else until it's done.
				collectgarbage()
				collectgarbage()
				--allocate up to 10MB
				collectgarbage(40000000)
			end

		end,
		
		BeforeNextSong=function() --hooked from NextCourseSong message
		
		
		end,
		--Next song in course:
		SongFinished=function() --after SongFinished(), before LoadNextSong()
			--Save stats here for example
--[[
			local entry={Song=CurSong()}
			ForeachPlayer(function(pn)
				entry[pn]={Judge={}}
				for j=1,9 do entry[pn].Judge[j]=JudgeCounts[pn][j] JudgeCounts[pn][j]=0 end
				entry[pn].Steps=CurSteps(pn)
			end)
			table.insert(CourseSongStats,entry)
--]]
			collectgarbage()
			collectgarbage()
		end,
		NextSong=function() --after LoadNextSong() from NextCourseSongLoaded (Finish command in overlay)

		end,
		
		--updates
		FirstUpdate=function()
			if GetScreen():GetChild("Debug") then GetScreen():GetChild("Debug"):shadowlength(0) end
		end,
		Update=function(s) --s=lifeframe
			ForeachPlayer(function(pn)
				StreamDisplay.Update(pn)
				StreamDisplay.UpdateNext(pn)
				if DangerState then
					Screens.Gameplay.Death.Check(DeathState[pn],pn)
					Screens.Gameplay.Danger.Check(DangerState[pn],pn)
				end
				Ghost.UpdateText(GhostDisplayText[pn],pn)
			end)
		end,
		
		--player state
		Danger={
			Update=function(s) if DangerState then DangerState[s:getaux()].LastSeenTime=s:GetSecsIntoEffect() end end,
			Check=function(danger,pn) --Fire a message when player enters/leaves danger threshold.
				--The danger layer only draws when danger is active and doesn't fire any messages to indicate so.
				if not danger.Active and danger.LastSeenTime~=danger.CachedLastSeenTime and danger.LastSeenTime>0 then
					danger.Active=true Broadcast("DangerP"..pn.."Show")
				elseif danger.Active and danger.LastSeenTime==danger.CachedLastSeenTime and danger.LastSeenTime>0 then
					danger.Active=false Broadcast("DangerP"..pn.."Hide") 
					if not IsFailed(pn) then Broadcast("DangerP"..pn.."Recover") end
				end
				danger.CachedLastSeenTime=danger.LastSeenTime
			end,
		},
		Death={
			Update=function(s) if DeathState then DeathState[s:getaux()].LastSeenTime=s:GetSecsIntoEffect() end end,
			Check=function(death,pn) --Fire a message when player dies. --A player can't "undie" so only check death activation.
				if not death.Active and death.LastSeenTime>0 then death.Active=true Broadcast("DeathP"..pn.."Show") Ghost.Die(pn) PlaySound("Gameplay die",true) end
			end,
		},
		
		--other
		AutoSyncChanged=function()
			--ApplyMod("no savescores") --hold on this is Autoplay but apply this here too I guess?
		end,
		Alarm=function()
			Screens.Gameplay.Off()
			ForeachPlayer(function(pn) ApplyModifier(pn,"FailImmediate") end)
			SetScreen(Branch.Evaluation())
			--BUG: Scores don't get committed to Evaluation.
		end,
		
		Pause={
			--[[
				NotITG:
					Hit select to pause
					Hit select or start to unpause
			--]]
			StartPressed=function(s)
				--notITG automatically unpauses the game for you
				if s:getaux()==1 and not IsDemonstration() then
					s:aux(0)
					SCREENMAN:HideOverlayMessage()
					Broadcast("GameUnpaused")
				end
			end,
			SelectPressed=function(s)
				local screen=GetScreen()
				local allowpause=getmetatable(screen).PauseGame and not IsDemonstration()
				if allowpause then
					if s:getaux()==0 then
						--pause the game
						screen:PauseGame(true)
						s:aux(1)
						SCREENMAN:OverlayMessage("Paused\n\nPress  to resume") --\nPress  to restart")
						Broadcast("GamePaused")
					else
						--game is already paused, restart?
						-- [[
						screen:PauseGame(false)
						s:aux(0)
						SCREENMAN:HideOverlayMessage()
						Broadcast("GameUnpaused")
						--]]
						--SOUND:StopMusic()
						--SetScreen(Branch.Gameplay()) --restart
					end
				end
			end,
		},
		Off=function()
			DangerState=nil
			DeathState=nil
			receptors=nil
		end
	}
