return Def.ActorFrame{
	Def.BitmapText{
		Font="Common normal",
		Text=ThemeManager.GetString and 
		     THEME:GetString("Dialog-Prompt","Error")
		     or "Error",
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
			s:y(SCREEN_BOTTOM-96)
			s:horizalign("right")
		end,
	},
	Def.BitmapText{
		Font="Common normal",
		Text=string.format("%s\n%s\n%s\n%s",
			ProductID and ProductID() or "unknown",
			ProductVersion and ProductVersion() or "unknown",
			ThemeManager.GetThemeDisplayName and THEME:GetThemeDisplayName() or "unknown",
			table.concat(INPUTMAN:GetDescriptions(),", ")
		),
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X-30)
			s:y(SCREEN_BOTTOM-96)
			s:horizalign("left")
		end
	},

        Def.BitmapText{
                Font="Common normal",
                Text="Press &START; to exit",
                InitCommand=function(s)
                        s:x(SCREEN_CENTER_X)
                        s:y(SCREEN_BOTTOM-16)
                end
        }
}
