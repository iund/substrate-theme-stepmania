-- Boot functions:
function CacheSongPtrs()
	local sub=string.sub
	local gsub=string.gsub

	local NUM_SORT_ORDERS=NUM_SORT_ORDERS or 20 --...I think, I'll need to check it.

	--Store song pointers into a master lookup table; it's faster than trying to do SONGMAN:FindSong(name).
	MasterSongList={}

	--Sort songs into their folders.
	AllSongsBy={}
	AllSongsBy.Folder={}
	
	AllSongNamesByFolder={}
	
	AllSongsNamesBySort={} for so=1,NUM_SORT_ORDERS do AllSongsNamesBySort[so]={} end

	local foldertmp={}

	for i,song in next,SONGMAN:GetAllSongs(),nil do
		local folder=GetFolder(song)
		AllSongsBy.Folder[folder]=AllSongsBy.Folder[folder] or {}
		table.insert(AllSongsBy.Folder[folder],song)
		foldertmp[i]=folder

		local title=song:GetDisplayFullTitle()
		local titlet=song:GetTranslitFullTitle()
		local initial=string.sub(title,1,1)
		local artist=song:GetDisplayArtist()
		local artistt=song:GetTranslitArtist()
		
		AllSongNamesByFolder[folder]=AllSongNamesByFolder[folder] or {}
		AllSongNamesByFolder[folder][title]=song
		AllSongNamesByFolder[folder][titlet]=song

		--set up stuff for the music wheel.
		AllSongsNamesBySort[SORT_GROUP][folder]=AllSongsNamesBySort[SORT_GROUP][folder] or {}
		AllSongsNamesBySort[SORT_GROUP][folder][title]=song
		AllSongsNamesBySort[SORT_GROUP][folder][titlet]=song

		AllSongsNamesBySort[SORT_TITLE][initial]=AllSongsNamesBySort[SORT_TITLE][initial] or {}
		AllSongsNamesBySort[SORT_TITLE][initial][title]=song --table.insert(AllSongsNamesBySort[SORT_TITLE][initial],song)
		AllSongsNamesBySort[SORT_TITLE][initial][titlet]=song

		AllSongsNamesBySort[SORT_ARTIST][artist]=AllSongsNamesBySort[SORT_ARTIST][artist] or {}
		AllSongsNamesBySort[SORT_ARTIST][artist][title]=song --table.insert(AllSongsNamesBySort[SORT_ARTIST][artist],song)
		AllSongsNamesBySort[SORT_ARTIST][artist][titlet]=song

		local steps=song:GetAllSteps()
		for si,steps in next,steps,nil do
			local so=steps:GetDifficulty()+SORT_EASY_METER-1
			local meter=tostring(steps:GetMeter())
			if so>=SORT_EASY_METER then --don't pollute the sort before it
				AllSongsNamesBySort[so][meter]=AllSongsNamesBySort[so][meter] or {}
				AllSongsNamesBySort[so][meter][title]=song --table.insert(AllSongsNamesBySort[so][meter],song)
				AllSongsNamesBySort[so][meter][titlet]=song
			end
		end

		local dir=song:GetSongDir()
		MasterSongList[dir]=song --/Songs/folder/song/
		MasterSongList[string.sub(string.gsub(dir,'/Songs/',''),1,-2)]=song --"folder/song"
		MasterSongList[title]=song --song (translit title) (see Song::Matches (Song.cpp))
		MasterSongList[titlet]=song --song (translit title) (see Song::Matches (Song.cpp))

		local title=split("/", dir)[4] --"song" (subfolder name)
		if not MasterSongList[title] then MasterSongList[title]=song end --only match the first entry
	end

	AllSongsBy.Dir={} --Instead of SONGMAN:FindSong().
	for i,song in next,SONGMAN:GetAllSongs(),nil do AllSongsBy.Dir[song:GetSongDir()]=song end

	AllFolders={}
	for i,f in next,foldertmp,nil do if not table.find(AllFolders,f) then table.insert(AllFolders,f) end end

	--Won't hurt to do courses too.
	MasterCourseList={}
	local courses=SONGMAN:GetAllCourses(false)
	for i=1,table.getn(courses) do
		MasterCourseList[courses[i]:GetDisplayFullTitle()]=courses[i]
		MasterCourseList[courses[i]:GetTranslitFullTitle()]=courses[i]
		if Course.GetCourseDir then --this is an openitg thing but genericise it so it'll work in Sm5 etc
			MasterCourseList[courses[i]:GetCourseDir()]=courses[i]
		end
	end
end

--Cache radar values
function CacheRadarValues()
	local radarnames={
		["NumSteps"]=RADAR_CATEGORY_TAPS, --RADAR_NUM_TAPS_AND_HOLDS
		["Jumps"]=RADAR_CATEGORY_JUMPS, --RADAR_NUM_JUMPS,
		["Holds"]=RADAR_CATEGORY_HOLDS, --RADAR_NUM_HOLDS,
		["Mines"]=RADAR_CATEGORY_MINES, --RADAR_NUM_MINES,
		["Hands"]=RADAR_CATEGORY_HANDS, --RADAR_NUM_HANDS,
		["Rolls"]=RADAR_CATEGORY_ROLLS, --RADAR_NUM_ROLLS
	}

	local songs=SONGMAN:GetAllSongs()
	for i=1,table.getn(songs) do
		local dir=songs[i]:GetSongDir()
		local stepslist=songs[i]:GetAllSteps()
		for i=1,table.getn(stepslist) do
			local steps=stepslist[i]
--			local stype=StepsTypeString[stText[steps:GetStepsType()]+1]
--			local diffstr=DifficultyToString(dText[steps:GetDifficulty()])


			local stype=steps:GetStepsType()
			local diffstr=steps:GetDifficulty()

			local stats=steps:GetRadarValues()
		
			GetSysProfile().Cache=GetSysProfile().Cache or {}
			GetSysProfile().Cache.Radar=GetSysProfile().Cache.Radar or {}

			local envg=GetSysProfile().Cache.Radar
			envg[dir]=envg[dir] or {}
			envg[dir][stype]=envg[dir][stype] or {}
			envg[dir][stype][diffstr]=envg[dir][stype][diffstr] or {}	

			for name,rv in next,radarnames,nil do
				envg[dir][stype][diffstr][name]=stats:GetValue(rv)
			end
		end
	end

	local courses=SONGMAN:GetAllCourses(false)
	for i=1,table.getn(courses) do
		local dir=courses[i]:GetCourseDir()
		--umm.. how does one get Trails without the lua binding for it?
	end
end
--Todo: Cache charts? In sm versions that allow lua to read charts.
	
function CacheStreams() --SM5
	Trace("StreamCache running...")

	--Why won't stupid SM5 load/save machine profile lua table?
	--PROFILEMAN is there
	
	--if not PROFILEMAN:GetMachineProfile():GetUserTable() then
	--PROFILEMAN:GetMachineProfile():GetUserTable()={}
	--end
	
--	PROFILEMAN:GetMachineProfile():GetUserTable() = PROFILEMAN:GetMachineProfile():GetUserTable() or {}
	--Getusertable in sm5 is broken and people instead make files to store their lua variables in

	local p={} --PROFILEMAN:GetMachineProfile():GetUserTable() --GetSysProfile()
	p.StreamCache=p.StreamCache or {}

	local g_streams=p.StreamCache
	local insert=table.insert
	local len=string.len
	local sub=string.sub
	local find=string.find
	local getn=table.getn
	local floor=math.floor
	local round=function(n) return math.floor(n+0.5) end

	for _,s in next,SONGMAN:GetAllSongs(),nil do
		if not g_streams[s:GetSongDir()] then
			Trace("caching "..s:GetSongDir())
			local fn=s:GetAllSteps()[1]:GetFilename()
			local path=s:GetSongDir()

			local f=File.Open(fn,1)
			if not f then return end

			local contents=File.ReadContents(f)

			for a,b in
				string.right(fn,4)==".ssc"
					and string.gfind(contents,"#NOTEDATA:;(.-)#NOTES:(.-);")
					or string.gfind(contents,"#NOTES:(.-);")
			do 
				local rawchart=b or a
				local meta=b and a

				local style
				local diffstr
				local chartdata
				if meta then --ssc
					local rawlines=split("\n",meta)
					local lines={}
					for _,line in next,rawlines,nil do if string.find(line,":") then
						local n,v=unpack(split(":",line))
						--"#NAME:value;" -> lines["NAME"]="value"
						lines[string.right(n,string.len(n)-({string.find(n,"#")})[1])]=string.left(v,({string.find(v,";") or string.len(v)})[1]-1)
					end end
					style=lines.STEPSTYPE --eg: "dance-single"
					diffstr=lines.DIFFICULTY --eg: "Challenge"
					chartdata=split("\n",b)
				else --sm
					local chart=split("\n",rawchart)
					_,_,style=find(chart[2],"%s*(.-):")
					_,_,diffstr=find(chart[4],"%s*(.-):")
					chartdata=table.sub(chart,7)
				end
				
				--parse chart
				local measures={{}}
				local curmeasure=1
				for i,line in next,chartdata,nil do
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
	
					--prune streams 
					local minstreamlength=2
					local outstreams={}
					for i,stream in next,streams,nil do
						if stream[2] and stream[2]-stream[1]>=minstreamlength then
							local start=stream[1]
							local length=stream[2]-stream[1]
							insert(outstreams,{start,length})
						end
					end

					--construct breakdown string
					local max=6 --max number of streams to show
					local gap=2 --threshold for short breaks in measures
					local longbreakthreshold=16 --in measures
	
					local breakdown=""
					local laststrbeat=0
					local brokenstreamlength=0

					for i,stream in next,outstreams,nil do
						local start=stream[1]
						local length=stream[2]
						local sbreak=start-laststrbeat --gap between cur and prev streams
						local separator=(
							sbreak<=2/measuretype and "." or
							sbreak<=gap and "-" or
							sbreak>longbreakthreshold and "|" or "/"
						)

						if false then --getn(outstreams)>max then --condense streams with short breaks
							if sbreak<=gap then
								if brokenstreamlength==0 then breakdown=breakdown.."/" end --FIXME: no "|"
								brokenstreamlength=brokenstreamlength+tostring(round(length))
							elseif brokenstreamlength>0 then
								breakdown=breakdown..brokenstreamlength.."*"
								brokenstreamlength=0
							else
								breakdown=breakdown..separator..tostring(round(length))
							end
						else
							breakdown=breakdown..separator..tostring(round(length))
						end
						laststrbeat=stream[2]+stream[1]
					end

					--export
					if getn(outstreams)>0 then
						g_streams[path]=g_streams[path] or {}
						g_streams[path][style]=g_streams[path][style] or {}
						g_streams[path][style][diffstr]=g_streams[path][style][diffstr] or {}
						g_streams[path][style][diffstr][measuretype]={breakdown=breakdown, stream=outstreams} --g_streams[path][style][diffstr][measuretype] or {}
					end
				end
			end
		end
	end
	PROFILEMAN:SaveMachineProfile()
end


CacheCourseData=function()
	local ins=table.insert
	local courses={}
	for i=1,6 do courses[i]={} end
	for i,c in next,SONGMAN:GetAllCourses(false),nil do
		ins(courses[c:GetPlayMode()],c)
	end
	CourseCache=courses
end