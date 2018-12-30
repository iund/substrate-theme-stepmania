-- NOTE: we should never get here. If we do, we may have a very restricted
--       api surface. Use very basic api calls
return Def.ActorFrame{
	Def.BitmapText{
		Font="Common normal",
		Text="You are using a version of StepMania with missing "..
		     "functionality.\n"..
		     "Use OpenITG or StepMania 5.1.",
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X)
			s:y(SCREEN_CENTER_Y)
			s:wrapwidthpixels(SCREEN_WIDTH)
		end
	}
}
