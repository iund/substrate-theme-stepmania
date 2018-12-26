--[[

	TODO.
	There is a lot of work to do before this becomes useable.

--]]

--[[
local rivalrowlist=function(name)
	local handler = {
		getchoices = function() 
			local out={}
			for i,step in next,GetSortedStepsList(),nil do out[i]=sprintf("%s (%d)", Languages[CurLanguage()].Difficulty[DifficultyNames[dText[step:GetDifficulty()]+1] ], step:GetMeter()) end
			return out
			--return RowType.ListNames(list,Languages[CurLanguage()].Mods.Names[name]) end,
		end,		
		get = function(r,pn)
			local out={}
			for i,step in next,GetSortedStepsList(),nil do out[i]=step==CurSteps(pn) end
			return out
		end,
		set = function(r,pn,i,flag)
			GAMESTATE:SetCurrentSteps(pNum[pn],GetSortedStepsList()[i])
		end
	}
	return RowType.ListBase(name,handler,false,false,false)
end

------
Potentially Useful Row Functions:

	ReloadRowMessages={list of broadcast messages to subscribe to}, eg {"value1","value2","value3", ...}
	EnabledForPlayers={list of players}, eg {PLAYER_2}

------
Potential Row Layout:


				{Rival.RowType.Select.Rival},
				{Rival.RowType.Select.Replays},
				{Rival.RowType.Info.Best.Player},
				{Rival.RowType.Info.Best.Rival},
				{Rival.RowType.Info.Average.Player},
				{Rival.RowType.Info.Average.Rival},

				--pick rival (show choices list on side?)
				--pick rival replay data
				--your best (current song)
				--rival's best (current song)
				--your average for (difficulty meter)
				--rival's average for (difficulty meter)


				for example:
				song = Chromatic Blitz
				chart = Expert (14)

				rival = ELM
				pick rival's replay = 99.82% May 1
				
				best = 98.82% (-1.00%)
				rival best = 99.92 (+0.10%)
				
				average on 14s = 97.44%
				rival's average on 14s = 98.99%

	Pick rival:
	        Off
	        Best
	        Last
	        Opponent
	        	"Player 1 (ELM)"
	        Machine Best
	        100%
	        (rival) Best
	        (rival) Most Recent
	           eg. ELM Most Recent
	               ELM Best

	Pick Rival score:
	     Most recent, Best score
	     
	     
	------- Potential results screen scorebox layout:
	
		vs RMO Best: (99.87%): +0.44%
		vs Your Last (99.74%): +0.36%
		
	
	     
	]]


Rival={}
--Rival data manager.
Rival={
	FindUUID=function(profile,uuid) local out if profile then for i=1,table.getn(profile) do if profile[i].UUID==uuid then out=i end end end return out end,

	--Profile start:
	Init = function()
		CurRival={}
		if not GetSysProfile().Rival then GetSysProfile().Rival={ Profiles={}, Data={}, CourseData={} } end --Initialise rival table
	end,
	InitPlayer=function(pn)
		local pr=GetProfile(pn)
		if not pr.Rival then pr.Rival={} end
		local r=pr.Rival
		if not r.Profiles then r.Profiles={} end
		CurRival[pn]=pr.UUID==r.Current and pr or r.Profiles[Rival.FindUUID(r.Profiles,r.Current)]
	end,
	AfterInit=function()
		Rival.SaveProfiles() --add/update UUIDs.
	end,

	--SSM/mods menu:
	GetScore=function(pn,steps)
		local data=Rival.Load(pn,steps)
		return data and FormatPercentScore(data.Score) or "no data"
	end,
	GetScoreSelf=function(pn,steps)
		local data=Rival.LoadSelf(pn,steps)
		return data and FormatPercentScore(data.Score) or "no data"
	end,

	--SGP
--[[
	oldLoad = function(pn,steps) --Return value gets passed to Ghost.Load(). Should it be the opposite way round?
		local dir=CurSong():GetSongDir()
		local stype=GetStepsTypeString() --(it's always the same for both sides) --StepsTypeString[steps:GetStepsType()+1]
		local diffstr=DifficultyToString((steps or CurSteps(pn)):GetDifficulty())

		local playdata={}
		if pn and pn>0 and CurRival[pn] and CurRival[pn].UUID then
			if GetProfile(pn).UUID==CurRival[pn].UUID then --load own rival data
				local p=GetProfile(pn).GhostData
				playdata=p and p[dir] and p[dir][stype] and p[dir][stype][diffstr] or {}
			else
				local p=GetSysProfile().Rival.Data
				playdata=p and p[dir] and p[dir][stype] and p[dir][stype][diffstr] and p[dir][stype][diffstr][CurRival[pn].UUID] or {}
			end
		end

		--Highest score first.
		--TODO: Give the option to pick other runs, for example: most recent, best
		if playdata then table.sort(playdata,function(a,b) return a.Score>b.Score or a.Score==b.Score and a.Time>b.Time end) end
		return playdata and playdata[1]
	end,
	oldLoadSelf=function(pn,steps)
		local dir=CurSong():GetSongDir()
		local stype=GetStepsTypeString() --(it's always the same for both sides) --StepsTypeString[steps:GetStepsType()+1]
		local diffstr=DifficultyToString((steps or CurSteps(pn)):GetDifficulty())
		local p=GetProfile(pn).GhostData
		local playdata=p and p[dir] and p[dir][stype] and p[dir][stype][diffstr] or {}
		table.sort(playdata,function(a,b) return a.Score>b.Score or a.Score==b.Score and a.Time>b.Time end)
		return playdata and playdata[1]
	end,
--]]
	Load=function(pn,steps)
		--Use the course dir when retrieving courses. If the CourseDir() method isn't available (ie, when using vanilla 3.95), fall back onto the course title.
		local dir=IsCourseMode() and CurCourse() and (Course.GetCourseDir and CurCourse():GetCourseDir() or CurCourse():GetDisplayFullTitle()) or CurSong():GetSongDir()
		local stype=GetStepsTypeString()
		local diffstr=IsCourseMode() and CourseDifficultyNames[1+CurTrail(pn):GetDifficulty()] or DifficultyToString((steps or CurSteps(pn)):GetDifficulty())
		local playdata={}
		if pn and pn>0 and CurRival[pn] and CurRival[pn].UUID then
			if GetProfile(pn).UUID==CurRival[pn].UUID then --load own rival data, if "Self" was selected as a rival.
				local p=GetProfile(pn)[IsCourseMode() and "CourseData" or "GhostData"]
				playdata=p and p[dir] and p[dir][stype] and p[dir][stype][diffstr] or {}
			else --pull rival data from machine profile
				local p=GetSysProfile().Rival[IsCourseMode() and "CourseData" or "Data"]
				playdata=p and p[dir] and p[dir][stype] and p[dir][stype][diffstr] and p[dir][stype][diffstr][CurRival[pn].UUID] or {}
			end
		end

		if playdata then table.sort(playdata,function(a,b) return a.Score>b.Score or a.Score==b.Score and a.Time>b.Time end) end
		return playdata and playdata[1]
	end,
	LoadSelf=function(pn,steps)
		local dir=IsCourseMode() and CurCourse() and (Course.GetCourseDir and CurCourse():GetCourseDir() or CurCourse():GetDisplayFullTitle()) or CurSong():GetSongDir()
		local stype=GetStepsTypeString()
		local diffstr=IsCourseMode() and CourseDifficultyNames[1+CurTrail(pn):GetDifficulty()] or DifficultyToString((steps or CurSteps(pn)):GetDifficulty())
		local p=GetProfile(pn)[IsCourseMode() and "CourseData" or "GhostData"]
		local playdata=p and p[dir] and p[dir][stype] and p[dir][stype][diffstr] or {}
		table.sort(playdata,function(a,b) return a.Score>b.Score or a.Score==b.Score and a.Time>b.Time end)
		return playdata and playdata[1]
	end,
	oldLoadCourse=function(pn)
		--[[
		GhostDataCourse
			/Courses/Marathon2/Driven.crs
				dance-single
					Intense
						1
							Song 1
								data
							Song 2
								data
							Song 3
								data
						2
							data..
						3
							data..

		--]]

		local dir=IsCourseMode() and CurCourse() and (Course.GetCourseDir and CurCourse():GetCourseDir() or CurCourse():GetDisplayFullTitle()) or CurSong():GetSongDir()
		local stype=GetStepsTypeString()
		local diffstr=CourseDifficultyNames[1+CurTrail(pn):GetDifficulty()] --if this doesn't work, use my constant


		local song=CourseSongIndex()+1

		local playdata={}
		if pn and pn>0 and GetProfile(pn).UUID then
			local uuid=GetProfile(pn).UUID --TODO: Pick a rival
			local p=GetProfile(pn).Rival.CourseData
			local sp=GetSysProfile().GhostCourseData
			playdata=p and p[dir] and p[dir][stype] and p[dir][stype][diffstr]
				or sp and sp[dir] and sp[dir][stype] and sp[dir][stype][diffstr][uuid] or {}
		end

		--So far: this takes the highest-score ghost data
		if playdata then table.sort(playdata,function(a,b) return a.Score>b.Score end) end
		local pd=playdata and playdata[1]
	end,

	Save = function(pn,ghostdata)

		local dir=IsCourseMode() and CurCourse() and (Course.GetCourseDir and CurCourse():GetCourseDir() or CurCourse():GetDisplayFullTitle()) or CurSong():GetSongDir()
		local stype=GetStepsTypeString()
		local diffstr=IsCourseMode() and CourseDifficultyNames[1+CurTrail(pn):GetDifficulty()] or DifficultyToString(CurSteps(pn):GetDifficulty())
		local uuid=GetProfile(pn).UUID
		local stats=Scores[table.getn(Scores)][pn]
		
		local playdata=function() return {
			Score=UnformatPercentScore(stats.Percent),
			Ghost=IsCourseMode() and ghostdata or Ghost.Pack(ghostdata),
			Time=CurTime(),
			Stats=stats.Stats,
			Judge=join(",",stats.Judge), --Judge=bcd.pack(join(",",stats.Judge)),
			SurvivedTime=stats.Time,
			Failed=stats.Failed,
			Mods=PlayerMods(pn),
		} end

		--Save ghost
		if uuid then --save to USB:
			local envg=GetProfile(pn)[IsCourseMode() and "CourseData" or "GhostData"]
			--local envg=GetProfile(pn).GhostData
			envg[dir]=envg[dir] or {}
			envg[dir][stype]=envg[dir][stype] or {}
			envg[dir][stype][diffstr]=envg[dir][stype][diffstr] or {}	
			local pd=playdata()
			pd.Machine={UUID=GetSysProfile().UUID, Name=GetPref("MachineName")}
			table.insert(envg[dir][stype][diffstr], pd)
		end
		--Save to machine
		if uuid and string.sub(dir,1,3)~="@mc" then --save to machine: (don't save ghost data of usb customs)
			local envg=GetSysProfile().Rival[IsCourseMode() and "CourseData" or "Data"] or {}
			--local envg=GetSysProfile().Rival.Data or {}
			envg[dir]=envg[dir] or {}
			envg[dir][stype]=envg[dir][stype] or {}
			envg[dir][stype][diffstr]=envg[dir][stype][diffstr] or {}	
			envg[dir][stype][diffstr][uuid]=envg[dir][stype][diffstr][uuid] or {}
			table.insert(envg[dir][stype][diffstr][uuid], playdata())
		end
	end,
	SaveCourse=function(pn,ghostdata)
		--Todo.
	end,

	SaveProfiles = function()
		--save opponent's uuid to usb
		if GetNumPlayersEnabled()>1 then
			ForeachPlayer(function(pn)
				for pns=1,GetNumPlayersEnabled() do
					if pns~=pn and UsingUSB(pns) and UsingUSB(pn) and GetProfile(pns).UUID then
						local pr=GetProfile(pn).Rival.Profiles
						local uuid=GetProfile(pns).UUID
						if not Rival.FindUUID(pr,uuid) then
							table.insert(pr,{UUID=uuid,Name=PlayerName(pns)}) --add rival
						else
							pr[Rival.FindUUID(pr,uuid)].Name=PlayerName(pns) --update name
						end
					end			
				end
			end)
		end

		--add uuid to master profile list if not already there
		ForeachPlayer(function(pn)
			if UsingUSB(pn) and GetProfile(pn).UUID then
				local pr=GetSysProfile().Rival.Profiles
				local uuid=GetProfile(pn).UUID
				if not Rival.FindUUID(pr,uuid) then
					table.insert(pr,{UUID=uuid,Name=PlayerName(pn)}) --add rival
				else
					pr[Rival.FindUUID(pr,uuid)].Name=PlayerName(pn) --update display names
				end		
			end
		end)
	end,
}
