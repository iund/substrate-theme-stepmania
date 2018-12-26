-- Title Menu

	-- Name maps as "Graphics/(screen name) Scroll Choice(Name).actor"

TitleMenuEntries = function() return
	table.concati(
		{
			{ Name="Names", Title = "Start", Mode="Regular", Screen=Branch.TitleNext() },
		},
--[[
		table.getn(CourseCache[PLAY_MODE_NONSTOP])>0 and {
			{ Name="Names", Title = "StartMarathons", Mode="Nonstop", Screen=Branch.TitleNext() },
		} or {},
		table.getn(CourseCache[PLAY_MODE_ONI])>0 and {
			{ Name="Names", Title = "StartSurvival", Mode="Oni;mod,lifetime", Screen=Branch.TitleNext() },
		} or {},
		{ Name="Names", Title = "NetworkPlay", Mode="Regular", Action=function() SetEnv("Network",1) ConnectToServer("") end, Screen=Branch.TitleNext() },
--]]

	--TODO		{ Name="Names", Title = "StartSuperMarathon", Mode="Regular", Action=function() SetEnv("SuperMarathon",1) end, Screen=Branch.TitleNext() },
	--workout is broken rn		{ Name="Names", Title = "StartWorkout", Mode="Regular", Action=function() SetEnv("WorkoutMode",1) end, Screen=Branch.TitleNext() },

--[[ NOTE: Match sm5.
		not IsArcade() and {
			{ Name="Names", Title = "Profiles", Screen="Profiles" },
			--{ Name="Names", Title = "Records", Screen="ScreenRecordsMenu" },
			--{ Name="Names", Title = "ManageProfiles", Action=function() SetEnv("ManageProfiles",1) end, Screen=Branch.PlayerEntry() },
		} or {},
--]]
		{
			{ Name="Names", Title = "Test Inputs", Action=function() GAMESTATE:SetEnv("BackToTitle",1) SOUND:StopMusic() end, Screen="TestInput" },
		},
		not IsArcade() and {
			{ Name="Names", Title = "Map Inputs", Action=function() GAMESTATE:SetEnv("BackToTitle",1) end, Screen="Remap" },
--[[ NOTE: Match sm5
			Metric("Common","EditMode")>0
				and { Name="Names", Title = "Edit", Screen="EditMenu" }
				or { Name="Names", Title = "Practice", Mode="Regular", Action=function() SetEnv("EditMode",1) SetEnv("PracticeMode",1) end, Screen=Branch.TitleNext() },
--]]
		} or {},
		{
			{ Name="Names", Title = "Options", Screen="ServiceMenu" },
		}
	)
end
