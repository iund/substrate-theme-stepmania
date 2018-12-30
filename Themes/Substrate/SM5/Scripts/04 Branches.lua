Branch={}
Branch={
	Start=function()
		--detect various features we need and bail out if we don't have them:
		--If the executable doesn't provide these, we will softlock on several screens
		if not (ScreenManager.set_input_redirected and Screen.AddInputCallback)
		then
			return "BootWrongVersion"
		end
		
		
		return
		(GAMESTATE:GetCoinMode()=="CoinMode_Home" or
		GAMESTATE:GetCoinMode()=="CoinMode_Pay" and GAMESTATE:EnoughCreditsToJoin())
			and Branch.Title()
			or Branch.FirstAttract()
	end,
	FirstAttract=function() return "Logo" end,
	AttractCancel=function() return Branch.Title() end,
--Attract screens TODO

	--How to play
	--Ranking
	--Demo
	--Logo
	
--Title
	TitleBack=function()
		return GAMESTATE:GetCoinMode()=="CoinMode_Home" and "Exit"
		or GAMESTATE:GetCoinsNeededToJoin()>0 and Branch.FirstAttract()
		or Branch.Title()
	end,

	Title=function() return GAMESTATE:GetCoinMode()=="CoinMode_Home" and "TitleMenu" or "TitleJoin" end,
	TitleNext=function() return THEME:GetMetric("Common","AutoSetStyle") and Branch.Caution() or Branch.PlayerEntry() end, --Don't need player entry if we can late join.

	GameBack=function() return GAMESTATE:EnoughCreditsToJoin() and Branch.Title() or Branch.FirstAttract() end,

	PlayerEntryBack=function() return Branch.GameBack() end,
	PlayerEntry=function() return "PlayerEntry" end,
	PlayerEntryNext=function() return Branch.Caution() end,

	--Caution also loads profiles if any.
	CautionBack=function() return Branch.GameBack() end,
	Caution=function() return "Caution" end,
	CautionNext=function() return Branch.SelectMusic() end,
	
--Game
	SelectMusicBack=function() return GAMESTATE:GetCurrentStageIndex()>0 and Branch.NameEntry() or Branch.GameBack() end,
	SelectMusic=function() return "SelectMusic"..(IsCourseMode() and "Course" or "") end,
	SelectMusicCourse=function() return "SelectMusicCourse" end, --Nonstop wheel item uses this. IsCourseMode() isn't applied before the screen opens.
	SelectMusicNext=function() return GetScreen():GetGoToOptions() and Branch.ModsMenu() or Branch.Stage() end,

	--Mods menu
	ModsMenuBack=function() return Branch.SelectMusic() end,
	ModsMenu=function() return "ModsMenu" end,
	ModsMenuNext=function() return Branch.Stage() end,
	
	StageBack=function() return Branch.SelectMusic() end,
	Stage=function() return "Stage" end,
	StageNext=function() return Branch.Gameplay() end,

	GameplayBack=function() return Branch.SelectMusic() end,
	Gameplay=function() return "Gameplay" end,
	GameplayNext=function() return Branch.Evaluation() end, --savesync is handled by the game

	EvaluationSuffix=function()
		local i=clamp(math.ceil(math.random()*4),1,4)
		return 
			not STATSMAN:GetCurStageStats():OnePassed() and "Failed"
			or tostring(i)..
				((GAMESTATE:IsPlayerEnabled(PLAYER_1) and STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetPercentDancePoints()==1
				or GAMESTATE:IsPlayerEnabled(PLAYER_2) and STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2):GetPercentDancePoints()==1)
				and "Quad" or "Pass")
	end,

	Evaluation=function()
		return (IsCourseMode() and "EvaluationCourse"
			or "EvaluationStage"
		)..Branch.EvaluationSuffix()
	end,

	EvaluationNext=function()
		return 
			IsNetSMOnline() and "NetRoom"
			or IsNetConnected() and "NetSelectMusic"
			or (GAMESTATE:IsEventMode()
				or not IsCourseMode() and
					STATSMAN:GetCurStageStats():OnePassed()
					and GAMESTATE:GetSmallestNumStagesLeftForAnyHumanPlayer()>0
				) and Branch.SelectMusic()
			or Branch.NameEntry()
	end,

	--Name entry
	NameEntry=function() return "NameEntry" end,
	NameEntryNext=function() return "SaveProfiles" end,

	--Profile save
	SaveProfilesNext=function()
		return Branch.Ending()
	end,
	
	Ending=function()
		return "Ending" --TODO
	end,

	--Game over (inherit the ranking screen for this)
}
