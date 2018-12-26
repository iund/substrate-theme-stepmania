Screens.Attract={
		Init=function(s)
			if Timer then
				Timer.Clear()
				Timer.Cancel()
			end
			Broadcast("ResetGame") local env=GAMESTATE:Env() env={} GameEnv={} EnvTable={} 
		end,
	}