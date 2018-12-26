	Tweens.TextEntry = {
		Question={
			On=function(s) s:draworder(2) s:zoom(3/2) s:shadowlength(0) end,
			Off=function(s) end,
		},
		AnswerBox={
			On=function(s) s:draworder(-55) end,
			Off=function(s) end,
		},
		Answer={
			On=function(s) s:zoom(3/2) s:shadowlength(0) end,
			Off=function(s) end,
		},
		Cursor={
			On=function(s) s:diffuse(0.5,0.5,0.5,1) s:zoomtoheight(24) LuaEffect(s,"Poll") end,
			Poll=function(s) s:zoomtowidth(s:GetY()==SCREEN_BOTTOM-80 and 88 or 24) end,

			Off=function(s) end,
		},
	}
