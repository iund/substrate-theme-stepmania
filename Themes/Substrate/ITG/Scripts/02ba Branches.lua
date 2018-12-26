Branch={

--Boot
	Boot=function() return "Boot" end,

	Start=function()
		if GetSysConfig().AutoConnectNetwork and not IsNetConnected() then ConnectToServer("") end
		PrepareScreen("Logo") DeletePreparedScreens()
		return
			not IsArcade() and not table.find(INPUTMAN:GetDescriptions(),"Keyboard") and "ArcadeInit" --if user put random crap in InputDrivers=
			or IsPS2() and "AttachController" 
 			or IsArcade() and not IsArcadeInitialised() and not GetSysConfig().SkipArcadeStart and (GetInputType and "ArcadeStart" or "ArcadeInit")
			--or not GetSysConfig().Language and "SetLanguage"
			or IsArcade() and not GetSysConfig().TimeIsSet and "SetTime" --commented out while i get the sm5 side to work 
			or Branch.FirstAttract()
 	end,

	SkipArcadeInit=function() --start pressed on Arcade Init "Waiting for I/O"

	end,

	SetTimeBack=function()
		return
			not GetSysConfig().TimeIsSet and "SetTime"
			or GAMESTATE:GetEnv("ServiceMenu") and "ServiceMenu"
			or Branch.Start()
	end,
	
	SetTimeNext=function()
		GetSysConfig().TimeIsSet=true PROFILEMAN:SaveMachineProfile()
		return GAMESTATE:GetEnv("ServiceMenu") and "ServiceMenu" or Branch.Start()
	end,
	
 --Attract
	FirstAttract=function() return GAMESTATE:GetCoinMode()==COIN_MODE_HOME and Branch.Title() or
	"Logo"
	--"Credits"
	end,
	--FirstAttract=function() return "NameEntryDDR" end,

--Start

--------
	TitleBack=function() return IsArcade() and Branch.FirstAttract() or "Exit" end, --press Escape to quit
	Title=function() return GAMESTATE:GetCoinMode()==COIN_MODE_HOME and "TitleMenu" or "TitleJoin" end,
	TitleNext=function()
		return --GAMESTATE:GetCoinMode()==COIN_MODE_HOME and 
			GetSysConfig().AfterCautionTestInput and "IngameTestInput"

		or CurStyleName()~="none" and "StartGame"
		or Branch.PlayerEntry()
	end,

	InputTestNext=function()
		--Only in home mode.
		return Branch.PlayerEntry()
	end,

	PlayerEntryBack=function()
		return
			GetPref("CoinMode")==COIN_MODE_PAY and GAMESTATE:GetCoinsNeeded()>0 and Branch.FirstAttract()
			or Branch.Title()
	end,
	PlayerEntry=function() return "PlayerEntryNew" end,
	PlayerEntrySelection=function() return --GetPref("ShowCaution") and Branch.Caution() or --NOTE: Caution message can wait til sm5 theme catches up
	Branch.CautionNext() end, --gets evaluated on playerentry load

	CautionBack=function() return Branch.Title() end,
	Caution=function() return "Caution" end,
	CautionNext=function() return "StartGame" end,

	StartGame=function() --Called after picking a style in ScreenPlayerEntry.
		if IsNetwork() then GAMESTATE:SetTemporaryEventMode(true) ReportStyle() end
		if GetEnv("WorkoutMode") then GAMESTATE:SetTemporaryEventMode(true) Env().SelectedTab=2 end
		if GetSysConfig().StartOnFullMode or GetEnv("WorkoutMode") or IsAnyPlayerUsingProfile() then Env().FullMode=true end
		return SM_VERSION==5 and Branch.LoadProfiles() or Branch.AfterLoadProfiles()
	end,
	
	LoadProfiles=function() return "ProfileLoad" end,
	AfterLoadProfiles=function()
		return (GetEnv("SMOnline") or IsNetSMOnline()) and Branch.NetRoom()
			--or GAMESTATE:GetPlayMode()==PLAY_MODE_ENDLESS and "WorkoutMenu"
			or GetEnv("WorkoutMode") and "WorkoutMenu"
			or GetEnv("SuperMarathon") and "SelectSuperMarathon"
			or GetEnv("ManageProfiles") and "ManageProfiles"

			or FUCK_EXE and (Player(1) and UsingUSB(1) and PROFILEMAN:GetProfile(pNum[1]):GetTotalNumSongsPlayed()<1
				or Player(2) and UsingUSB(2) and PROFILEMAN:GetProfile(pNum[2]):GetTotalNumSongsPlayed()<1)
				and Branch.NameProfile()
			--or Branch.SelectCharacter()
			or Branch.SelectMusic()
	end,
	
	NameProfile=function() return "NameProfile" end,
	--AfterNameProfile=function() return Branch.SelectCharacter() end,
	AfterNameProfile=function() return Branch.SelectMusic() end,

	SelectCharacter=function() return "SelectCharacter" end,
	AfterSelectCharacter=function() return Branch.SelectMusic() end,
	
	SaveProfiles=function() return "ProfileSave" end, --does sm5 have a screen?

--Network:
	NetRoom=function() return (Player(1) and not IsSMOnlineLoggedIn(pNum[1]) or Player(2) and not IsSMOnlineLoggedIn(pNum[2])) and "SMOnlineLogin" or "NetRoom" end,

--Select Music
	SelectMusicBack=function()
		return StageIndex()>0 and Branch.NameEntry()
			--or IsAnyPlayerUsingMemoryCard() and Branch.SaveProfiles()
			or GetPref("CoinMode")==COIN_MODE_PAY and GAMESTATE:GetCoinsNeeded()>0 and Branch.FirstAttract()
			or Branch.Title()
	end,
	SelectMusic=function(course)
		return
			(IsNetwork() and "NetSelectMusic"
			or "SelectMusic"..((course or IsCourseMode()) and "Course" or GetEnv("PracticeMode") and "Practice" or "")
			)..(not GetSysConfig().MenuMusic and "Silent" or "")

	end,
	SelectMusicNext=function()
		--GetGoToOptions in SM5 returns true if user signalled intent to enter mods menu screen (ie, hit start twice, held start)
		return Song.GetDisplayBpms and (
				ScreenSelectMusic and ScreenSelectMusic.GetGoToOptions and GetScreen():GetGoToOptions() and Branch.SelectMusicModsPlayer()
				or Branch.Stage()
			)
			or "PlayerOptionsBPM"
	end, --Hack only needed for 3.95. PlayerOptionsBPM goes to Branch.Stage() anyway

--Select Course
	EnterCourseMode=function()
		GAMESTATE:ApplyGameCommand('playmode,nonstop')
		SetCourseSort(GetSysConfig().DefaultCourseSort or 2,false) --fall back to COURSE_SORT_METER_SUM
		return "EnterCourseModeIntermediate"
	end,

	EnterCourseModeIntermediate=function() return Branch.SelectMusic() end,

--Workout
	WorkoutMenuNext=function()
		--start
		Env().WorkoutState={
			Stage=1,
		}

		--load song queue
		Env().SongQueue={}
		for i=1,GetSysConfig().WorkoutSongsToPlay do
			local song,steps=GetRandomSongAndStepsByMeter(GetSysConfig().WorkoutDifficultyMin,GetSysConfig().WorkoutDifficultyMax)
			Env().SongQueue[i]={Song=song,Steps={steps,steps}}
		end

		--init first song
		assert(Env().SongQueue[1].Song)
		GAMESTATE:SetCurrentSong(Env().SongQueue[1].Song)
		ForeachPlayer(function(pn) GAMESTATE:SetCurrentSteps(pNum[pn],Env().SongQueue[1].Steps[pn]) end)

		GAMESTATE:SetTemporaryEventMode(true) --prevent hardcoded extra stage lifebar/forced mods

		return "PlayerOptionsBPM" --Branch.Stage() --"Gameplay"
	end,
	
	WorkoutGameplayNext=function()
		Env().WorkoutState.Stage=Env().WorkoutState.Stage+1

		local lastsong=Env().WorkoutState.Stage>GetSysConfig().WorkoutSongsToPlay
		if not lastsong then
			PrepareScreen("EvaluationStage") DeletePreparedScreens()

			local nextsong=Env().SongQueue[Env().WorkoutState.Stage]
			GAMESTATE:SetCurrentSong(nextsong.Song)
			ForeachPlayer(function(pn) GAMESTATE:SetCurrentSteps(pNum[pn],nextsong.Steps[pn]) end)

			local breakfreq=not GetPref("EndlessBreakEnabled") and 0 or GetPref("EndlessNumStagesUntilBreak")
			local needbreak=Env().WorkoutState.Stage>1 and breakfreq>0 and math.mod(Env().WorkoutState.Stage,breakfreq)==0
		end

		return needbreak and "WorkoutBreak"
			or lastsong and Branch.Evaluation() 
			--or lastsong and Branch.SummaryNext()
			or "PlayerOptionsBPM" --Branch.Stage() --"Gameplay"
	end,

	WorkoutBreakNext=function()
		--after break
		return Env().WorkoutState.Stage>GetSysConfig().WorkoutSongsToPlay and Branch.Evaluation() or "PlayerOptionsBPM"
	end,

--Super Marathon Mode
	SuperMarathonStartGame=function()
		Env().SuperMarathon.Stage=1	
	
		--load first song in queue
		assert(Env().SongQueue[1].Song)
		GAMESTATE:SetCurrentSong(Env().SongQueue[1].Song)
		ForeachPlayer(function(pn) GAMESTATE:SetCurrentSteps(pNum[pn],Env().SongQueue[1].Steps[pn]) end)

		GAMESTATE:SetTemporaryEventMode(true) --prevent hardcoded extra stage lifebar/forced mods

		return "PlayerOptionsBPM" --Branch.Stage() --"Gameplay"
	end,

	SuperMarathonGameplayNext=function()
		Env().SuperMarathon.Stage=Env().SuperMarathon.Stage+1
		PrepareScreen("EvaluationStage") DeletePreparedScreens() --commit score

		if GetScreen():GetChild("Debug"):GetText()==Metric("Gameplay","GiveUpText") then
			return Branch.Evaluation()
		elseif Env().SuperMarathon.Stage<=table.getn(Env().SongQueue) and OnePassed() then
			local nextsong=Env().SongQueue[Env().SuperMarathon.Stage]
			GAMESTATE:SetCurrentSong(nextsong.Song)
			ForeachPlayer(function(pn) GAMESTATE:SetCurrentSteps(pNum[pn],nextsong.Steps[pn]) end)
			return "PlayerOptionsBPM"
		else
			return Branch.Evaluation()
		end
	end,

--Mods Menu
	NewModsMenu=function() PrepareScreen("PlayerOptionsBPMModsMenu") DeletePreparedScreens() return "NewModsMenu" end,
	SelectMusicModsPlayer=function() PrepareScreen("PlayerOptionsBPMModsMenu") DeletePreparedScreens() return "PlayerOptionsBasic" end,
	--SelectMusicModsPlayer=function() PrepareScreen("PlayerOptionsBPMModsMenu") DeletePreparedScreens() return Env().FullMode and "SongOptionsMenu" or "PlayerOptionsBasic" end, --tabbed menu

	SelectMusicModsSong=function() PrepareScreen("PlayerOptionsBPMModsMenu") DeletePreparedScreens() return "PlayerOptionsPage2" end,
	--SelectMusicModsSong=function() PrepareScreen("PlayerOptionsBPMModsMenu") DeletePreparedScreens() return Env().FullMode and "SongOptionsMenu" or "PlayerOptionsBasic" end,
	
--Gameplay
	PlayerOptionsBPMNext=function() return Branch.Stage() end,

	StageBack=function() return Branch.GameplayBack() end,
	Stage=function() return "Stage" end,
	StageNext=function() return Branch.Gameplay() end,

	GameplayBack=function() return
		GAMESTATE:IsSyncDataChanged() and Branch.SaveSyncBack() or
		GetEnv("WorkoutMode") and "WorkoutMenu" or
		GetEnv("SuperMarathon") and "SelectSuperMarathon" or
		Branch.SelectMusic()
	end,
	Gameplay=function() return "Gameplay" end,
	GameplayNext=function() return
		GAMESTATE:IsSyncDataChanged() and Branch.SaveSync() or 
		GetEnv("WorkoutMode") and Branch.WorkoutGameplayNext() or
		GetEnv("SuperMarathon") and Branch.SuperMarathonGameplayNext() or
		Branch.Evaluation()
	end,

	SaveSyncBack=function() return "SaveSyncBack" end,
	AfterSaveSyncBack=function() return Branch.GameplayBack() end,
	SaveSync=function() return "SaveSync" end,
	AfterSaveSync=function() return Branch.GameplayNext() end,
	
--Evaluation
	EvaluationSuffix=function()
		Env().ResultsMusic=Env().ResultsMusic or clamp(math.ceil(math.random()*4),1,4)
		return not GetSysConfig().MenuMusic and "" or not OnePassed() and "Failed" or OneQuad() and "Quad" or tostring(Env().ResultsMusic)
	end,

	Evaluation=function()
		Env().ResultsMusic=clamp(math.ceil(math.random()*4),1,4)
		return IsNetConnected() and "NetEvaluation" or (
			GetEnv("WorkoutMode") and "EvaluationWorkout" --"NameEntry" --Branch.SummaryNext() --"EvaluationWorkout"
			or GetEnv("SuperMarathon") and "EvaluationSuperMarathon"
			or IsCourseMode() and "EvaluationCourse"
			or "EvaluationStage"
		)..Branch.EvaluationSuffix()
	end,

	EvaluationNext=function()
		return 
			IsNetSMOnline() and "NetRoom"
			or IsNetConnected() and "NetSelectMusic"
			or not (GetEnv("WorkoutMode") or GetEnv("SuperMarathon")) and (
				GetPref('EventMode')
				or (GetSysConfig().Timer and Timer.GetRemainingSeconds()>0)
				or not IsCourseMode() and OnePassed() and not FinalStage() --(not IsCourseMode() and NumStagesLeft()>0)
			)
			and Branch.SelectMusic()
			or Branch.NameEntry()
	end,

--Name Entry
	--NameEntry=function() return GAMESTATE:AnyPlayerHasRankingFeats() and "NameEntryDDR" or Branch.NameEntryNext() end,
	NameEntry=function() return "NameEntry"..Branch.EvaluationSuffix() end,
	NameEntryNext=function() return Branch.Ending() end,

	Ending=function() 
		PrepareScreen("Ending") DeletePreparedScreens()
		return GAMESTATE:GetCoinMode()==COIN_MODE_HOME and Branch.Title() or IsCourseMode() and "RankingCourses" or "RankingSongs"
	end,

--Misc
	SoundOptions=function() return "SoundOptions" .. (OPENITG and "OPENITG" or "") end,
	
	ExitServiceMenu=function() return "ExitServiceMenu" end,
	AfterExitServiceMenu=function()
		if GetEnv("LuaPrefsChanged") then PROFILEMAN:SaveMachineProfile() end
		PrepareScreen("TitleMenu") DeletePreparedScreens()
		return GAMESTATE:GetCoinMode()==COIN_MODE_HOME and Branch.Title() or Branch.FirstAttract()
	end,

	ExitManageProfiles=function() return "ManageProfilesSave" end,
	AfterExitManageProfiles=function() PrepareScreen("Ending") DeletePreparedScreens() return Branch.Title() end,

--Arcade
	Diagnostics=function() return "HardwareStatus" end
}
