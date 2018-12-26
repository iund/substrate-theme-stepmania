
	CommonPaneDiffuseAlpha=0.8



-- 0-5 = beginner-challenge, -1 = invalid
	difficultyColors = {
		[0]={ 1,0,1,1 },
		[1]={ 0,1,0,1 },
		[2]={ 1,1,0,1 },
		[3]={ 1,0,0,1 },
		[4]={ 0,0.75,1,1 },
		[5]={ 0.75,0.75,0.75,1 },
		[-1]={ 0,0,0,1 }
	}

-- Colour tween alternates between colour values specified in [1] and [2]
-- Subtable: 1-3 = Fantastic, Excellent, Great

	ComboColours = {
		[1] = {
			[1] = function() return 0.78,1,1,1 end,
			[2] = function() return 0.99,1,0.79,1 end,
			[3] = function() return 1,1,1,1 end
		},
		[2] = {
			[1] = function() return 0.42,0.94,1,1 end,
			[2] = function() return 0.99,0.86,0.52,1 end,
			[3] = function() return 0.3,0.99,0.56,1 end
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

	UIColors={
		default={ --make the grey elements slightly blue to look nicer
		
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

		},
	}

	PlayerColors = {
		purple={0.75,0.5,1,1},
		pink	={1,.5,.75,1},
		blue	={.25,.75,1,1},
		teal	={0.25,1,1,1},
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

function GetSwatches()
--Desaturated colours matching the brightness of the corresponding grey areas?
--[[
	Possible swatches:

	name		r,g,b
	-----		-----
	purple	1,0,.5
	pink		1,0,1
	blue		.5,.5,1
	teal		0,.5,1
	green		0,1,0 (do light orange/'gold'?)
	yellow	1,1,0
	orange	1,.5,0
	red		1,0,0
	brown		1,.5,.25 (or dark beige/chocolate brown?)
	grey		.5,.5,.5

	+ room for another 5 (15 swatches total + random)

]]
end

--TODO2: What about the middle pane? Should that be coloured too?

