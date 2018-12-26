	--Custom name entry score list.
	Tweens.Summary = {
		ScoreList = {
			On = function(s,pn) s:zoom(15/20) s:shadowlength(0) end,
			Off = function(s,pn) end
		},
		--[[
		ScrollFeats = function(s,d) --new work-in-progress version with manual scrolling input 
			local dir=d or 1
			if not ScrollerRows or not Scores or table.getn(Scores)==0 then return end
			local rows=ScrollerRows
			local NumScores=table.getn(Scores)
			local NumRows=table.getn(rows.children) --one extra
			if NumScores<NumRows then return end --do nothing. we already have all feats shown

			local height=Metrics.Summary.ScoreHeight

			--get row+score to wrap
			--row index:   s:getaux()
			--score index: GetScreen():getaux()

			local rindex=s:getaux()
			local first=rindex<0
			local wraprow=math.mod(rindex+NumRows+(dir-1),NumRows)+1
			if not first then
				local top=rows.children[wraprow].self
				top:finishtweening() top:y(NumRows*height) --wrap row
				GetScreen():aux(math.mod(GetScreen():getaux()+NumScores+(dir-1),NumScores)+1) --select score index to load
				
				local recursecommands
				recursecommands=function(t,cmds) for _,s in next,t,nil do cmds(s.self or s) if s.self then recursecommands(s.children,cmds) end end end
				recursecommands(rows.children[wraprow].children,function(s) s:playcommand("ReloadRow") end) --load wrapped row
			end
			for i=1,NumRows do
				local r=rows.children[i].self
				r:finishtweening()
				r:linear(Metrics.Summary.ScrollTweenTime)

				r:y(height*math.mod(i+rindex,NumRows))
				--r:addy(-height)
			end --scroll up
			s:aux(wraprow)
		end,
		]]
		-- [[
		ScrollFeats = function(s) --this is crazy finicky, don't touch it 		or it'll break spectacularly
			if not ScrollerRows or not Scores or table.getn(Scores)==0 then return end
			local rows=ScrollerRows
			local NumScores=table.getn(Scores)
			local NumRows=table.getn(rows.children) --one extra
			if NumScores<NumRows then return end --do nothing. we already have all feats shown

--			DumpTable(Scores,"Scores Dump")

			local height=Metrics.Summary.ScoreHeight

			--get row+score to wrap
			local first=s:getaux()<0
			local wraprow=math.mod(s:getaux(),NumRows)+1
			if not first then
				local top=rows.children[wraprow].self
				top:addy(NumRows*height) --wrap row
				top:finishtweening()
				GetScreen():aux(math.mod(GetScreen():getaux(),NumScores)+1)
				
				local recursecommands
				recursecommands=function(t,cmds) for _,s in next,t,nil do cmds(s.self or s) if s.self then recursecommands(s.children,cmds) end end end
				recursecommands(rows.children[wraprow].children,function(s) s:playcommand("ReloadRow") end) --load wrapped row
			end
			for i=1,NumRows do local s=rows.children[i].self s:finishtweening() s:decelerate(Metrics.Summary.ScrollTweenTime) s:addy(-height) end --scroll up
			s:aux(wraprow)
		end,
		--]]
	}
