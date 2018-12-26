	Tweens.Stage = {
		Box={
			On=function(s)
			end,
			Off=function(s)
			end,
		},
		CourseProgress={
			Box={
				On=function(s)
				end,
				Off=function(s)
				end,
			},
			
			Current={
				On=function(s)
					s:vertalign('top')
					s:shadowlength(0)
				end,
				Off=function(s)
				end,
			},
			
			Next={
				On=function(s)
					s:diffusecolor(.5,.5,.5,1)
					s:vertalign('top')
					s:shadowlength(0)
				end,
				Off=function(s)
				end,
			},
		}
	}