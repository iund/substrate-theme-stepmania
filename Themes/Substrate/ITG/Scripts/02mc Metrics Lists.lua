-- List of various options (gets used in multiple places in the code)

	-- I've removed the options that people never use.
	NoteSkinList={
		dance= {'metal','cel','flat'}, --'sm','smnote','smflat',"DivinEntity","DivinEntity-cel"}, --nobody uses vivid or robot
		
		pump= {"default","Classic",'new'},
		
		techno={'default',"new"},

		--I don't think anyone uses these game-types:
-- [[
		ds3ddx={'default'},
		ez2={'default','panic','stars','turtles'},
		maniax={'default'},
		para={'default','2ndmix','new'},
		pnm={'default'},
		bm={'default'},
--]]
		lights={'default'},
	}
	PerspectiveList = {'Overhead','Hallway','Distant'} --nobody sane uses Incoming or Space
	JudgeFontList = {'Default','GrooveNights','ITG2','Chromatic','EM2','Simply Love','SM','PeterNights'}
	
	MeasureTypes = {4,8,16,32} --TODO find a way round recurring decimal rounding errors and get 24ths working

-- Mods to persist on USB save
-- The game automatically saves these: speedmod, perspective, noteskin, "reverse","noholds","nomines","nojumps","nohands","noquads","nostretch"
	ModsSaveList = {
		{Name='Mini', Type='number', Min=-80, Max=175},
		{Name='Cover', Type='number', Min=0, Max=100}, 
		{Name='Blind', Type='boolean'},
		{Name='Dark', Type='boolean'},
	}

-- Selectable difficulties

	--SelectableDifficulties pertains to difficulty selection when no song is highlighted
	SelectableDifficulties = { "Beginner","Easy","Medium","Hard","Challenge" } --,"Edit" }

	--can't pick beginner, challenge, edit in game. also, why does survival also not let you pick difficult??????
	--FYI some survival courses are impassable on Easy (too few notes)
	SelectableCourseDifficulties = { "Regular","Difficult" }
	--SelectableCourseDifficulties = { "Easy","Regular","Difficult" }

-- ranking 

	RankingDifficulties = { "Easy","Medium","Hard","Challenge" } --,"Edit" }
	SongRankingShiftRowsLeft = 1
	SongRankingSpacingZoomX = 1

	RankingCourseDifficulties = { "Regular","Difficult" }
	CourseRankingShiftRowsLeft = 1.75
	CourseRankingSpacingZoomX = 0.65

	RankingSurvivalDifficulties={ "Regular" }
	SurvivalRankingShiftRowsLeft = 1.5 --these are trial and error values fyi
	SurvivalRankingSpacingZoomX = 1

--[[
	RankingCourseDifficulties = { "Regular","Difficult" }
	CourseRankingShiftRowsLeft = 0.75
	CourseRankingSpacingZoomX = 0.75

	RankingSurvivalDifficulties={ "Easy","Regular" }
	SurvivalRankingShiftRowsLeft = 0.8 --these are trial and error values fyi
	SurvivalRankingSpacingZoomX = 0.7
--]]
