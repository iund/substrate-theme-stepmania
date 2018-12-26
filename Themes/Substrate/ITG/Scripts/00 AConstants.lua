--Notes:
--[[
Judge window mappings:

All have normal judge windows mapped except:

EZ2: perf,perf,perf,good,miss
BM: perf,perf,great,great,miss

normally: marv,perf,great,good,boo
]]

--Actor constants:
DRAW_ORDER_BEFORE_EVERYTHING	= -200
DRAW_ORDER_UNDERLAY				= -100
DRAW_ORDER_OVERLAY				=  100
DRAW_ORDER_TRANSITIONS			=  110
DRAW_ORDER_AFTER_EVERYTHING	=  200

--GAMESTATE:GetCurrentGame():GetName() (oITG/SM5, not 3.95) will return one of these. Corresponds to m_szName in source.
--CurGame is set as a global (from ScreenLogo) for convenience.
GameNames={"dance","pump","ez2","para","ds3ddx","bm","maniax","techno","pnm","lights"}

--StepsType[GAMESTATE:GetCurrentGame()+1][CurStyleName()]
StepsType={
	{single=STEPS_TYPE_DANCE_SINGLE,versus=STEPS_TYPE_DANCE_SINGLE,double=STEPS_TYPE_DANCE_DOUBLE,couple=STEPS_TYPE_DANCE_COUPLE,solo=STEPS_TYPE_DANCE_SOLO,["couple-edit"]=STEPS_TYPE_DANCE_COUPLE},
	{single=STEPS_TYPE_PUMP_SINGLE,versus=STEPS_TYPE_PUMP_SINGLE,halfdouble=STEPS_TYPE_PUMP_HALFDOUBLE,double=STEPS_TYPE_PUMP_DOUBLE,couple=STEPS_TYPE_PUMP_COUPLE},
	{single=STEPS_TYPE_EZ2_SINGLE,versus=STEPS_TYPE_EZ2_SINGLE,double=STEPS_TYPE_EZ2_DOUBLE,real=STEPS_TYPE_EZ2_REAL,versusReal=STEPS_TYPE_EZ2_REAL},
	{single=STEPS_TYPE_PARA_SINGLE,versus=STEPS_TYPE_PARA_VERSUS},
	{single=STEPS_TYPE_DS3DDX_SINGLE},
	{single5=STEPS_TYPE_BM_SINGLE5,double5=STEPS_TYPE_BM_DOUBLE5,single7=STEPS_TYPE_BM_SINGLE7,double7=STEPS_TYPE_BM_DOUBLE7},
	{single=STEPS_TYPE_MANIAX_SINGLE,versus=STEPS_TYPE_MANIAX_SINGLE,double=STEPS_TYPE_MANIAX_DOUBLE},
	{single4=STEPS_TYPE_TECHNO_SINGLE4,single5=STEPS_TYPE_TECHNO_SINGLE5,single8=STEPS_TYPE_TECHNO_SINGLE8,versus4=STEPS_TYPE_TECHNO_SINGLE4,versus5=STEPS_TYPE_TECHNO_SINGLE5,versus8=STEPS_TYPE_TECHNO_SINGLE8,double4=STEPS_TYPE_TECHNO_DOUBLE4,double5=STEPS_TYPE_TECHNO_DOUBLE5},
	{["pnm-five"]=STEPS_TYPE_PNM_FIVE,["pnm-nine"]=STEPS_TYPE_PNM_NINE},
	{cabinet=STEPS_TYPE_LIGHTS_CABINET}
}

--StepsTypeString[steps:GetStepsType()+1]
StepsTypeString = {
	"dance-single","dance-double","dance-couple","dance-solo",
	"pump-single","pump-halfdouble","pump-double","pump-couple",
	"ez2-single","ez2-double","ez2-real","para-single","para-versus","ds3ddx-single",
	"bm-single5","bm-double5","bm-single7","bm-double7","maniax-single","maniax-double",
	"techno-single4","techno-single5","techno-single8","techno-double4","techno-double5",
	"pnm-five","pnm-nine","lights-cabinet"
}

ValidStepsTypes={
	dance={"dance-single","dance-double","dance-couple","dance-solo"},
	pump={"pump-single","pump-halfdouble","pump-double","pump-couple"},
	ez2={"ez2-single","ez2-double","ez2-real"},
	para={"para-single"},
	ds3ddx={"ds3ddx-single"},
	bm={"bm-single5","bm-double5","bm-single7","bm-double7"},
	maniax={"maniax-single","maniax-double"},
	techno={"techno-single4","techno-single5","techno-single8","techno-double4","techno-double5"}, --no techno-double8
	pnm={"pnm-five","pnm-nine"},
	lights={"lights-cabinet"}
}

--StepsTypesNumLanes[steps:GetStepsType()+1]
StepsTypesNumLanes = {
	4,8,8,6, --dance
	5,6,10,10, --pump 
	5,10,7, --ez2
	5,10, --para
	8, --ds3ddx
	6,12,8,16, --bm
	4,8, --maniax
	4,5,8,8,10, --techno
	5,9, --pnm
	8 --lights
}--NUM_CABINET_LIGHTS

-- CurStyleName() will return one of these strings -
--[[
StyleNames =  {
	dance  = {"single","versus","double","couple","solo","couple-edit"}, --solo-versus is commented out in GameManager
	pump   = {"single","versus","halfdouble","double","couple","couple-edit"},
	ez2    = {"single","real","versus","versusReal","double"},
	para   = {"single","versus"},
	ds3ddx = {"single"},
	bm     = {"single5","double5","single7","double7"},
	maniax = {"single","versus","double"},
	techno = {"single4","single5","single8","versus4","versus5","versus8","double4","double5"},
	pnm    = {"pnm-five","pnm-nine"},
	lights = {"cabinet"},

	or "none" if style isn't set
}

--Master list for 3.95.
--PlayerEntryChoices[CurGame][GetNumPlayersEnabled()]
--"single", all pnm/lights styles, = one side, all others are two sides

PlayerEntryChoices = {
	dance  = {{{Style="single"},{Style="double"},{Style="solo"}},{{Style="versus"},{Style="couple"},{Style="couple-edit"}}}, --solo-versus is commented out in GameManager
	pump   = {{{Style="single"},{Style="halfdouble"},{Style="double"}},{{Style="versus"},{Style="couple"},{Style="couple-edit"}}},
	ez2    = {{{Style="single"},{Style="double"},{Style="real"}},{{Style="versus"},{Style="versusReal"}}},
	para   = {{{Style="single"}},{{Style="versus"}}},
	ds3ddx = {{{Style="single"}}},
	bm     = {{{Style="single5"},{Style="double5"}},{{Style="single7"},{Style="double7"}}},
	maniax = {{{Style="single"},{Style="double"}},{{Style="versus"}}},
	techno = {{{Style="single4"},{Style="single5"},{Style="single8"},{Style="double4"},{Style="double5"}},{{Style="versus4"},{Style="versus5"},{Style="versus8"}}},
	pnm    = {{{Style="pnm-five"},{Style="pnm-nine"}}},
	lights = {{{Style="cabinet"}}},
}

--]]

--DifficultyToString(diff) will return one of these strings
--DifficultyToThemedString
--StringToDifficulty(str) will accept one of these, plus 
DifficultyNames = { "Beginner","Easy","Medium","Hard","Challenge","Edit" } -- ,"Invalid" }
--CourseDifficultyToThemedString
CourseDifficultyNames = { "Beginner","Easy","Regular","Difficult","Challenge","Edit" }

--AvoidMine and None, although mentioned in GameConstantsAndTypes.cpp, are never triggered in game
JudgeNames =
	SM_VERSION==5
	and {"W0","W1","W2","W3","W4","Miss","OK","NG","HitMine"}
	or {"Marvelous","Perfect","Great","Good","Boo","Miss","OK","NG","HitMine"}

StatsNames = {"Jumps","Holds","Mines","Hands","Rolls"} --SM5 has Lifts and Fakes (who uses those?)

--Mods menu row types.
ROW_TYPE_SUBMENU=0
ROW_TYPE_LIST=1
ROW_TYPE_MULTI_LIST=2
ROW_TYPE_SLIDER=3
ROW_TYPE_BOOL=4
ROW_TYPE_DUMMY=5
ROW_TYPE_ACTION=6
ROW_TYPE_SCREEN=7
ROW_TYPE_COMMAND=8

--easier to flip the table upsidedown than manually add ="number"/="boolean" to every line.
local modtypes={
	number={

		--Accel mods [floats]",
		"Boost",
		"Brake",
		"Wave",
		"Expand",
		"Boomerang",
	
		--Note effects [floats]",
		"Drunk",
		"Dizzy",
		"Mini",
		"Flip",
		"Invert",
		"Tornado",
		"Tipsy",
		"Bumpy",
		"Beat",
	
		--Appearance [floats]",
		"Hidden",
		"HiddenOffset",
		"Sudden",
		"SuddenOffset",
		"Stealth",
		"Blink",
		"RandomVanish",

		--Scroll [floats]",
		"Reverse",
		"Split",
		"Alternate",
		"Cross",
		"Centered",
	
		"Blind",
		"Cover",
	
		"Passmark",
	
		"RandomSpeed",

		--Angles [floats]",
		--tbh you could just apply/check hallway percentage
		"Overhead", --applying Overhead will reset skew/tilt to 0
		"Distant",
		"Hallway",
		"Space",
		"Incoming",
	},
	boolean={

		--Careful. Dark is actually a float, but CodeMod handles it like a bool.
		"Dark",

		--Turns (bool)",
		"Mirror",
		"Left",
		"Right",
		"Shuffle",
		"SuperShuffle",
	
		--Transforms [bool]",
		"NoHolds",
		"NoRolls",
		"NoMines",
		"Little",
		"Wide",
		"Big",
		"Quick",
		"BMRize",
		"Skippy",
		"Mines",
		"Echo",
		"Stomp",
		"Planted",
		"Floored",
		"Twister",
		"NoJumps",
		"NoHands",
		"NoQuads",
		"NoStretch",
		
		"addscore",
		"subtractscore",
		"averagescore",
		"random"
	},
}
ModTypes={} for t,mod in next,modtypes,nil do ModTypes[mod]=t end

--]]

-- PlayModeToString(pm)
-- PlayModeName() will return one of these strings
-- call as PlayModeNames[pm+1]
PlayModeNames = { "Regular","Nonstop","Oni","Endless","Battle","Rave" }

PlayModeSM5Names={} for i=1,table.getn(PlayModeNames) do PlayModeSM5Names["PlayMode_"..PlayModeNames[i]]=PlayModeNames[i] end

-- Use any of these in the sort menu
SortOrderNames = {
	"Preferred","Group","Title","Bpm","Popularity","TopGrades","Artist","Genre","SongLength",
	"EasyMeter","MediumMeter","HardMeter","ChallengeMeter",
	"ModeMenu","AllCourses","Nonstop","Oni","Endless","RouletteCourse","Roulette",
}

-- GetStageText() will return one of these strings
StageNames = { "1", "2", "3", "4", "5", "6", "Final", "Extra1", "Extra2", "Nonstop", "Oni", "Endless", "Event", "Demo" }

-- Could this be useful anywhere?
GoalTypeNames = { "Calories","Time","None" }

-- PaneItems[IsCourseMode()]
PaneItems = {
	[false] = { --Regular,Battle,Rave
		"SongNumSteps", "SongJumps", "SongMines", "SongHolds", "SongRolls", "SongHands",
		"MachineHighScore", "MachineHighName", "ProfileHighScore",
	},
	[true] = { --Nonstop,Oni,Endless
		"CourseNumSteps", "CourseJumps", "CourseMines", "CourseHolds", "CourseRolls", "CourseHands",
		"CourseMachineHighScore", "CourseMachineHighName", "CourseProfileHighScore"
	}
}

PaneItemNames={
	"SongNumSteps",
	"SongJumps",
	"SongHolds",
	"SongRolls",
	"SongMines",
	"SongHands",
	"MachineHighScore",
	"MachineHighName",
	"ProfileHighScore",
	"CourseMachineHighScore",
	"CourseMachineHighName",
	"CourseProfileHighScore",
	"CourseNumSteps",
	"CourseJumps",
	"CourseHolds",
	"CourseMines",
	"CourseHands",
	"CourseRolls",	
}
