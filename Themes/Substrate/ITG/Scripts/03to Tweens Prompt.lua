	Tweens.Prompt = {
		BackgroundOn=function(s) end,
		Question={
			On=function(s) s:shadowlength(0)
		
				s:wrapwidthpixels(576)
				--s:zoom(math.min(1,234/s:GetHeight()))
				--s:zoom(math.min(1,576/s:GetWidth()))
				s:maxheight(234)
			end,
			Off=function(s) end,
		},
		Answer={
			On=function(s,i,numAnswers) s:zoom(3/2) s:shadowlength(0) end,
			Off=function(s,i,numAnswers) end,
		},
		Cursor={
			On=function(s) end,
			Off=function(s) end,
		},
	}
