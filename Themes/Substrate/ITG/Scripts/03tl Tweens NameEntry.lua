	Tweens.NameEntry = { --Stock name entry score list.
	--underlay
		ScoreList = {
			On = function(s,pn) s:zoom(15/20) s:shadowlength(0) end,
			Off = function(s,pn) end
		},

	--name entry boxes
		OutOfRanking = {
			On=function(s,pn) end,
			Off=function(s,pn) end,
		},
		EntryFrame = {
			On=function(s,pn) end,
			Off=function(s,pn) end,
		},
		Keyboard = {
			On=function(s,pn) end,
			Off=function(s,pn) end,
		},
		Letters = {
			On=function(s) s:shadowlength(0) s:zoom(2) end,
		},
		LettersSpecial = {
			On=function(s) s:shadowlength(0) s:zoom(2) end,
		},
		
		Selection = {
			On=function(s,pn) s:shadowlength(0) s:zoom(2) end,
			Off=function(s,pn) end,
		},

	--score pane on scroller
		Wheel = {
			On=function(s,pn)
				s:zoom(0.75)
				
				--Make the wheel 2D by inverting the transform that gets applied
				local items=Capture.ActorFrame.GetChildren(s).children
				for i=1,table.getn(items) do
					items[i].self:rotationx((5.25-i)*18)
					items[i].self:y(i*16)
				end
				--DumpActor(s,"WheelOn")
			end,
			Off=function(s,pn) end,
		},
		WheelItem={
			Rank=function(s) s:shadowlength(0) s:horizalign('center') end,
			Name=function(s) s:shadowlength(0) s:horizalign('left') end,
			Score=function(s) s:shadowlength(0) s:horizalign('right') end,
			Date=function(s) s:shadowlength(0) s:horizalign('right') end,
		},
		Banner = {
			On=function(s,pn) s:scaletoclipped(unpack(Metrics.NameEntry.BannerSizeXY)) end,
			Off=function(s,pn) end,
		},
		Grade = {
			On=function(s,pn) end,
			Off=function(s,pn) end,
		},
		DifficultyIcon = {
			On=function(s,pn) end,
			Off=function(s,pn) end,
		},
		DifficultyMeter = {
			On=function(s,pn) s:shadowlength(0) end,
			Off=function(s,pn) end,
		},
		Score = {
			On=function(s,pn) end,
			Off=function(s,pn) end,
		},
		Percent = {
			On=function(s,pn) s:shadowlength(0) s:diffuse(1,1,1,1) end, --s:settext(string.gsub(s:GetText(),"%%","")) end,
			Off=function(s,pn) end,
		},

		BannerFrame = {
			On=function(s,pn) s:draworder(-1) end,
			Off=function(s,pn) end,
		},
		
	--util
		ScrollFeats = function(pn)
			local h=Metrics.NameEntry.FeatHeight
			local NumFeats=table.getn(Feat.Objects[pn])
			if NumFeats<=Metrics.NameEntry.NumFeatsShown then return end --do nothing. we already have all feats shown
			for f=1,NumFeats do
				local feat=Feat.Objects[pn][f]
				for n,s in next,feat,nil do
					s:finishtweening()
					if s:getaux()<1 then
						s:aux(NumFeats) s:addy(NumFeats*h)
					end
					s:aux(s:getaux()-1) s:linear(0.5) s:addy(-h) --the aux value is the displayed rows. aux 0 = top row
					if n=="Wheel" then s:queuecommand("NoTween") end
				end
			end
		end,

	}
