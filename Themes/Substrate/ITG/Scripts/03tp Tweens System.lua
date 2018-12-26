	Tweens.System = {
		StatsOn=function(s)
			s:horizalign("right") s:vertalign("top") s:shadowlength(0)
			--align to the pixel since this is relative to screen right
			s:zoomx(SCREEN_HEIGHT*(math.round(GetPref("DisplayAspectRatio")*900)/900)/GetPref("DisplayWidth"))
			s:zoomy(SCREEN_HEIGHT/GetPref("DisplayHeight"))
			s:x((math.round(GetPref("DisplayAspectRatio")*900)/900)*SCREEN_HEIGHT-16)
		end,
		CreditsTextOn=function(s,pn) s:zoom(15/20) s:horizalign(({"left","right"})[pn]) s:shadowlength(0) s:aux(pn) end,
		TimerOn=function(s) 
			s:horizalign("left") s:vertalign("top") s:shadowlength(0)
			s:zoomx(SCREEN_HEIGHT*(math.round(GetPref("DisplayAspectRatio")*900)/900)/GetPref("DisplayWidth"))
			s:zoomy(SCREEN_HEIGHT/GetPref("DisplayHeight"))
		end,
		Message={
			Frame={ --On is called, then Off is called immediately after.
				Init=function(s) s:vertalign("top") s:horizalign("center") s:diffuse(0,0,0,0.8) s:clearzbuffer(1) s:zbias(1) s:zbuffer(1) end,
				On=function(s) s:finishtweening() s:stoptweening() s:cropbottom(1) s:decelerate(0.3) s:cropbottom(0) end,
				Off=function(s) s:sleep(2.5) s:accelerate(0.3) s:cropbottom(1) end,
			},
			Text={
				Init=function(s) s:shadowlength(0) s:horizalign("center") s:vertalign("top") s:maxwidth(SCREEN_WIDTH) s:maxheight(SCREEN_HEIGHT) s:ztestmode("writeonfail") end,
				On=function(s) s:stoptweening() s:diffusealpha(0) s:decelerate(0.3) s:diffusealpha(1) end,
				Off=function(s) s:sleep(2.5) s:accelerate(0.3) s:diffusealpha(0) end,
			},
		},
		DebugOverlay = {
		
		
		},
		SyncOverlay = {
		
		},
	}
