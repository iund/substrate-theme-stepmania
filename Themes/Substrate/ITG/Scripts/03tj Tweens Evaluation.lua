	Tweens.Evaluation = {
		--Middle box.
		Stage = {
			On=function(s) s:diffuse(1,1,1,1) s:shadowlength(0) s:clearzbuffer(1) s:zoom(15/20) Sweep.InCenter(s,-1) end,
			Off=function(s) Sweep.OutCenter(s,-1) end
		},
		BannerFrame = {
			On = function(s) s:diffusealpha(CommonPaneDiffuseAlpha) Sweep.InCenter(s,-1) end,
			Off = function(s) Sweep.OutCenter(s,-1) end
		},
		Banner = {
			On = function(s) Sweep.InCenter(s,-1) end,
			Off = function(s) Sweep.OutCenter(s,-1) end
		},
		SongName = {
			On=function(s) s:shadowlength(0) s:zoom(.75) Sweep.InCenter(s,-1) end,
			Off=function(s) Sweep.OutCenter(s,-1) end
		},
		SongOptions = {
			On=function(s) s:shadowlength(0) s:zoom(.75) s:maxwidth(256/s:GetZoomX()) Sweep.InCenter(s,-1) end,
			Off=function(s) Sweep.OutCenter(s,-1) end
		},

		--pecrent box
		Percent = {
			On = function(s,pn)
				s:zoom(3)
				if GetGrade(pn)==GRADE_FAILED and getmetatable(s).GetChild and s:GetChild('PercentP'..pn) then s:GetChild('PercentP'..pn):diffusecolor(1,0,0,0) end
				Sweep.In(s,pn) end,
			Off = function(s,pn) Sweep.Out(s,pn) end
		},
		PercentFrame = {
			On = function(s,pn) Capture.ActorFrame.AutoActor.ApplyPNToChildren(s,pn) s:diffusealpha(CommonPaneDiffuseAlpha) Sweep.In(s,pn) end,
			Off = function(s,pn) Sweep.Out(s,pn) end
		},
		PlayerName = {
			On = function(s,pn) s:shadowlength(0) Sweep.In(s,pn) end,
			Off = function(s,pn) Sweep.Out(s,pn) end
		},
		Record = {
			Machine = {
				On = function(s,pn) GetScreen():aux(pn) Sweep.In(s,pn) s:visible(Bool[false]) end,
				Off = function(s,pn) Sweep.Out(s,pn) end
			},
			Personal = {
				On = function(s,pn)
				--[[	if GetScreen():getaux()==pn then 
						--both personal and machine records 
						GetScreen():GetChild("MachineRecordP"..pn):visible(Bool[false])
						s:settext("Personal & "..s:GetText())
					end
					Sweep.In(s,pn)
				]]
					s:visible(Bool[false]) --scorelist is working, so this and machine record text is redundant
				end,
				Off = function(s,pn) Sweep.Out(s,pn) end
			},
		},
		DQ = {
			On = function(s,pn) s:visible(Bool[not IsFailed(pn)]) Sweep.In(s,pn) end,
			Off = function(s,pn) Sweep.Out(s,pn) end
		},
		ScoreList = {
			On = function(s,pn) --[[s:visible(Bool[not IsFailed(pn)])--]] s:zoom(15/20) s:shadowlength(0) Sweep.In(s,pn) end,
			Off = function(s,pn) Sweep.Out(s,pn) end
		},
		
		--player pane
		
		PlayerPane = {
			On = function(s,pn)
				s:diffusealpha(CommonPaneDiffuseAlpha)
				s:diffusecolor(unpack(PlayerColor(pn))) s:finishtweening()
				s:ztestmode('writeonpass') Sweep.In(s,pn) end,
			Off = function(s,pn) Sweep.Out(s,pn) end
		},
		StepsDescription = {
			On = function(s,pn)
				s:shadowlength(0) s:zoom(3/4) Sweep.In(s,pn) end,
			Off = function(s,pn) Sweep.Out(s,pn) end
		},
		StatsLabels = {
			On = function(s,pn,row)
				s:shadowlength(0) s:zoom(3/4) s:horizalign(({'right','left'})[pn]) Sweep.In(s,pn) end,
			Off = function(s,pn,row) Sweep.Out(s,pn) end,
		},
		Stats = {
			On = function(s,pn,row)
				s:shadowlength(0) s:zoom(3/4) s:horizalign('center') --s:horizalign(({'right','left'})[pn])
				s:settext(string.gsub(s:GetText()," ","")) Sweep.In(s,pn) end,
			Off = function(s,pn,row) Sweep.Out(s,pn) end,
		},
		JudgeLabels = {
			On = function(s,pn,row)
				s:shadowlength(0) s:zoom(3/4) s:horizalign(({'left','right'})[pn]) Sweep.In(s,pn) end,
			Off = function(s,pn,row) Sweep.Out(s,pn) end,
		},
		Judge = {
			On = function(s,pn,row)
				s:shadowlength(0) s:zoom(3/4) s:horizalign('center') --s:horizalign(({'right','left'})[pn])
				s:settext(string.gsub(s:GetText()," ","")) Sweep.In(s,pn) end,
			Off=function(s,pn,row) Sweep.Out(s,pn) end
		},
		Meter = {
			On = function(s,pn) s:zoom(2) Sweep.In(s,pn) end,
			Off = function(s,pn) Sweep.Out(s,pn) end
		},
		Mods = {
			On = function(s,pn) s:zoom(3/4) s:shadowlength(0) s:maxwidth(384/s:GetZoomX()) Sweep.In(s,pn) end,
			Off = function(s,pn) Sweep.Out(s,pn) end
		},
		--Combined life+combo graph
		--[[
		Note:
			GraphFrame = _blank
			LifeGraph = mask + dim grey section (combo breaks)
			ComboGraph = white/light grey section (uses lifegraph mask)
		]]
		GraphFrame = {
			On = function(s,pn) Sweep.In(s,pn) end,
			Off = function(s,pn) Sweep.Out(s,pn) end
		},
		LifeGraph = {
			SongBoundaryOn = function(s) s:zoomtowidth(2) s:zoomtoheight(72) s:diffuse(1,1,1,1) s:diffusealpha(0.25) end,
			On = function(s,pn) s:zbias(1) s:zbuffer(1) Sweep.In(s,pn) end,
			Off = function(s,pn) Sweep.Out(s,pn) end
		},
		ComboGraph = {
			NormalPartOn = function(s) s:aux(-1) end,
			MaxPartOn = function(s) s:aux(-2) end,
			MaxNumber = {
				On = function(s) s:zoom(0.75) s:shadowlength(0) s:horizalign('center') end,
				Off = function(s) end,
			},
			On = function(s,pn)
				for i,part in next,Capture.ActorFrame.GetChildren(s).children,nil do
					if part:getaux()==-1 then
						--part:diffusecolor(unpack(PlayerColor(pn)))
					end
				end
				s:ztestmode('writeonfail')
				Sweep.In(s,pn)
			end,
			Off = function(s,pn) Sweep.Out(s,pn) end,
			PartOff = function(s) end,
		},
		Time = {
			On = function(s,pn) s:draworder(5+(5*pn)) s:shadowlength(0) s:zoom(3/4) s:horizalign('left') Sweep.In(s,pn)
				s:visible(Bool[false]) --actually don't show this
			end,
			Off = function(s,pn) Sweep.Out(s,pn) end
		},
		
		--Misc
		Award = {
			Timing = {
				On = function(s,pn) end,
				Off = function(s,pn) end
			},
			Combo = {
				On = function(s,pn) end,
				Off = function(s,pn) end
			}
		},
		
		--Net player list
		PlayerListBG={
			On=function(s)
				s:diffusealpha(CommonPaneDiffuseAlpha)
				Sweep.In(s,Player(1) and 2 or 1)
			end,
			Off=function(s)
				Sweep.Out(s,Player(1) and 2 or 1)
			end,		
		},
		PlayerListLines={
			On=function(s)
				s:shadowlength(0)
				Sweep.In(s,Player(1) and 2 or 1)
			end,
			Off=function(s)
				s:shadowlength(0)
				Sweep.Out(s,Player(1) and 2 or 1)
			end,
			Highlight=function(s)
			end,
			Unhighlight=function(s)
			end,
		},
		BonusBar={
			Possible={	
				On=function(s,pn,i) end,
				Off=function(s,pn,i) end,
			},
			Actual={
				On=function(s,pn,i) end,
				Off=function(s,pn,i) end,
				MaxFlash=function(s) end,
			}
		}
	}
