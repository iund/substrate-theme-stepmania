

	ProfileManagementMenu=function() return
	{ Name="Manage Profile", Contents={

		{ Name='General', Screen="ScreenManageProfilesContents", Type=2, Contents={
			{RowType.GoalType,"Goal Type",1},
			{RowType.GoalNumber,"Goal Value",{slow=5, fast=60, snap=0},{ min=0, max=100000 }},
			{RowType.CaloriesBurnedInfo,"Calories Burned Today"},
			{RowType.TotalSongsPlayedInfo,"Songs Played"},
		}},
		{ Name="Grade Counts", Screen="ScreenProfileGradeStats" },
--[[
		{ Name="Ghost Data", Contents={
			{ Name="All Played", Contents=
				folder
					-> song
						-> steps
							-> list
								-> delete ghost
			
				( only populate folders etc with ghostdata present )
			},
			{ Name="Most Recently Played", Contents=
				view songs by most recently played
					-> delete ghost
			
			
			},
		
		
		}},
		{ Name="Rivals", Contents={
			( list of rivals)
				-> View Rival
					-> View All Songs
					-> View Mutually Played
						most recently played
						all played
					

				
				-> Delete Rival
				
				-> Add (if new and both sides are present)
--]]
	}} end
		--[[
GetTotalStepsWithTopGrade
			StepsType
			Difficulty
			Grade

	}} end
--]]
--[[

	Also TODO:
	
	
		Mods courses that are 2-player only.
		
		
		Use UNLOCKMAN to hide them in 1-player.

		iterate through list on game boot?
		use GameplaySetup() to check
		
		
		
	TODO:
	
	
	
	
	Profile Management

		General
		
			WeightPounds
			GoalType
			GoalCalories/Seconds
			
			GetCaloriesBurnedToday

			GetTotalNumSongsPlayed
			
			Grade Counts:
				Total Quads
				Total FECs
				Total Passes

		Ghost Data

			view song/steps
			delete ghost data for song/steps
		
		Manage Rivals
		
			view rivals list
			delete rival
			add rival from P1 side

	static int GetWeightPounds( T* p, lua_State *L )		{ lua_pushnumber(L, p->m_iWeightPounds ); return 1; }
	static int SetWeightPounds( T* p, lua_State *L )		{ p->m_iWeightPounds = IArg(1); return 0; }
	static int GetGoalType( T* p, lua_State *L )			{ lua_pushnumber(L, p->m_GoalType ); return 1; }
	static int SetGoalType( T* p, lua_State *L )			{ p->m_GoalType = (GoalType)IArg(1); return 0; }
	static int GetGoalCalories( T* p, lua_State *L )		{ lua_pushnumber(L, p->m_iGoalCalories ); return 1; }
	static int SetGoalCalories( T* p, lua_State *L )		{ p->m_iGoalCalories = IArg(1); return 0; }
	static int GetGoalSeconds( T* p, lua_State *L )			{ lua_pushnumber(L, p->m_iGoalSeconds ); return 1; }
	static int SetGoalSeconds( T* p, lua_State *L )			{ p->m_iGoalSeconds = IArg(1); return 0; }
	static int GetCaloriesBurnedToday( T* p, lua_State *L )	{ lua_pushnumber(L, p->GetCaloriesBurnedToday() ); return 1; }
	static int GetSaved( T* p, lua_State *L )				{ p->m_SavedLuaData.PushSelf(L); return 1; }
	static int GetTotalNumSongsPlayed( T* p, lua_State *L )	{ lua_pushnumber(L, p->m_iNumTotalSongsPlayed ); return 1; }
	static int IsCodeUnlocked( T* p, lua_State *L )			{ lua_pushboolean(L, p->IsCodeUnlocked(IArg(1)) ); return 1; }
	
	--returns a percentage value:
	static int GetSongsActual( T* p, lua_State *L )			{ lua_pushnumber(L, p->GetSongsActual((StepsType)IArg(1),(Difficulty)IArg(2)) ); return 1; }
	static int GetCoursesActual( T* p, lua_State *L )		{ lua_pushnumber(L, p->GetCoursesActual((StepsType)IArg(1),(CourseDifficulty)IArg(2)) ); return 1; }
	static int GetSongsPossible( T* p, lua_State *L )		{ lua_pushnumber(L, p->GetSongsPossible((StepsType)IArg(1),(Difficulty)IArg(2)) ); return 1; }
	static int GetCoursesPossible( T* p, lua_State *L )		{ lua_pushnumber(L, p->GetCoursesPossible((StepsType)IArg(1),(CourseDifficulty)IArg(2)) ); return 1; }
	
	--PercentComplete = just Actual / Possible
	static int GetSongsPercentComplete( T* p, lua_State *L )	{ lua_pushnumber(L, p->GetSongsPercentComplete((StepsType)IArg(1),(Difficulty)IArg(2)) ); return 1; }
	static int GetCoursesPercentComplete( T* p, lua_State *L )	{ lua_pushnumber(L, p->GetCoursesPercentComplete((StepsType)IArg(1),(CourseDifficulty)IArg(2)) ); return 1; }

	--grade counts
	static int GetTotalStepsWithTopGrade( T* p, lua_State *L )	{ lua_pushnumber(L, p->GetTotalStepsWithTopGrade((StepsType)IArg(1),(Difficulty)IArg(2),(Grade)IArg(3)) ); return 1; }
	static int GetTotalTrailsWithTopGrade( T* p, lua_State *L )	{ lua_pushnumber(L, p->GetTotalTrailsWithTopGrade((StepsType)IArg(1),(CourseDifficulty)IArg(2),(Grade)IArg(3)) ); return 1; }


		ADD_METHOD( GetWeightPounds )
		ADD_METHOD( SetWeightPounds )
		ADD_METHOD( GetGoalType )
		ADD_METHOD( SetGoalType )
		ADD_METHOD( GetGoalCalories )
		ADD_METHOD( SetGoalCalories )
		ADD_METHOD( GetGoalSeconds )
		ADD_METHOD( SetGoalSeconds )
		ADD_METHOD( GetCaloriesBurnedToday )
		ADD_METHOD( GetSaved )
		ADD_METHOD( GetTotalNumSongsPlayed )
		ADD_METHOD( IsCodeUnlocked )
		ADD_METHOD( GetSongsActual )
		ADD_METHOD( GetCoursesActual )
		ADD_METHOD( GetSongsPossible )
		ADD_METHOD( GetCoursesPossible )
		ADD_METHOD( GetSongsPercentComplete )
		ADD_METHOD( GetCoursesPercentComplete )
		ADD_METHOD( GetTotalStepsWithTopGrade )
		ADD_METHOD( GetTotalTrailsWithTopGrade )


--]]