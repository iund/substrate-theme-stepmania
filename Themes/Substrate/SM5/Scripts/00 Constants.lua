-- constants
Bool={[false]=false, [true]=true}

PlayerIndex={[PLAYER_1]=1,[PLAYER_2]=2, [1]=PLAYER_1,[2]=PLAYER_2} --use to convert both ways

DifficultyIndex={
	Difficulty_Beginner  = 0, [0]="Difficulty_Beginner",
	Difficulty_Easy      = 1, [1]="Difficulty_Easy",
	Difficulty_Medium    = 2, [2]="Difficulty_Medium",
	Difficulty_Hard      = 3, [3]="Difficulty_Hard",
	Difficulty_Challenge = 4, [4]="Difficulty_Challenge",
	Difficulty_Edit      = 5, [5]="Difficulty_Edit",
	Difficulty_Invalid   = 7, [7]="Difficulty_Invalid"
}

CommonPaneDiffuseAlpha=0.8

-- 4:3 scaling factors:
ASPECT_ADJUST_NARROW_FACTOR=SCREEN_WIDTH/(SCREEN_HEIGHT*(16/9)) --1 for 16:9, 0.75 for 4:3
ASPECT_ADJUST_WIDE_FACTOR=(SCREEN_HEIGHT*(4/3))/SCREEN_WIDTH   --1 for 4:3, 1.5 for 16:9

-- 0-5 = beginner-challenge, -1 = invalid
	DifficultyColors = {
		Difficulty_Beginner  = { 1,0,1,1 },
		Difficulty_Easy      = { 0,1,0,1 },
		Difficulty_Medium    = { 1,1,0,1 },
		Difficulty_Hard      = { 1,0,0,1 },
		Difficulty_Challenge = { 0,0.75,1,1 },
		Difficulty_Edit      = { 0.75,0.75,0.75,1 },
		Difficulty_Invalid   = { 0,0,0,1 }
	}

-- Colour tween alternates between colour values specified in [1] and [2]
-- Subtable: 1-3 = Fantastic, Excellent, Great

	ComboColours = {
		[1] = {
			[1] = {0.78,1,1,1},
			[2] = {0.99,1,0.79,1},
			[3] = {1,1,1,1},
		},
		[2] = {
			[1] = {0.42,0.94,1,1},
			[2] = {0.99,0.86,0.52,1},
			[3] = {0.3,0.99,0.56,1}
		}
	}

	JudgeColours={
		{0.42,0.94,1,1},				--fantastic
		{0.99,0.86,0.52,1},			--excellent
		{0.3,0.99,0.56,1},			--great
		{0.5,0.1,0.8,1},				--decent
		{0,0,0,0},						--wayoff (unused)
		{0.9,0.1,0.1,1},				--miss
		{0.8,0.6,0.4,1},				--ok
		{0.9,0.3,0.3,1},				--ng
		{1,0.5,0,1},					--hitmine
	}

	UIColors={ --make the grey elements slightly blue to look nicer
		
	--attract:
	--Ranking:
		RankingPane={.8,.9,1,1},
		RankingEntry={.9,.95,1,1},

	--Title
		PlatformLarge={.9,.95,1,1},

	--Player entry
		PlayerEntryPaneUnjoined={.8,.9,1,1},
		PlayerEntryPaneJoined={.9,.95,1,1},
		
		PlayerEntryPanePlatformActive={.9,.95,1,1},
		PlayerEntryPanePlatformInactive={.9,.95,1,1},
	
	--Selectmusic
		MusicWheelItemSong={.7,.75,.8,1},
		SelectMusicSongInfoBar={.2,.225,.25,1},
		SelectMusicHelpPopup={.2,.225,.25,1},
	
	--Gameplay
		TrafficLight={.8,.9,1,1},
		
		LifebarCapTop={.15,.3,.45,1},
		LifebarCapBottom={.15,.3,.45,1},
		LifebarBackground={.15,.175,.2,1},
		
		ProgressBackground={.15,.175,.2,1},
		ProgressFill={.3,.35,.4,1},

	--Evaluation
		EvaluationSongInfoBar={.2,.225,.25,1},

	}

	PlayerColors = {
		purple={0.75,0.5,1,1},
		pink	={1,.5,.75,1},
		blue	={.25,.75,1,1},
		teal	={0.5,.75,.75,1},
		green	={.5,1,.5,1},
		yellow={1,1,.5,1},
		orange={1,.5,0,1},
		red	={1,.25,.25,1},
		brown	={1,.75,.5,1},
		grey	={.75,.75,.75,1},
	}
	
	PlayerTextColors={
		purple={1,1,1,1},
		pink	={0,0,0,1},
		blue	={1,1,1,1},
		teal	={0,0,0,1},
		green	={0,0,0,1},
		yellow={0,0,0,1},
		orange={0,0,0,1},
		red	={0,0,0,1},
		brown	={1,1,1,1},
		grey	={0,0,0,1},
	}
	
--all the net screens use sample colors for testing

	NetRoomColors={
		New={1.0,0.4,0.4,1.0},
		Open={0.5,0.5,1.0,1.0},
		Password={0.5,1.0,0.5,1.0},
		Busy={1.0,0.5,0.5,1.0},
	}
	
	NetPlayerBoxColor={0.2,0.4,0.6,0.5}

	NetPlayerStatusColors={
		Inactive={1.0,0.4,0.4,1.0},
		Inactiveundefined={1.0,1.0,1.0,1.0},
		NetScreen={0.5,0.5,1.0,1.0},
		Options={0.5,1.0,0.5,1.0},
		Evaluation={1.0,0.5,0.5,1.0},
	}
