-- Sort menu items. 18 entries max

	SortMenuEntries=function(coursemode)
		return not coursemode and { --dance mode
			{ Name='Folder', Sort='Group' },
			{ Name='Title', Sort='Title' },
			{ Name='Tempo', Sort='Bpm' },
			{ Name='Artist', Sort='Artist' },
			{ Name='Easy', Sort='EasyMeter' },
			{ Name='Medium', Sort='MediumMeter' },
			{ Name='Hard', Sort='HardMeter' },
			{ Name='Expert', Sort='ChallengeMeter' },
--			{ Name='MostPlayed', Sort='Popularity' },
--			{ Name='Blender', Sort='Roulette' },
		} or { --course mode
--[[
			{ Name='AllCourses', Sort='AllCourses',}, -- sorts into folders named Nonstop, Endless and Oni (hardcoded names)
			{ Name='Marathon', Sort='Nonstop', },
			{ Name='Survival', Sort='Oni', },
			{ Name='Workout', Sort='Endless', },
--]]
			{ Name='SongCount', Action=function() SetCourseSort(0,true) end, Sort=PlayModeName(), Screen=Branch.SelectMusic() },
			{ Name='AverageMeter', Action=function() SetCourseSort(1,true) end, Sort=PlayModeName(), Screen=Branch.SelectMusic() },
			{ Name='TotalMeter', Action=function() SetCourseSort(2,true) end, Sort=PlayModeName(), Screen=Branch.SelectMusic() },
			{ Name='Rank', Action=function() SetCourseSort(3,true) end, Sort=PlayModeName(), Screen=Branch.SelectMusic() },
		}
	end

	SortMenuExtraEntries=function(numplayers)
		local out=numplayers==1 and
			{
	--			{ Name='Single', Action=function() SetStyle("single") end, Screen=Branch.SelectMusic() },
	--			{ Name='Double', Action=function() SetStyle("double") end, Screen=Branch.SelectMusic() },
	--			{ Name='solo', Action=function() SetStyle("solo") end, Screen=Branch.SelectMusic() },
			} or {
	--			{ Name='Versus', Action=function() SetStyle("versus") end, Screen=Branch.SelectMusic() },
	--			{ Name='Couple', Action=function() SetStyle("couple") end, Screen=Branch.SelectMusic() },
			}

		if CanPlayMarathons() then
			--Note: lifebar type is forced on each play mode. I've had the game crash because the lifebar type remained on lifetime even after switching out of survival mode during a session.
			if IsCourseMode() then
				table.insert(out,{Name='DanceMode', Action=function() SetPlayMode("regular;mod,bar") SetSort("group") end, Screen=Branch.SelectMusic(false)})
			end
			if PlayModeName()~="Oni" and table.getn(CourseCache[PLAY_MODE_ONI])>0 then
				table.insert(out,{Name="SurvivalMode", Action=function() SetPlayMode("oni;mod,lifetime") SetSort("oni") end, Screen=Branch.SelectMusic(true)})
			end
			--put marathon at the bottom so the player only needs to nudge the sort menu once to get marathons
			if PlayModeName()~="Nonstop" and table.getn(CourseCache[PLAY_MODE_NONSTOP])>0 then
				table.insert(out,{Name='MarathonMode', Action=function() SetPlayMode("nonstop;mod,bar") SetSort("nonstop") end, Screen=Branch.SelectMusic(true)})
			end
		end
		
		--[[ doesn't work
		local numsides=GAMESTATE:GetNumSidesJoined()
		
		local stylechoices=PlayerEntryChoices[CurGame][GetNumPlayersEnabled()]

		for i,st in next,stylechoices,nil do
			if st.Sides==numsides then
				local style=st.Style
				local action=(function()
					local style=style
					return function() SetStyle(style) end end)
				local row={ Name="Style - "..st.Style, Action=action, Screen=Branch.SelectMusic() }
				table.insert(out,row)
			end
		end
		--]]
		
		return out
	end
