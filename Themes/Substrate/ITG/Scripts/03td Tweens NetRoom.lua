Tweens.NetRoom={
		TitleBG = {
			On = function(s) s:zbias(1) s:zbuffer(Bool[true]) s:draworder(-1) s:diffusealpha(CommonPaneDiffuseAlpha) end,
			Off = function(s) end,
		},
		Title = {
			On = function(s) end,
			Off = function(s) end,
		},
		RoomWheelOn = function(s) end,
		RoomWheelItem={
			TextOn = function(s) s:horizalign("left") s:zoom(0.75) end,
			DescOn = function(s) s:horizalign("right") s:zoom(0.75) end,
		},
	}
