	Tweens.SelectMusic = {
	
		Stage = {
			On=function(s) s:diffuse(1,1,1,1) s:shadowlength(0) s:zoom(15/20) end,
			Off=function(s) end
		},

		-- Center pane
		Banner = {
			On = function(s) end,
			Off = function(s) end,
		},
		SongOptions = {
			--TODO
			On = function(s) s:draworder(2) s:shadowlength(0) s:zoom(15/20) end,
			Off = function(s) end,
		},
		
		BannerFrame = { --Reused
			On = function(s) s:draworder(2) end,
			Off = function(s) end,
		},
		BPMDisplay = {
			On = function(s)
				local text=IsActorFrame(s) and Capture.ActorFrame.GetChildren(s).children[1] or s
				text:shadowlength(0) s:draworder(3) text:horizalign("left") text:zoom(15/20) text:finishtweening()
				--if IsActorFrame(s) then s:SetUpdateRate(2) end
				s:SetUpdateRate(4)
			end,
			Off = function(s) end,
		},
		Artist = {
			On = function(s) s:horizalign("center") s:shadowlength(0) s:draworder(3) s:zoom(15/20) s:maxwidth(300) end,
			Off = function(s) end
		},
		TotalTime= {
			On =	function(s) s:horizalign("right") s:shadowlength(0) s:draworder(3) s:zoom(15/20) end,
			Off = function(s) end
		},
		
		MusicWheel = {
			On = function(s) s:draworder(1) end,
			Off = function(s) end,
		},
		MusicWheelItem = {
			-- NOTE: The game internally applies hurrytweening(0.25) afterward to the objects when changing sort.
			StartOn=function(s)
				s:horizalign("left")
				s:zoomy(0)
					s:finishtweening()
			end,
			FinishOn = function(s) --aux is the row index
				local spr=mwSprites[s:getaux()].Folder.Closed
--				local width=spr:GetWidth()*spr:GetZoomX()
--				local i=GetScreen():getaux()

--				s:sleep(i*0.075)
					s:decelerate(0.1)
					s:zoomy(1)
--				GetScreen():aux(math.mod(i+1,table.getn(mwItems)))
			end,
			MeterTween=function(m,d,pn)
				local h=m:GetZoomY()
				m:finishtweening()
				if GAMESTATE:GetSortOrder()==SORT_ROULETTE then return end --moves very fast
				m:zoomy(0) m:y(-m:GetHeight()/2)
				m:decelerate(0.2)
				m:zoomy(h) m:y(0)
			end,
			StartOff = function(s)
				s:finishtweening()
			end,
			FinishOff = function(s)
				if not mwSprites then return end --dodge a crash in NetSelectMusic
				local spr=mwSprites[s:getaux()].Folder.Closed
--				local width=spr:GetWidth()*spr:GetZoomX()
--				local i=GetScreen():getaux()

--				s:sleep(i*0.075)
					s:accelerate(0.1) s:zoomy(0)
--				GetScreen():aux(math.mod(i+1,table.getn(mwItems)))
			end
		},
		
		CourseContents={
			On = function(s) s:draworder(2) end,
			Off = function(s) end,
			Show=function(s) end,
			Hide=function(s) end,
		},
		
		-- Side panes
		PlayerPane = { --parent
			On = function(s,pn)
				local ch=Capture.ActorFrame.GetChildren(s).children --under, contents frame, over

				Tweens.SelectMusic.PaneDisplay.Under.On(ch[1].self or ch[1]) 
				Tweens.SelectMusic.PaneDisplay.Over.On(ch[3].self or ch[3])

				s:ztestmode('writeonpass')
				local x=Metrics.SelectMusic.PaneDisplay.Width*(pn-1.5)*2
				s:addx(-x) s:decelerate(0.5) s:addx(x)

			end,
			Off = function(s,pn)
				local x=Metrics.SelectMusic.PaneDisplay.Width*(pn-1.5)*2
				s:accelerate(0.5) s:addx(-x)
			end
		},
		ExtraPane = {
			On=function(s) local pn=math.mod(s:getaux(),2)+1
				s:ztestmode('writeonpass')
				local x=Metrics.SelectMusic.PaneDisplay.Width*(pn-1.5)*2
				s:addx(-x) s:decelerate(0.5) s:addx(x)
				s:diffusecolor(unpack(PlayerColor(s:getaux())))
			end,
			Off=function(s) local pn=math.mod(s:getaux(),2)+1
				local x=Metrics.SelectMusic.PaneDisplay.Width*(pn-1.5)*2
				s:accelerate(0.5) s:addx(-x)
			end,
		},
--Tweens.SelectMusic.ExtraPane.On(
		PaneDisplay = {
			Under = {
				On = function(s)
					s:diffusecolor(unpack(PlayerColor(s:getaux())))
					s:diffusealpha(CommonPaneDiffuseAlpha)
				end,
				Off = function(s) end,
			},
			Over = {
				On = function(s) end,
				Off = function(s) end,
			},
			Stats = {
				Text = {
					On = function(s) s:horizalign('center') s:shadowlength(0) s:zoom(3/4) end,
					Off = function(s) end,
					GainFocus = function(s) s:stoptweening() s:sleep(.15) s:linear(.2) s:diffusealpha(1) end,
					LoseFocus = function(s) s:stoptweening() s:linear(.2) s:diffusealpha(0) end,
				},
				Label = {
					On = function(s) s:horizalign('center') s:shadowlength(0) s:zoom(3/4) end,
					Off = function(s) end,
					GainFocus = function(s) s:stoptweening() s:sleep(.15) s:linear(.2) s:diffusealpha(1) end,
					LoseFocus = function(s) s:stoptweening() s:linear(.2) s:diffusealpha(0) end,
				},
			},
			Score = {
				Machine = {
					Text = {
						On = function(s) s:shadowlength(0) end,
						Off = function(s) end,
						GainFocus = function(s) s:stoptweening() s:sleep(.15) s:linear(.2) s:diffusealpha(1) end,
						LoseFocus = function(s) s:stoptweening() s:linear(.2) s:diffusealpha(0) end,
					},
					Label = {
						On = function(s) s:shadowlength(0) end,
						Off = function(s) end,
						GainFocus = function(s) s:stoptweening() s:sleep(.15) s:linear(.2) s:diffusealpha(1) end,
						LoseFocus = function(s) s:stoptweening() s:linear(.2) s:diffusealpha(0) end,
					},
				},
				Personal = {
					Text = {
						On = function(s) s:shadowlength(0) end,
						Off = function(s) end,
						GainFocus = function(s) s:stoptweening() s:sleep(.15) s:linear(.2) s:diffusealpha(1) end,
						LoseFocus = function(s) s:stoptweening() s:linear(.2) s:diffusealpha(0) end,
					},
					Label = {
						On = function(s) s:shadowlength(0) end,
						Off = function(s) end,
						GainFocus = function(s) s:stoptweening() s:sleep(.15) s:linear(.2) s:diffusealpha(1) end,
						LoseFocus = function(s) s:stoptweening() s:linear(.2) s:diffusealpha(0) end,
					},
				},
--[[
				Machine = {
					Text = {
						On = function(s) s:horizalign('right') s:shadowlength(0) s:zoom(3/4) end,
						Off = function(s) end,
						GainFocus = function(s) s:stoptweening() s:sleep(.15) s:linear(.2) s:diffusealpha(1) end,
						LoseFocus = function(s) s:stoptweening() s:linear(.2) s:diffusealpha(0) end,
					},
					Label = {
						On = function(s) s:horizalign('left') s:shadowlength(0) s:zoom(3/4) end,
						Off = function(s) end,
						GainFocus = function(s) s:stoptweening() s:sleep(.15) s:linear(.2) s:diffusealpha(1) end,
						LoseFocus = function(s) s:stoptweening() s:linear(.2) s:diffusealpha(0) end,
					},
				},
				Personal = {
					Text = {
						On = function(s) s:horizalign('right') s:shadowlength(0) s:zoom(3/4) end,
						Off = function(s) end,
						GainFocus = function(s) s:stoptweening() s:sleep(.15) s:linear(.2) s:diffusealpha(1) end,
						LoseFocus = function(s) s:stoptweening() s:linear(.2) s:diffusealpha(0) end,
					},
					Label = {
						On = function(s) s:horizalign('left') s:shadowlength(0) s:zoom(3/4) end,
						Off = function(s) end,
						GainFocus = function(s) s:stoptweening() s:sleep(.15) s:linear(.2) s:diffusealpha(1) end,
						LoseFocus = function(s) s:stoptweening() s:linear(.2) s:diffusealpha(0) end,
					},
				},
--]]
			},
			Description = {
				On = function(s) s:horizalign('center') s:shadowlength(0) s:zoom(15/20) s:maxwidth(224/s:GetZoomX()) end,
				Off = function(s) end,
				GainFocus = function(s) s:stoptweening() s:sleep(.15) s:linear(.2) s:diffusealpha(1) end,
				LoseFocus = function(s) s:stoptweening() s:linear(.2) s:diffusealpha(0) end,
			},
			PlayerName = {
				On = function(s) s:horizalign('center') s:shadowlength(0) s:zoom(1.5) s:maxwidth(224/s:GetZoomX()) end,
				Off = function(s) end,
				GainFocus = function(s) s:stoptweening() s:sleep(.15) s:linear(.2) s:diffusealpha(1) end,
				LoseFocus = function(s) s:stoptweening() s:linear(.2) s:diffusealpha(0) end,
			},
			Mods = {
				On = function(s) s:horizalign('center') s:shadowlength(0) s:zoom(3/4) s:maxwidth(224/s:GetZoomX()) end,
				Off = function(s) end,
			},
		},

		OptionsMenuPrompt={
			--On=function(s) s:zoomy(0) s:linear(0.25) s:zoomy(1) end,
			--Off=function(s) s:linear(0.25) s:zoomy(0) end,
			On=function(s) s:diffusealpha(0) s:linear(0.3) s:diffusealpha(1) end,
			Off=function(s) s:finishtweening() s:linear(Metrics.SelectMusic.OptionsMenuPromptTime-0.3) s:diffusealpha(0) end,
		},

	}
