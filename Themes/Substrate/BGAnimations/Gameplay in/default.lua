return Def.ActorFrame{
	InitCommand=cmd(visible,not IsDemonstration()),
	LoadActor("../Stage overlay")..{
		StartTransitioningCommand=cmd(playcommand,"Finish"),
	}
}
