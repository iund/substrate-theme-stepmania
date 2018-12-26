return Def.ActorFrame{
	DoneLoadingNextSongMessageCommand=function(s)
		--NOTE: Forces c150 overhead to align with the traffic light.
		ForeachEnabledPlayer(function(p)
			if GetCurSteps(p):GetDifficulty()=="Difficulty_Beginner" then
				local m=GAMESTATE:GetPlayerState(p):GetPlayerOptions("ModsLevel_Song")
				m:FromString("clearall")
				m:CMod(150,1) --TODO: Doesn't get applied when preferred mmod is set
				m:Overhead(true)
			end
		end)
	end
}
