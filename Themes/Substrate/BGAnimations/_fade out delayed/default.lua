return Def.ActorFrame{
	Def.Quad {
		InitCommand=function(s) s:stretchtoscreen() s:diffuse(0,0,0,0) end,
		CancelCommand=function(s) s:sleep(0.3) s:linear(0.3) s:diffusealpha(1) end
	}
}
