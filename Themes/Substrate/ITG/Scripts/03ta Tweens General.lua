Sweep={ --Shared tween lateral slide-in for most actors
	In=function(s,pn) local dir=(pn-1.5)*2 s:addx(dir*SCREEN_WIDTH/2) s:decelerate(0.5) s:addx(-dir*SCREEN_WIDTH/2) end,
	Out=function(s,pn) local dir=(pn-1.5)*2 s:stoptweening() s:accelerate(0.5) s:addx(dir*SCREEN_WIDTH/2) end,

	InCenter=function(s,dir) s:addy(dir*SCREEN_HEIGHT/2) s:decelerate(0.5) s:addy(-dir*SCREEN_HEIGHT/2) end,
	OutCenter=function(s,dir) s:stoptweening() s:accelerate(0.5) s:addy(dir*SCREEN_HEIGHT/2) end,
}

Tweens={}