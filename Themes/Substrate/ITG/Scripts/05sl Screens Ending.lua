Screens.Ending={
		Init=function(s) Rival.SaveProfiles() SaveProfile() ForeachPlayer(function(pn) Broadcast("ShowGameOverP"..pn) end) --[[Screens.Attract.Init(s)]] FitScreenToAspect(s) end,
		On=function(s) end,
		FirstUpdate=function(s) end, --PROFILEMAN:SaveMachineProfile() end,
		Off=function(s) Scores=nil end,
	}