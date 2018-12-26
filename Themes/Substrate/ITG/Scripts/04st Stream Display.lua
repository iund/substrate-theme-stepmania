StreamDisplay={ -- Stream measure counter.
	On=function(s)
		local pn=s:getaux()
		if not CurSong() then Env().Stream=nil return end
		Env().Stream=Env().Stream or {}
		
		local dir=CurSong():GetSongDir()
		local stype=StepsTypeString[CurSteps(pn):GetStepsType()+1]
		local diffstr=DifficultyToString(CurSteps(pn):GetDifficulty())
		
		local StreamCache=GetSysProfile().StreamCache
		
--[[
		local streamentry=StreamCache[dir] and 
				StreamCache[dir][stype] and
				StreamCache[dir][stype][diffstr] and
				StreamCache[dir][stype][diffstr][GetProfile(pn).MeasureType]
--]]
-- [[
		local streamentry=
				(((StreamCache[dir] or {})[stype] or {})[diffstr] or {})[GetProfile(pn).MeasureType] or nil
--]]
				
		Env().Stream[pn]={
			Data=streamentry and Stream.Unpack(streamentry).stream or {},
			Index=0,
			Position=0,
			Object=s,
		}

		s:visible(Bool[true])
		s:shadowlength(0)
--[[
		Env().Breakdown={
			GetScreen():GetChild("StepsDescriptionP"..pn),
			GetScreen():GetChild("PlayerOptionsP"..pn),
			GetScreen():GetChild("SongNumberP"..pn)
		}
		
		local gap=2 --threshold for short breaks in measures
		local longbreakthreshold=16 --in measures
		
		local breakdown=""
		local laststrbeat=0
		for i,stream in next,Env().Stream[pn].Data,nil do
			local start=stream[1]
			local length=stream[2]
			local sbreak=start-laststrbeat --gap between cur and prev streams
			local separator=(
				sbreak<=2/GetProfile(pn).MeasureType and "." or
				sbreak<=gap and "-" or
				sbreak>longbreakthreshold and "|" or "/"
			)
			breakdown=breakdown..separator..tostring(round(length))
			laststrbeat=stream[2]+stream[1]
		end
]]

	end,
	OnNext=function(s)
		local pn=s:getaux()
		if not Env().Stream then return end
		Env().Stream[pn].ObjectNext=s
		s:visible(Bool[true])
		s:shadowlength(0)
		s:vertalign("top") s:diffusealpha(0.5) s:zoom(3/4) 
	end,
	Update=function(pn)
		local env=Env()
		if not (env.Stream and env.Stream[pn]) then return end
		local sdata=env.Stream[pn]
		if not (sdata and sdata.Object) then return end
		local s=sdata.Object
		local floor=math.floor
		local stream=sdata.Data
		local streamindex=sdata.Index
		local measure=(GameState.GetSongBeat and GAMESTATE:GetSongBeat() or GameState.GetSongPosition and GAMESTATE:GetSongPosition():GetSongBeat())/4

		if stream[streamindex+1] and stream[streamindex+1][1]<=measure then sdata.Index=streamindex+1 end --next stream

 		streamindex=sdata.Index
		if stream[streamindex] then
			local start=stream[streamindex][1]
			local length=stream[streamindex][2]
			if floor(sdata.Position)~=floor(measure) then s:settext(measure<=start+length and floor(1+measure-start).."/"..math.ceil(length) or "") end
--			sdata.Position=measure --update this in UpdateNext instead
		end
	end,
	UpdateNext=function(pn) --Lists remaining streams
		local env=Env()
		if not (env.Stream and env.Stream[pn]) then return end
		local sdata=env.Stream[pn]
		if not (sdata and sdata.ObjectNext) then return end --prevent crash, due to queuecommand
		local s=sdata.ObjectNext
		if not s then return end
		local floor=math.floor
		local ceil=math.ceil
		local stream=sdata.Data
		local streamindex=sdata.Index+1
		local measure=(GameState.GetSongBeat and GAMESTATE:GetSongBeat() or GameState.GetSongPosition and GAMESTATE:GetSongPosition():GetSongBeat())/4

		if floor(sdata.Position)~=floor(measure) then
			local list={}
			for i=streamindex,table.getn(stream) do
				local start=stream[i][1]
				local length=stream[i][2]
				list[i-streamindex+1]=floor(1+measure-start).."/"..ceil(length)
			end
			s:settext(join("\n",list))
		end
		sdata.Position=measure
	end,
	Off=function(s)
		local pn=s:getaux();
		(Env().Stream or {})[pn]=nil
	end
}
