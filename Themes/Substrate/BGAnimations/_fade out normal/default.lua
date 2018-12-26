return Def.Quad {
	InitCommand=function(s) s:stretchtoscreen() s:diffuse(0,0,0,0) end,
	StartTransitioningCommand=function(s) s:linear(0.3) s:diffusealpha(1) end
}