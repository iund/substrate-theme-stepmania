Screens.PlayerEntry={
		Init=function(s)
			--FitScreenToAspect(s)
		end,
		On=function(s)

		end,
		FirstUpdate=function(s) 

		end,
		PlayersFinalized=function(s)
			if GetSysConfig().Timer then
				Timer.Clear() Timer.SetSeconds(GetSysConfig().TimerSeconds)
				GAMESTATE:SetTemporaryEventMode(true)
			end
		end,
	}