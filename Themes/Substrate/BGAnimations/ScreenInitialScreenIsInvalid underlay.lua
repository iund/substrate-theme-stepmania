return Def.ActorFrame{
	Def.BitmapText{
		Font="Common normal",
		Text=THEME:GetString("Dialog-Prompt","Error"),
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X)
			s:y(SCREEN_TOP+40)
			s:zoom(2)
		end
	},

	-- Show some diags. Not localised since this screen should never appear in normal use.
	Def.BitmapText{
		Font="Common normal",
		Text="Game Version:\nBuild:\nTheme Name:\nDevices:",
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X-36)
			s:y(SCREEN_BOTTOM-64)
			s:horizalign("right")
		end,
	},
	Def.BitmapText{
		Font="Common normal",
		Text=string.format("%s\n%s\n%s\n%s",
			ProductID(),
			ProductVersion(),
			THEME:GetThemeDisplayName(),
			table.concat(INPUTMAN:GetDescriptions(),", ")
		),
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X-30)
			s:y(SCREEN_BOTTOM-64)
			s:horizalign("left")
		end
	}
}
