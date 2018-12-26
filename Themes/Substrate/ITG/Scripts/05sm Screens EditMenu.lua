Screens.EditMenu={ --I'm well aware that the menu is completely different in SM 5.1. This is for the old 3.9/3.95 style edit menu.
		NextRow={
			Label=function(s)
				s:shadowlength(0) 
				Env()._name=s:GetText()
				EditMenuRows=EditMenuRows or {}
				EditMenuRows[Env()._name]={Label=s}
				--TODO language strings
			end,
			Value=function(s)
				s:maxwidth(Metrics.EditMenu.ValueMaxWidth) s:shadowlength(0)
				local lastRow=EditMenuRows[Env()._name]
				lastRow.Label:horizalign("center") 
				lastRow.Value=s
			end
		},

		FormatTextBanner=function(title,sub) --put title and subtitle on the same line, grey out subtitle a bit to be consistent with the rest of the theme
			sub:settext(" "..sub:GetText())
			sub:diffuse(0.75,0.75,0.75,1)
			local totalwidth=AlignTexts("center",title,sub)
			if not GetScreen():GetChild("EditMenu") then return end --This isn't present on the first load
			GetScreen():GetChild("EditMenu"):GetChild("SongTextBanner"):zoomx(math.min(1,maxwidth or Metrics.EditMenu.ValueMaxWidth/totalwidth))
		end,

		Init=function(s) TopScreen=s SetEnv("EditMode",1) end,
		
		InitCourseMenu=function(s) TopScreen=s SetEnv("EditMode",1) end,
	
		On=function(s)
--			s:GetChild("EditMenu"):GetChild("GroupBanner"):draworder(-1000)
--			s:GetChild("EditMenu"):GetChild("SongBanner"):wag()
		end,
	

		UpdateStats=function(s)
			s:visible(Bool[false])
			Broadcast('MoveHighlight')
--[[
			assert(TopScreen)
			local editmenu=TopScreen:GetChild("EditMenu")

			if not editmenu:GetChild("Explanation") then
				EditMenuRaw=Capture.ActorFrame.GetChildren(editmenu)
			end
			assert(EditMenuRows["Group"],table.dump(EditMenuRows))
			local folder=EditMenuRows["Group"].Value:GetText()
			local textbanner=editmenu:GetChild("SongTextBanner")

			local title=textbanner:GetChild("Title"):GetText()
			local subtitle=textbanner:GetChild("Subtitle"):GetText()
--			Screens.EditMenu.FormatTextBanner(title,subtitle,textbanner)
--]]

		end
	
	}