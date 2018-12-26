Stream={
	--Packing functions: Currently this uses a modified BCD.
	--[[

		Format: breakdownstr,start,end/start,end/start,end
		(for example: 65/74-23.64,34,3/45,7/67,4)

	--]]
	Pack=function(streamdata)
		local stream=streamdata.stream
		local breakdown=streamdata.breakdown

		local data={}
		for i=1,table.getn(stream) do
			local st=stream[i]
			data[i]=tostring(st[1])..","..tostring(st[2]) --data[i]=sprintf("%f,%f",st[1],st[2])
		end
		local streamstr=join("/",data)
	
		local out=sprintf("%s,%s",breakdown,streamstr)

		return bcd.pack(out)
	end,
	Unpack=function(packeddata)
		local raw=bcd.unpack(packeddata)

		local delimpos=string.find(raw,",") --first , = splits string into 2 pieces
		local breakdownstr=string.sub(raw,1,delimpos-1)
		local streamstr=string.sub(raw,delimpos+1,-1)

		local stream=split("/",streamstr)

		local out={} for i,st in next,stream,nil do
			local tmp=split(",",st)
			local o={} for j=1,table.getn(tmp) do o[j]=tonumber(tmp[j]) end
			
			out[i]=o
		end

		return {breakdown=breakdownstr, stream=out}
	end,
	GetBreakdown=function(packeddata)
		local data=bcd.unpack(packeddata)
		local start=data and string.find(data,",")
		return start and string.sub(data,1,start-1) or ""
	end,
}

function UpdateStreamCache(isthread)
	--config vars:
		--stream:
		local minstreamlength=2
		local minbreaklength=1 --in measures
		--breakdown string condensing:
		local max=6 --max number of streams to show
		local gap=2 --threshold for short breaks in measures
		local longbreak=16 --in measures

		local CONDENSED_STREAMS=false


	--My Mac oITG build craps out after reading so many files (runs out of memory?). Save it every so often for each opened file.
	local maxfiles=10000

	--import globals
	local getn=table.getn
	local sts=StepsTypeString
	local dn=DifficultyNames
	local Trace=Trace
	local tostring=tostring
	local getsteps=Song.GetAllSteps
	local getSM=Steps.GetSMNoteData
	local getst=Steps.GetStepsType
	local getdiff=Steps.GetDifficulty
	local songdir=Song.GetSongDir
	local nextl=string.nextline
	local next=next
	local sprintf=sprintf
	local sub=string.sub
	local len=string.len
	local insert=table.insert
	local find=string.find
	local round=function(n) return math.floor(n+0.5) end

	Trace("Caching..")

	GetSysProfile().StreamCache=GetSysProfile().StreamCache or {}

	local out=GetSysProfile().StreamCache
	
	local songs=SONGMAN:GetAllSongs()
	local total=getn(songs)

	local filesread=0

	local curfolder=""
	local curfolderi=1

	for i,song in next,songs,nil do
		local dir=songdir(song)
		local infostr=sprintf("%d/%d\t%s",i,total,dir)
		Trace(infostr)

		if isthread then coroutine.yield(infostr) end

		--save every 50 folders in case we dead
--[[
		local newfolder=split("/",dir)[3]
		if newfolder~=curfolder then 
			curfolderi=math.mod(curfolderi,50)+1
			curfolder=newfolder
		end
		if curfolderi==1 then
			curfolderi=curfolderi+1
			PROFILEMAN:SaveMachineProfile()
		end
--]]

--		if math.mod(i,5000)==0 then PROFILEMAN:SaveMachineProfile() end


		for s,steps in next,getsteps(song),nil do
			local style=sts[stText[getst(steps)]+1]
			local diffstr=dn[dText[getdiff(steps)]+1]

--			Trace(sprintf("\t%s,%s",style,diffstr))
		
			if out[dir] and out[dir][style] and out[dir][style][diffstr] then break end --skip if there's already an entry

			filesread=filesread+1
			if filesread>=maxfiles then PROFILEMAN:SaveMachineProfile() filesread=0 end

			local chartdata=getSM(steps) --get everything inside #NOTES in a .sm

			--parse chart
			local measures={{}}
			local curmeasure=1

			for line in nextl(chartdata) do
				if sub(line,1,1)=="," then
					curmeasure=curmeasure+1
					measures[curmeasure]={}
				elseif len(line)>0 then
					insert(measures[curmeasure],line)
				end
			end

			for i,measuretype in next,{4,8,16,32},nil do
				--[[
					12ths, 24ths etc is broken due to rounding errors on recurring decimals.
					Maybe, multiply measures by divisions to counter it (by making them integers),
					and then divide it back at the other end?
				]]

				--get streams
				local streams={{0,0}}
				local firstbeat=0
				local lastbeat=0
				local curbeat=0
				local length=0
				for m,mtab in next,measures,nil do
					local div=getn(mtab)
					for row,notes in next,mtab,nil do
						local curbeat=m-1+(row-1)/div
						local beatdiv=curbeat-lastbeat
						if find(notes,"[124]") and beatdiv<=1/measuretype then --add to stream
							length=length+1/div
							lastbeat=curbeat
							streams[table.getn(streams)]={firstbeat,lastbeat}
						elseif beatdiv>1/measuretype then --stream broken
							if length>1 then insert(streams,{}) end --new stream
							lastbeat=curbeat
							firstbeat=curbeat
							length=0
						end
					end
				end

				--prune streams (delete everything shorter than minstreamlength)
				--TODO group streams by minbreaklength
				local outstreams={}
				local laststrend=0
				--CONDENSED_STREAMS ought to also apply here?
				for i=1,table.getn(streams) do local stream=streams[i]
				--for i,stream in next,streams,nil do
					if stream[2] and stream[2]-stream[1]>=minstreamlength then
						local start=stream[1]
						local length=stream[2]-stream[1]
						insert(outstreams,{start,length})
						laststrend=start+length
					end
				end

			
				--[[
				--prune streams 
				local minstreamlength=2
				local outstreams={}
				local laststrend=0
				for i,stream in next,streams,nil do
					if stream[2] and stream[2]-stream[1]>=minstreamlength then
						local start=stream[1]
						local length=stream[2]-stream[1]
						insert(outstreams,{start,length})
					end
				end
				--]]

				--construct breakdown string
				local notegap=2/measuretype --single note break (so-called "Ian breaks")
			
				local breakdown=""
				local laststrbeat=0
				local brokenstreamlength=0

				for i,stream in next,outstreams,nil do
					local start=stream[1]
					local length=stream[2]
					local sbreak=start-laststrbeat --gap between cur and prev streams

					--[[
						symbols to indicate stream gaps:
							note  .
							short -
							long  /
							vlong // (was | but I'm packing the streams now to save space and time and | is an invalid symbol for bcd.pack())
							
							group +
					--]]
					local separator=(
						sbreak<=notegap and "." or
						sbreak<=gap and "-" or
						sbreak<longbreak and "/" or "//"
					)
					
					-- Condensed breakdown format (indicated with a +) groups the streams by . and - 

					if CONDENSED_STREAMS and getn(outstreams)>max then --condense streams with short breaks
						if sbreak<=gap then
							if brokenstreamlength==0 then breakdown=breakdown.."/" end --FIXME: no "|"
							brokenstreamlength=brokenstreamlength+tostring(round(length))
						elseif brokenstreamlength>0 then
							breakdown=breakdown..brokenstreamlength.."+"
							brokenstreamlength=0
						else
							breakdown=breakdown..separator..tostring(round(length))
						end
					else
						breakdown=breakdown..separator..tostring(round(length))
					end
					laststrbeat=stream[2]+stream[1]

				end
--				Trace(sprintf("\t\t\t%d breakdown: %s",measuretype,breakdown))

				--export
				out[dir]=out[dir] or {}
				out[dir][style]=out[dir][style] or {}
				out[dir][style][diffstr]=out[dir][style][diffstr] or {}

				if getn(outstreams)>0 then
					local streamdata=Stream.Pack({breakdown=breakdown,stream=outstreams})
				
					out[dir][style][diffstr][measuretype]=streamdata
				end
			end
		end
	end
	
	Trace("..saving")
	
	--save it in case we crash
	--PROFILEMAN:SaveMachineProfile()
	
	Trace("..finished")
end
