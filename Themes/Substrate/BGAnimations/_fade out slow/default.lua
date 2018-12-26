return Def.ActorFrame{
	Def.Quad {
		InitCommand=cmd(stretchtoscreen;diffuse,0,0,0,0;finishtweening),
		StartTransitioningMessageCommand=cmd(linear,0.6;diffusealpha,1)
	}
}
