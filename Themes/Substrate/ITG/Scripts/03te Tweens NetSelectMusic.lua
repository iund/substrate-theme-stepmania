	Tweens.NetSelectMusic = {
		DiffBG={
			On = function(s) s:zbias(1) s:zbuffer(Bool[true]) s:draworder(-1) s:diffusealpha(CommonPaneDiffuseAlpha) end,
			Off = function(s) end,
		},

		BPMDisplay = {
			On = function(s) local text=IsActorFrame(s) and Capture.ActorFrame.GetChildren(s).children[1] or s text:shadowlength(0) s:draworder(3) text:horizalign("left") text:zoom(15/20) text:finishtweening() end,
			Off = function(s) end,
		},
		Banner = {
			On = function(s) end,
			Off = function(s) end,
		},
		BannerFrame = { --Reused
			On = function(s) s:draworder(2) end,
			Off = function(s) end,
		},
	}
