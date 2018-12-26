--[[ The game automatically saves these mods:
		speed mod
		reverse
		perspective
		NoHolds, NoRolls, NoMines, NoJumps, NoHands, NoQuads, NoStretch (sm5 adds NoLifts, NoFakes)
		score display type (except sm5)
		noteskin
		(sm5: MuteOnError)
--]]

--Simple mode.
	--NOTE: Make this match the sm5 one for now.
	ModsPagesBasic=function() return { Name="Mods", Type=2, Contents=
		{
			{RowType.SpeedModType, 'SpeedModType',1}, --update row 2 when you change this
			{RowType.SpeedMod, 'Speed', {slow=5, fast=20}, {min=25, max=1300} },
			{RowType.ModNumber, 'Mini', 1,'%d%%', {slow=1, fast=2, snap=0}, { min=-80, max=175 }},
			{RowType.Noteskin, 'Noteskins', NoteSkinList[CurGame] },
			{RowType.ModsList, 'Persp', PerspectiveList, false,false }, --{RowType.ModNumber, 'Hallway', 1, '%d%%', {slow=10, fast=20, snap=0}, { min=-100, max=100 }},
			{RowType.ModNumber, 'Cover', 1,'%d%%', {slow=10, fast=100, snap=0}, { min=0, max=100 }}, --{RowType.ModsBool, 'Cover', false},
			{RowType.RateMod, 'MusicRate',false,false,{1,2}},
			{RowType.InfoBPM, 'Tempo',false},
			{RowType.InfoLength, 'Length',false},
			{not IsCourseMode() and RowType.Steps or RowType.Trail,'Difficulty'}, --RowType.Trail crashes
			{RowType.ModsBool, 'Reverse',false },
			{RowType.ModsList, 'Hide', {'Stealth','Hidden','Sudden'}, false,true,false },

		}} end

--[[
		ModsPagesBasic=function() return { Name="Mods", Type=2, Contents=
		Env().FullMode and table.concati({
			--full
			{RowType.SpeedModType, 'SpeedModType',1}, --update row 2 when you change this
			{RowType.SpeedMod, 'Speed', {slow=5, fast=20}, {min=25, max=1300} },
			{RowType.ModNumber, 'Mini', 1,'%d%%', {slow=1, fast=2, snap=0}, { min=-80, max=175 }},
			{RowType.Noteskin, 'Noteskins', NoteSkinList[CurGame] },
			{RowType.ModsList, 'Persp', PerspectiveList, false,false }, --{RowType.ModNumber, 'Hallway', 1, '%d%%', {slow=10, fast=20, snap=0}, { min=-100, max=100 }},
			{RowType.JudgeFontList, 'JudgeFont', JudgeFontList, true, false},
			{RowType.ModNumber, 'Cover', 1,'%d%%', {slow=10, fast=100, snap=0}, { min=0, max=100 }}, --{RowType.ModsBool, 'Cover', false},

--			{RowType.ModsList, 'LifebarMode', {"normal-drain","norecover","suddendeath"}, false,false,true},

--			{RowType.Weight,"Weight",{slow=5, fast=20, snap=150}, { min=20, max=1000 }},
--			{RowType.GoalType,"Goal Type",1},
--			{RowType.GoalNumber,"Goal Value",{slow=15, fast=150, snap=0}, { min=0, max=10000 }},
		},
		not GetEnv("WorkoutMode") and {
			{RowType.RateMod, 'MusicRate',false,false,{1,2}},
			{RowType.InfoBPM, 'Tempo',false},
			{RowType.InfoLength, 'Length',false},
		} or {
			{RowType.RateMod, 'MusicRate',false,false,false},
		},
		IsCourseMode() and table.concati({
			--course
			--There really isn't anything you're able to do in course mode (in 3.95/oITG it's INCREDIBLY gimped)
			{RowType.TrailInfo,'Difficulty'}, --this is read only - trail gamecommand doesn't work.
			{RowType.Breakdown,"Measure Type"},
		},GetSysConfig().EnableRivals and {
			{RowType.RivalList,"Rival",{1,2}},
			{RowType.Rival.GhostInfoRival,"Rival's Best"},
			{RowType.Rival.GhostInfoPlayer,"My Best"},
		} or {}) or not GetEnv("WorkoutMode") and table.concati({
			--song
			{RowType.Steps,'Stepchart',{1,3,5}},
			{RowType.ChartDescription,"Description"},
			{RowType.Breakdown,"Measure Type",1},
			{RowType.BreakdownInfo,"Breakdown"},
			-- "list,Characters", --commented out because characters do not save to your profile
		},GetSysConfig().EnableRivals and {
			{RowType.RivalList,"Rival",{1,2}},
			{RowType.Rival.GhostInfoRival,"Rival's Best"},
			{RowType.Rival.GhostInfoPlayer,"My Best"},
		} or {}) or {
			--workout
			{RowType.Breakdown,"Measure Type",1},
		}) or {
			--simple mode. Only put important mods in here 
			{RowType.SpeedMod, 'Speed', {slow=25, fast=50}, {min=50, max=800}, true,1}, --use whatever is the default speedmod type.
			{RowType.InfoSpeedXModBPM, 'Tempo'},
			{RowType.ModsList, 'Persp', PerspectiveList, false,false },
			{RowType.Noteskin, 'Noteskins', NoteSkinList[CurGame] },
			{RowType.ModNumber, 'Mini', 1,'%d%%', {slow=5, fast=10, snap=50}, { min=0, max=100 }},
			{RowType.ModsBool, 'Little',false },
			{RowType.ModsBool, 'Reverse',false },
			{RowType.ModsList, 'Turn', {'Mirror','Left','Right','Shuffle'}, false,true,false },
			{RowType.Steps, 'Difficulty',false},
		}}
	end
--]]
	ModsPagesBasicPage2=function() return { Name="Mods", Type=2, Contents=table.concati(
		{
			{RowType.Color, 'Colour', GetPlayerColorList(), true, false},
			{RowType.EnvList, 'JudgeAnimation', {'Small','Medium','Big','Static'}, false, false},
			{RowType.EnvList, 'ComboColour', {'Midpoint','SongStart','ComboStart','Off'}, false, false},
			{RowType.EnvBool, 'HideCombo'},
			{RowType.EnvBool, 'HideHoldJudge'},
			{RowType.EnvBool, 'StatsDisplay'},
                }, Judgment and Judgment.GetNoteOffset and {
                        {RowType.EnvBool, 'TimingBar'}, 
                } or {},
		{
			{RowType.ModsBool, 'Dark',false },
			{RowType.ModsBool, 'Blind',false },
			{RowType.ModNumber, 'Flip', 1,'%d%%', {slow=1, fast=2, snap=0}, { min=-100, max=200 }},
			{RowType.ModsList, 'Turn', {'Mirror','Left','Right','Shuffle','SuperShuffle'}, false,true,false },
			{RowType.ModsBool, 'Reverse',false },
			{RowType.ModsList, 'Hide Notes', {'Stealth','Hidden','Sudden'}, false,true,false },
			{RowType.ModsList, 'Remove Notes', {"Little","NoJumps","NoHands","NoQuads","NoStretch","NoMines"}, false,true,false },
			{RowType.ModsList, 'Remove Holds', {"NoHolds","NoRolls"}, false,true,false },
--[[ commenting these out, because these affect the score counter.
			{RowType.ModsList, 'Add Notes', {"Stomp","Wide","Big","Quick","Skippy","BMRize","Echo","Mines"}, false,true,false },
			{RowType.ModsList, 'Add Holds', {"Planted","Floored","Twister"}, false,true,false },
--]]
			{RowType.ModsList, 'Note Effects', {'Drunk','Dizzy','Invert',"Tornado","Tipsy","Beat","Bumpy"}, false,true,false },
			{RowType.ModsList, 'Scroll Effects', {'Boost','Brake','Wave',"Expand","Boomerang"}, false,true,false },
			--room for 1 more row?
		})
			
			--[[ Todo rows:
		
				Live Stats pane
				Timing Bar
				NPS Display
				Goal?
				Background Type (animated / static)
			
			--]]
	} end

	--[[
	--New mods menu:
	NewModsPages=function() return { Contents={
		{ Name="Player Mods", Contents={
			{RowType.SpeedModType, 'SpeedModType'}, --,2}, --update row 2 when you change this
			{RowType.SpeedMod, 'Speed', {slow=5, fast=20}, {min=5, max=2560} },
			{RowType.ModNumber, 'Mini', 1,'%d%%', {slow=1, fast=2, snap=0}, { min=-80, max=175 }},
			{RowType.Noteskin, 'Noteskins', NoteSkinList[CurGame] },
			{RowType.ModsList, 'Persp', PerspectiveList, false,false }, --{RowType.ModNumber, 'Hallway', 1, '%d%%', {slow=10, fast=20, snap=0}, { min=-100, max=100 }},
			{RowType.ModsBool, 'Cover', false},
			{RowType.JudgeFontList, 'JudgeFont', JudgeFontList, true, false},
			{RowType.EnvList, 'JudgeAnimation', {'Small','Medium','Big','Static'}, false, false},
			{RowType.EnvBool, 'HideHoldJudge'},
			{RowType.EnvBool, 'HideCombo'},
			{RowType.EnvList, 'ComboColour', {'Midpoint','SongStart','ComboStart','Off'}, false, false},
			{RowType.EnvList, 'Colour', GetPlayerColorList(), true, false},
		}},
		{ Name="Song Mods", Contents={
			{RowType.RateMod, 'MusicRate'},
			{RowType.InfoBPM, 'Tempo'},
			{RowType.InfoLength, 'Length'},
			{RowType.ModsList, 'LifebarMode', {"normal-drain","norecover","suddendeath"}, false,false,true},
		}},
		{ Name="Chart", Contents=
			not IsCourseMode() and {
				{RowType.Steps, 'Stepchart'},
				{RowType.ChartDescription,"Description"},
				{RowType.Breakdown,"Measure Type",4},
				{RowType.BreakdownInfo,"Breakdown"},
				{RowType.RivalList,"Rival",6},
				{RowType.Rival.GhostInfoPlayer,"My Best"},
				{RowType.Rival.GhostInfoRival,"Rival's Best"},
			} or {
				{RowType.TrailInfo, 'Difficulty'}, --this is read only - trail gamecommand doesn't work.
				{RowType.Breakdown,"Measure Type"},
				{RowType.RivalList,"Rival",4},
				{RowType.Rival.GhostInfoPlayer,"My Best"},
				{RowType.Rival.GhostInfoRival,"Rival's Best"},
			}
		},
		{ Name="Effects", Contents={
			{RowType.ModsList, 'Scroll', {"Reverse","Split","Alternate","Cross","Centered"}, true,false,false },
			{RowType.ModsList, 'Turn', {'Left','Right','Mirror','Shuffle','SuperShuffle'}, true,false,false },
			{RowType.ModNumber, 'Flip', 1,'%d%%', {slow=1, fast=2, snap=0}, { min=-100, max=200 }},
			{RowType.ModsList, 'Hide Notes', {'Hidden','Sudden','Stealth','Blink'}, true,false,false },
			{RowType.ModsList, 'Remove Notes', {"Little","NoMines","NoJumps","NoHands","NoQuads","NoStretch"}, true,false,false },
			{RowType.ModsList, 'Remove Holds', {"NoHolds","NoRolls"}, true,false,false },
			{RowType.ModsList, 'Add Notes', {"Wide","Big","Quick","BMRize","Skippy","Mines","Echo"}, true,false,false },
			{RowType.ModsList, 'Add Holds', {"Planted","Floored","Twister"}, true,false,false },
			{RowType.ModsList, 'X Effects', {'Drunk','Dizzy','Invert',"Tornado","Tipsy","Beat"}, true,false,false },
			{RowType.ModsList, 'Y Effects', {'Boost','Brake','Wave',"Expand","Boomerang"}, true,false,false },
			{RowType.ModsList, 'Z Effects', {"Bumpy"}, true,false,false },
		}},
	}} end
--]]
	--Full mode.
	ModsPages=function() return { Contents={
		{ Name="Mods", Type=2, Screen="ScreenPlayerOptions", Contents={
			{RowType.SpeedModType, 'SpeedModType'}, --,2}, --update row 2 when you change this
			{RowType.SpeedMod, 'Speed', {slow=5, fast=20}, {min=5, max=2560} },
			{RowType.ModNumber, 'Mini', 1,'%d%%', {slow=1, fast=2, snap=0}, { min=-80, max=175 }},
			{RowType.Noteskin, 'Noteskins', NoteSkinList[CurGame] },
			{RowType.ModsList, 'Persp', PerspectiveList, false,false }, --{RowType.ModNumber, 'Hallway', 1, '%d%%', {slow=10, fast=20, snap=0}, { min=-100, max=100 }},
			{RowType.JudgeFontList, 'JudgeFont', JudgeFontList, true, false},
			{RowType.ModsBool, 'Cover', false},
			{RowType.EnvBool, 'HideHoldJudge'},
			{RowType.EnvList, 'JudgeAnimation', {'Small','Medium','Big','Static'}, false, false},
			{RowType.EnvList, 'ComboColour', {'Midpoint','SongStart','ComboStart','Off'}, false, false},
			{RowType.EnvList, 'Colour', GetPlayerColorList(), true, false},
		}},
--[[
		--{RowType.EnvList, 'JudgeTrackState', {'Combo','Counters','Both','Hide Combo'}, false, false},
--]]

		{ Name="Chart", Type=2, Screen="ScreenPlayerOptions", Contents=
			not IsCourseMode() and
		{
			{RowType.Steps, 'Stepchart',true}, --last number = row to update on change
			{RowType.ChartDescription,"Description"},
			{RowType.Breakdown,"Measure Type",1},
			{RowType.BreakdownInfo,"Breakdown"},
			{RowType.RivalList,"Rival",1},
			{RowType.Rival.GhostInfoPlayer,"My Best"},
			{RowType.Rival.GhostInfoRival,"Rival's Best"},
		} or {
			{RowType.TrailInfo, 'Difficulty'}, --this is read only - trail gamecommand doesn't work.
			{RowType.Breakdown,"Measure Type"},
			--There really isn't anything you're able to do in course mode (in 3.95/oITG it's INCREDIBLY gimped)
			{RowType.RivalList,"Rival",1},
			{RowType.Rival.GhostInfoPlayer,"My Best"},
			{RowType.Rival.GhostInfoRival,"Rival's Best"},
		}},
		{ Name="Song", Type=3, Screen="ScreenSongOptions", Contents={
			--Shared options between players:
			{RowType.RateMod, 'MusicRate',nil,nil,1},
			{RowType.InfoBPM, 'Tempo'},
			{RowType.InfoLength, 'Length'},
			--{RowType.ModsList, 'LifebarType', {"bar","battery","lifetime"}, false,false,true},
			{RowType.ModsList, 'LifebarMode', {"normal-drain","norecover","suddendeath"}, false,false,true},
			--{RowType.ModsBool, 'savescore', true},
			--{RowType.EnvBool, 'CourseProgress', nil, true},

			--{RowType.JudgeWindow,"Timing",false},
			{RowType.BatteryLives,"Lives",{slow=1,fast=5,snap=4},{min=1,max=1000}},
		}},
		{ Name="Effect", Type=2, Screen="ScreenPlayerOptions", Contents={
			{RowType.ModsList, 'Scroll', {"Reverse","Split","Alternate","Cross","Centered"}, false,true,false },
			{RowType.ModsList, 'Turn', {'Left','Right','Mirror','Shuffle','SuperShuffle'}, false,true,false },
			{RowType.ModNumber, 'Flip', 1,'%d%%', {slow=1, fast=2, snap=0}, { min=-100, max=200 }},
			{RowType.ModsList, 'Hide Notes', {'Hidden','Sudden','Stealth','Blink'}, false,true,false },
			{RowType.ModsList, 'Remove Notes', {"Little","NoMines","NoJumps","NoHands","NoQuads","NoStretch"}, false,true,false },
			{RowType.ModsList, 'Remove Holds', {"NoHolds","NoRolls"}, false,true,false },
			{RowType.ModsList, 'Add Notes', {"Wide","Big","Quick","BMRize","Skippy","Mines","Echo"}, false,true,false },
			{RowType.ModsList, 'Add Holds', {"Planted","Floored","Twister"}, false,true,false },
			{RowType.ModsList, 'X Effects', {'Drunk','Dizzy','Invert',"Tornado","Tipsy","Beat"}, false,true,false },
			{RowType.ModsList, 'Y Effects', {'Boost','Brake','Wave',"Expand","Boomerang"}, false,true,false },
			{RowType.ModsList, 'Z Effects', {"Bumpy"}, false,true,false },
		}},
	}} end
	
	--Edit menus
	ModsPagesPlayerEdit=function() return {Contents={
		{RowType.SpeedModType, 'SpeedModType',1}, --update row 2 when you change this
		{RowType.SpeedMod, 'Speed', {slow=5, fast=20}, {min=5, max=2560} },
		{RowType.ModNumber, 'Mini', 1,'%d%%', {slow=1, fast=2, snap=0}, { min=-80, max=175 }},
		{RowType.Noteskin, 'Noteskins', NoteSkinList[CurGame] },
		{RowType.ModsList, 'Persp', PerspectiveList, false,false }, --{RowType.ModNumber, 'Hallway', 1, '%d%%', {slow=10, fast=20, snap=0}, { min=-100, max=100 }},
		{RowType.ModsBool, 'Reverse',false },
	}} end
	ModsPagesSongEdit=function() return {Contents={
		{RowType.RateMod, 'MusicRate',{slow=0.1, fast=0.1, snap=1},{ min=0.2, max=2 },2},
		{RowType.InfoBPM, 'Tempo'},
		{RowType.InfoLength, 'Length'},
	}} end


	JukeboxMenu=function() return { Type=3, Contents={
		--			{Name="Styles",
		--Line1=list,Styles
		--Line2=list,Groups
		--Line3=list,Difficulties
		{RowType.ModsBool,"random",true},
	}} end
