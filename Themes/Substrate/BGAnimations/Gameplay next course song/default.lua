return Def.ActorFrame{
	LoadActor("../Stage overlay")..{
		FinishCommand=function(s) Broadcast("NextCourseSongLoaded") end
	}
}