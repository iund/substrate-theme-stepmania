-- Actions for codes in ScreenSelectMusic

-- Notes:
-- Menu L+R activates full mode. It can then be used to open the sort menu.
-- In simple mode, most of the codes are disabled (they're not necessary)

	--make it a function because OnlyDedicatedMenuButtons can be changed in the service menu.

	CodeModList = function() return {
		dark         = { Code = not Env().FullMode and "MenuLeft+MenuRight" or "", Action = function(pn) Env().FullMode=true GameCommand("songgroup,--ALL MUSIC--;sort,Group") SetScreen(Branch.SelectMusic(false)) end },
		left         = { Code = not Env().FullMode and '' or '', Action = function(pn) end },
		right        = { Code = not Env().FullMode and '' or 'Select', Action = function(pn) Env().SongMods.ShowFolder=not Env().SongMods.ShowFolder end },
		nomines      = {
			Code = '', -- (NOTE: Don't use pages just yet until the sm5 theme catches up) Code = Env().FullMode and GetPref('OnlyDedicatedMenuButtons') and 'Right,Right' or '',
			--Code = Env().FullMode and GetPref('OnlyDedicatedMenuButtons') and (IsArcade() and 'Right,Right' or 'Right') or '',
			Action = function(pn) if not IsCourseMode() then CustomDifficultyList.CycleDifficultyDisplay(pn,1) end end },
		noholds      = { Code = not Env().FullMode and '' or '', Action = function(pn) Env().SongMods.LiveBPM=not Env().SongMods.LiveBPM end },
		mirror       = {
			Code = '', -- (NOTE: Don't use pages just yet until the sm5 theme catches up) Code = Env().FullMode and GetPref('OnlyDedicatedMenuButtons') and 'Left,Left' or '',
			--Code = Env().FullMode and GetPref('OnlyDedicatedMenuButtons') and (IsArcade() and 'Left,Left' or 'Left') or '',
			Action = function(pn) if not IsCourseMode() then CustomDifficultyList.CycleDifficultyDisplay(pn,-1) end end },
		shuffle      = { Code = not Env().FullMode and '' or '', Action = function(pn) end },
		supershuffle = { Code = not Env().FullMode and '' or '', Action = function(pn) end }
	} end

	--General codes. Gets refreshed on SSM load/exit.
	Codes = function() return {

		--SSM:
		Easier	= {"Up,Up","MenuUp"}, --Easier	= {IsArcade() and "Up,Up" or "Up","MenuUp"},
		Harder	= {"Down,Down","MenuDown"}, --Harder	= {IsArcade() and "Down,Down" or "Down","MenuDown"},
		SortMenu	= not Env().FullMode and {"",""} or {"Up,Down,Up,Down", IsSelectButtonAvailable() and "Select+Start" or "MenuLeft+MenuRight"},
		OptionsListOpen={"Select","MenuLeft,MenuRight,MenuLeft,MenuRight,MenuLeft,MenuRight"}, --sorta like Pump but with the menu keys

		--ScreenPlayerOptions:
		CancelMods="Left,Right,Left,Right,Left,Right,Left,Right",
		
		--Eval:
		Screenshot={"Select",IsSelectButtonAvailable() and "" or "MenuLeft+MenuRight"},

		--General:
		BackInEventMode={IsBackShortcutEnabled() and "Select+Start" or "","MenuLeft,MenuLeft,MenuRight,MenuRight,MenuLeft,MenuLeft,MenuRight,MenuRight"},

		--UserPacks:
		LinkedMenuSwitch={"Select","MenuLeft+MenuRight"},

		--Title: (home mode only)
		NextGame={"",""}, --(IsArcade() or not GetPref('OnlyDedicatedMenuButtons')) and {"",""} or {"","Left,Right,Left,Right,Left,Right"}, --cycles through game types (hardcoded list)

	} end
