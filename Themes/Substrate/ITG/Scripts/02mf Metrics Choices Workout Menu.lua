--[[
	WorkoutMenu=function() return { Contents={
		{Name="Workout", Type=3, Screen="ScreenWorkoutOptions", Contents={
			--These are shared for both players, but I want the settings to persist. Therefore, save on the machine profile.
			{RowType.LuaPrefNumber, 'WorkoutSongsToPlay', 1,'%d songs', {slow=1, fast=2, snap=5}, { min=1, max=50 },true},
			{RowType.Dummy,' '},
			{RowType.LuaPrefNumber, 'WorkoutDifficultyMin', 1,'%d', {slow=1, fast=2, snap=9}, { min=1, max=25 },true},
			{RowType.LuaPrefNumber, 'WorkoutDifficultyMax', 1,'%d', {slow=1, fast=2, snap=11}, { min=1, max=25 },true},
			{RowType.Dummy,' '},
			--Endless as a game type isn't used. Re-use the preferences for it.
			{RowType.PrefBool, 'EndlessBreakEnabled'},
			{RowType.PrefNumber,"EndlessNumStagesUntilBreak",1,"every %d songs",{slow=1,fast=2,snap=5},{min=1,max=100}},
			{RowType.PrefTime, 'EndlessBreakLength', {slow=1, fast=15, snap=5}, { min=1, max=6000 }},
		}},
		ModsPagesBasic()
	}} end

--]]

	WorkoutMenu=function()
		return {Name="Workout Menu", Contents={
			{Name="Workout Options", Type=3, Screen="WorkoutOptionsShared", Contents={
				--These are shared for both players, but I want the settings to persist. Therefore, save on the machine profile.
				{RowType.LuaPrefNumber, 'WorkoutSongsToPlay', 1,'%d songs', {slow=1, fast=2, snap=5}, { min=1, max=50 },true},
				{RowType.Dummy,' '},
				{RowType.LuaPrefNumber, 'WorkoutDifficultyMin', 1,'%d', {slow=1, fast=2, snap=9}, { min=1, max=25 },true},
				{RowType.LuaPrefNumber, 'WorkoutDifficultyMax', 1,'%d', {slow=1, fast=2, snap=11}, { min=1, max=25 },true},
				{RowType.Dummy,' '},
				--Endless as a game type isn't used. Re-use the preferences for it.
				{RowType.PrefBool, 'EndlessBreakEnabled'},
				{RowType.PrefNumber,"EndlessNumStagesUntilBreak",1,"every %d songs",{slow=1,fast=2,snap=5},{min=1,max=100}},
				{RowType.PrefTime, 'EndlessBreakLength', {slow=1, fast=15, snap=5}, { min=1, max=6000 }},
			}},
			{Name="Mods", Type=2, Screen="WorkoutOptions", Contents=ModsPagesBasic().Contents},
		}}
	end
