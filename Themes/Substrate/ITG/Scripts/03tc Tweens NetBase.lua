Tweens.NetBase={
		Chat={
			Input={
				Box = {
					On = function(s) s:draworder(1) s:diffusealpha(0.5) s:diffusecolor(0.3,0.3,0.3,1) end,
					Off = function(s) end,
				},
				Text = {
					On = function(s) s:draworder(3) s:zoom(0.75) end,
					Off = function(s) end,
				},
			},
			Output={
				Box = {
					On = function(s) s:draworder(1) s:diffusealpha(0.5) s:diffusecolor(0.2,0.2,0.3,1) end,
					Off = function(s) end,
				},
				Text = {
					On = function(s) s:draworder(3) s:zoom(0.75) end,
					Off = function(s) end,
				},
			},
		},
		Players={
			Box = {
				On = function(s) s:draworder(1) end,
				Off = function(s) end,
			},
			Text = {
				On = function(s) s:draworder(2) end,
				Off = function(s) end,
			},
		},
	}
