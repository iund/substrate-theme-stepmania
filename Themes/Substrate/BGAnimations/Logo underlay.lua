return Def.ActorFrame{
	LoadActor("_logo")..{
		InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+24)
	}
}
