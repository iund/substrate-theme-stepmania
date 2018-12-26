	Tweens.Options = {
		CenterPane = {	
			On=function(s) s:diffusealpha(CommonPaneDiffuseAlpha) end,
			Off=function(s) end,
		},
		Titles = {
			On=function(s,line)
				s:diffusealpha(0)
				s:sleep((tonumber(line) or 0)*0.025)
				s:linear(0.1)
				s:diffusealpha(1) end,
			Off=function(s,line) end,
		},
		PlayerPane = {
			On=function(s,pn) end, --Sweep.In(s,pn) end,
			ColorChanged=function(s) s:stoptweening() s:decelerate(.25) end, --fade to another color in mods menu (where the "Colour" row is)
			Off=function(s,pn) end, --Sweep.Out(s,pn) end,
		},
		Items = {
			On=function(s,pn,line) end, --Sweep.In(s,pn) end,
			Off=function(s,pn,line) end, --Sweep.Out(s,pn) end,
		}
	}